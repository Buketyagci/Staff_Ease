import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/services/notificate_manager.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';
import 'package:staff_ease/widgets/message.dart';

class AnnounceScreen extends StatefulWidget {
  const AnnounceScreen({super.key});

  @override
  State<AnnounceScreen> createState() => _AnnounceScreenState();
}

class _AnnounceScreenState extends State<AnnounceScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  Message msg = Message();
  String? _title;
  String? _message;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Duyuru", "")),
      drawer: menuBarAdmin(context),
      body: Center(child: Column(children: [createMessage()])),
    );
  }

  Widget createMessage() {
    // _title = titleController.text;
    // _message = messageController.text;
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
            "Çalışanlara Bildir",
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
              String title = titleController.text.trim();
              String message = messageController.text.trim();
              print(_title);
              print("title: $title");
              print("message: $message");

              if (title.isEmpty || message.isEmpty) {
                msg.showMessage("Lütfen tüm alanları doldurun");
                return;
              }

              bool success = await NotificateManager()
                  .sendNotificationToEmployee(title: title, message: message);
              if (success) {
                titleController.clear();
                messageController.clear();
                msg.showMessage("İleti başarıyla gönderildi");
              } else {
                msg.showMessage("İleti gönderilirken hata oluştu");
              }
            },
            child: Text("Gönder", style: GoogleFonts.josefinSans(fontSize: 20)),
          ),
        ],
      ),
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
}
