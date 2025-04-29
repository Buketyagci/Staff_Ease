import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/main.dart';
import 'package:staff_ease/screens/admin/admin_home.dart';
import 'package:staff_ease/services/auth.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  String? errorMessage;

  void _showMessage(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.teal.shade100,
      textColor: Colors.grey,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBar(context)),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              loginLabels("e-posta"),
              textFields(
                false,
                "e-posta",
                "E-posta adresinizi giriniz",
                emailController,
              ),
              loginLabels("şifre"),
              textFields(
                true,
                "şifre",
                "Şifrenizi giriniz",
                passwordController,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: loginAdminButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginAdminButton(BuildContext context) {
    final Auth authService = Auth();
    return ElevatedButton(
      onPressed: () async {
        print("butona basıldı");
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        if (email.isEmpty || password.isEmpty) {
          setState(() {
            errorMessage = "E-posta veya şifre boş olamaz!";
          });
          return;
        }
        if (statusController.text.trim() == 'Çalışan') {
          setState(() {
            errorMessage = "Yönetici Girişi Yapamazsınız";
          });
          return;
        }
        try {
          await authService.signIn(email: email, password: password);
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            final dbRef = FirebaseDatabase.instance.ref();
            final userSnapshot = await dbRef.child('users').get();

            if (userSnapshot.exists) {
              final userData = userSnapshot.value as Map<dynamic, dynamic>;
              bool found = false;

              for (final departmentEntry in userData.entries) {
                //final department = departmentEntry.key;
                final statuses = departmentEntry.value as Map<dynamic, dynamic>;

                for (final statusEntry in statuses.entries) {
                  final status = statusEntry.key;
                  final usersMap = statusEntry.value as Map<dynamic, dynamic>;

                  for (final uidKey in usersMap.keys) {
                    if (uidKey == user.uid) {
                      found = true;

                      if (status == 'Yonetici') {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminHome()),
                        );
                      } else {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          errorMessage = "Yönetici Girişi Yapamazsınız";
                        });
                        _showMessage(errorMessage!);
                      }
                      break;
                    }
                  }
                  if (found) break;
                }
                if (found) break;
              }
              if (!found) {
                setState(() {
                  errorMessage = "Kullanıcı bulunamadı";
                });
                _showMessage(errorMessage!);
              }
            } else {
              setState(() {
                errorMessage = "Veritabanında kullanıcılar bulunamadı";
              });
              _showMessage(errorMessage!);
            }
          } else {
            setState(() {
              errorMessage = "Kullanıcı bilgisi bulunamadı";
              _showMessage(errorMessage!);
            });
          }
        } catch (e) {
          print("Giriş hatası buton : $e");
        }

        // try {
        //   await authService.signIn(email: email, password: password);
        //   final user = FirebaseAuth.instance.currentUser;
        //   if (user != null) {
        //     final dbRef = FirebaseDatabase.instance.ref();
        //     final snapshot = await dbRef.child('users/${user.uid}').get();
        //     if (snapshot.exists) {
        //       final data = snapshot.value as Map<dynamic, dynamic>;
        //       final status = data['status'];
        //       print(status);
        //       if (status == 'Yönetici') {
        //         if (!context.mounted) return;
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => AdminHome()),
        //         );
        //       } else {
        //         await FirebaseAuth.instance.signOut();
        //         errorMessage = 'Yönetici Girişi Yapamazsınız';
        //         _showMessage(errorMessage!);
        //       }
        //     }
        //   } else {
        //     setState(() {
        //       errorMessage = "Kullanıcı Bilgisi Bulunamadı!";
        //       _showMessage(errorMessage!);
        //     });
        //   }
        // } catch (e) {
        //   print("Giriş hatası buton: $e");
        //   ScaffoldMessenger.of(
        //     context,
        //   ).showSnackBar(SnackBar(content: Text("Giriş başarısız: $e")));
        // }
      },
      child: Text("Giriş Yap", style: GoogleFonts.josefinSans(fontSize: 20)),
    );
  }

  Row myAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.deepPurple),
        ),
        SizedBox(width: 60),
        Text(
          "Yönetici Giriş Sayfası",
          style: GoogleFonts.josefinSans(color: Colors.deepPurple),
        ),
      ],
    );
  }

  Padding textFields(
    bool visible,
    String labelt,
    String hintT,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        width: 400,
        child: TextField(
          controller: controller,
          cursorWidth: 3,
          obscureText: visible,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: labelt,
            hintText: hintT,
          ),
          maxLength: 30,
        ),
      ),
    );
  }

  Padding loginLabels(String login) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Text(login, style: GoogleFonts.josefinSans(fontSize: 25)),
    );
  }
}
