import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/main.dart';
import 'package:staff_ease/screens/user/user_home.dart';
import 'package:staff_ease/services/auth.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;


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
              errorMessage != null ? Text(errorMessage!) : SizedBox.shrink(),
              loginButton(),
              Padding(
                padding: const EdgeInsets.only(top: 280.0),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Hesabınız yok mu? Yöneticiye bildirin",
                    style: GoogleFonts.josefinSans(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton() {
    final Auth authService = Auth();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: () async {
          print("butona basıldı");
          final email = emailController.text.trim();
          final password = passwordController.text.trim();
          print("email: $email");
          print("password: $password");
          if (email.isEmpty || password.isEmpty) {
            setState(() {
              errorMessage = "E-posta veya şifre boş olamaz!";
            });
            return;
          }

          try {
            await authService.signIn(email: email, password: password);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserHome()),
            );
          } catch (e) {
            print("Giriş hatası buton: $e");
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Giriş başarısız: $e")));
          }
        },
        child: Text("Giriş Yap", style: GoogleFonts.josefinSans(fontSize: 20)),
      ),
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
          "Kullanıcı Giriş Sayfası",
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
