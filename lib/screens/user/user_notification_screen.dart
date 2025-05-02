import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/services/notificate_manager.dart';
import 'package:staff_ease/widgets/message.dart';
import 'package:staff_ease/widgets/reminder.dart';
import 'package:staff_ease/widgets/user_widgets/appbar_user.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  String? _title;
  String? _message;
  Message msg = Message();
  NotificateManager notification = NotificateManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "Bildirimler")),
      drawer: menuBarUser(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [Reminder.Reminder(), createMessage()]),
        ),
      ),
    );
  }

  Widget createMessage() {
    _title = titleController.text;
    _message = messageController.text;
    return Container(
      width: 400,
      height: 520,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(
          color: const Color.fromARGB(255, 157, 155, 161),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Yöneticiye Bildir",
            style: GoogleFonts.josefinSans(fontSize: 24),
          ),
          SizedBox(height: 20),
          title("Başlık"),
          msgField(
            titleController,
            "İleti başlığı",
            "İleti başlığı giriniz",
            80,
            30,
          ),
          title("İleti"),
          msgField(messageController, "İleti", "İleti giriniz", 200, 400),
          ElevatedButton(
            onPressed: () async {
              String title = _title ?? "";
              String message = _message ?? "";
              print("title: $title");
              print("message: $message");

              if (title.isEmpty || message.isEmpty) {
                msg.showMessage("Lütfen tüm alanları doldurun");
                return;
              }

              bool success = await NotificateManager()
                  .sendNotificationToManager(title: title, message: message);
              if (success) {
                _title = null;
                _message = null;
                msg.showMessage("İleti başarıyla gönderildi");
              } else {
                msg.showMessage("İleti gönderilirken hata oluştu");
              }
            },
            child: Text(
              "Yöneticiye gönder",
              style: GoogleFonts.josefinSans(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget title(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(title, style: GoogleFonts.josefinSans(fontSize: 20)),
        ),
        SizedBox(width: 180),
      ],
    );
  }

  Widget msgField(
    TextEditingController controller,
    String labelText,
    String hintText,
    double height,
    int length,
  ) {
    return Container(
      margin: EdgeInsets.all(12),
      width: 360,
      height: height,
      child: TextField(
        onChanged: (value) {},
        cursorWidth: 3,
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelText,
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        minLines: 8,
        maxLines: 15,
        maxLength: length,
      ),
    );
  }
}
