import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staff_ease/services/notificate_manager.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';
import 'package:staff_ease/widgets/message.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  bool isLoading = true;

  Set<int> expandedIndexes = {};

  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  //String? _title;
  //String? _message;
  Message msg = Message();

  NotificateManager notification = NotificateManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Bildirimler", "")),
      drawer: menuBarAdmin(context),
      body: Center(
        child: SingleChildScrollView(child: Column(children: [messages()])),
      ),
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
              //print(_title);
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

  Widget messages() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        width: 400,
        height: 720,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Çalışan İletileri",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: notification.fetchMessagesManager(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Çalışan iletisi yok"));
                      }

                      final messages = snapshot.data!;
                      print("messages: $messages");
                      return SizedBox(
                        height: 660,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final item = messages[index];
                            final isExpanded = expandedIndexes.contains(index);
                            int createdAt = item['createdAt'];
                            DateTime datetime =
                                DateTime.fromMillisecondsSinceEpoch(createdAt);
                            String formattedDate = DateFormat(
                              'dd.MM.yyyy HH:mm',
                            ).format(datetime);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (expandedIndexes.contains(index)) {
                                      expandedIndexes.remove(index);
                                    } else {
                                      expandedIndexes.add(index);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      241,
                                      235,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.deepPurple.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (isExpanded == false) ...[
                                        Text("$formattedDate"),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${item['name']} ${item['surname']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  print(
                                                    "Department: ${item['department']}",
                                                  );
                                                  print(
                                                    "UserID: ${item['userId']}",
                                                  );
                                                  print(
                                                    "MessageID: ${item['key']}",
                                                  );
                                                  await notification
                                                      .deleteMessageManager(
                                                        department:
                                                            item['department'],
                                                        uid: item['userId'],
                                                        messageId: item['key'],
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Mesaj silindi",
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  print("Onaylama hatası: $e");
                                                }
                                              },
                                              icon: Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        //SizedBox(height: 8),
                                        Text(
                                          "Başlık:   ${item['title']}",
                                          style: GoogleFonts.josefinSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                      if (isExpanded) ...[
                                        Text("$formattedDate"),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${item['name']} ${item['surname']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  await notification
                                                      .deleteMessageManager(
                                                        department:
                                                            item['department'],
                                                        uid: item['userId'],
                                                        messageId: item['key'],
                                                      );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Mesaj silindi",
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  print("Onaylama hatası");
                                                }
                                              },
                                              icon: Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        //SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "Başlık:",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              " ${item['title']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 20,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Text(
                                              "İleti:",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            Expanded(
                                              child: Text(
                                                " ${item['message']} sdvgdrfrhbgjnythjgt",
                                                style: GoogleFonts.josefinSans(
                                                  fontSize: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                softWrap: true,
                                                maxLines: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
