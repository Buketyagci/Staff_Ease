import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/widgets/message.dart';
import 'package:staff_ease/widgets/user_widgets/appbar_user.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';
import 'package:staff_ease/services/refresh.dart';

class UserSettingScreen extends StatefulWidget {
  const UserSettingScreen({super.key});

  @override
  State<UserSettingScreen> createState() => _UserSettingScreenState();
}

class _UserSettingScreenState extends State<UserSettingScreen> {
  Refresh update = Refresh();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Message msg = Message();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "Ayarlar")),
      drawer: menuBarUser(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [changePasswordContainer(), changeEmailContainer()],
          ),
        ),
      ),
    );
  }

  Widget changePasswordContainer() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: 400,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                "Şifre güncelle",
                style: GoogleFonts.josefinSans(fontSize: 24),
              ),
              SizedBox(height: 15),
              textFields(
                "Mevcut şifre",
                "Mevcut şifreyi giriniz",
                true,
                360,
                passwordController,
              ),
              textFields(
                "Yeni şifre",
                "Yeni şifreyi giriniz",
                true,
                360,
                newPasswordController,
              ),
              ElevatedButton(
                onPressed: () {
                  String password = passwordController.text;
                  String newPassword = newPasswordController.text;
                  if (password.isEmpty || newPassword.isEmpty) {
                    msg.showMessage("Lütfen tüm alanları doldurun");
                    return;
                  }
                  update.passwordUpdate(
                    newPassword: newPassword,
                    password: password,
                  );
                  passwordController.clear();
                  newPasswordController.clear();
                },
                child: Text("Şifreyi Güncelle", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget changeEmailContainer() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        width: 400,
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                "Email güncelle",
                style: GoogleFonts.josefinSans(fontSize: 24),
              ),
              SizedBox(height: 15),
              textFields(
                "Yeni email",
                "Yeni email adresini giriniz",
                false,
                360,
                emailController,
              ),
              ElevatedButton(
                onPressed: () {
                  String newEmail = emailController.text;
                  update.emailUpdate(newEmail: newEmail);
                },
                child: Text("Email Güncelle", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget textFields(
  String label,
  String hint,
  bool visible,
  double wdth,
  TextEditingController controller,
) {
  return Container(
    width: wdth,
    child: TextField(
      controller: controller,
      cursorWidth: 3,
      obscureText: visible,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      maxLength: 30,
    ),
  );
}
