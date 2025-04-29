import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:staff_ease/widgets/message.dart';

class Refresh {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  final databaseRef = FirebaseDatabase.instance.ref();
  Message _showMessage = Message();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  Future<void> passwordUpdate({
    required String password,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        print(user.email);
        print(password);
        print(newPassword);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        _showMessage.showMessage("Şifre başarıyla değişti");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          print("Mevcut şifre hatalı.");
        } else if (e.code == 'invalid-credential') {
          _showMessage.showMessage("Mevcut şifre hatalı");
          print("Geçersiz kimlik bilgisi (credential).");
        } else {
          _showMessage.showMessage("Şifre değiştirilirken hata oluştu");
          print("Şifre değiştirilirken hata oluştu: ${e.message}");
        }
      }
    } else {
      print("kullanıcı oturumu açmamış");
    }
  }

  Future<void> emailUpdate({required String newEmail}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);

        print(
          "E-posta adresini güncellemek için doğrulama e-postası gönderildi.",
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print("Bu işlem için son zamanlarda giriş yapılması gerekiyor.");
        } else if (e.code == 'invalid-email') {
          print("Geçersiz e-posta adresi.");
        } else if (e.code == 'email-already-in-use') {
          print("Bu e-posta adresi zaten kullanılıyor.");
        } else {
          print("E-posta güncellenirken hata oluştu: ${e.message}");
        }
      }
    } else {
      print("Kullanıcı oturum açmamış.");
    }
  }
}
