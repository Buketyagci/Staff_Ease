import 'package:firebase_auth/firebase_auth.dart';
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
  bool isLoading = true;
  Set<int> expandedIndexes = {};
  Message msg = Message();
  NotificateManager notification = NotificateManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "Bildirimler")),
      drawer: menuBarUser(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Reminder.Reminder(),
              messages(),
              createMessage(),
              oldMessages(),
            ],
          ),
        ),
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
              String title = titleController.text.trim();
              String message = messageController.text.trim();
              print("title: $title");
              print("message: $message");

              if (title.isEmpty || message.isEmpty) {
                msg.showMessage("Lütfen tüm alanları doldurun");
                return;
              }

              bool success = await NotificateManager()
                  .sendNotificationToManager(title: title, message: message);
              setState(() {});

              if (success) {
                // _title = null;
                // _message = null;
                titleController.clear();
                messageController.clear();
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
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Yönetici İletileri",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: notification.fetchMessagesEmployee(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Yönetici iletisi yok"));
                      }

                      final messages = snapshot.data!;
                      print("messages: $messages");
                      return SizedBox(
                        height: 340,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final item = messages[index];
                            final isExpanded = expandedIndexes.contains(index);

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
                                    ;
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
                                      if (isExpanded) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "başlık: ${item['title']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 20,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  final uid =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid;
                                                  final department =
                                                      await notification
                                                          .getCurrentDepartment(
                                                            uid!,
                                                          );
                                                  print(
                                                    "Department: $department",
                                                  );
                                                  print("UserID: $uid");
                                                  print(
                                                    "MessageID: ${item['key']}",
                                                  );
                                                  await notification
                                                      .deleteMessageFromManager(
                                                        department: department!,
                                                        uid: uid,
                                                        messageId: item['key'],
                                                      );
                                                  setState(() {});

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
                                      ],
                                      if (!isExpanded) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "başlık: ${item['title']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 20,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  final uid =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid;
                                                  final department =
                                                      await notification
                                                          .getCurrentDepartment(
                                                            uid!,
                                                          );
                                                  print(
                                                    "Department: $department",
                                                  );
                                                  print("UserID: $uid");
                                                  print(
                                                    "MessageID: ${item['key']}",
                                                  );
                                                  await notification
                                                      .deleteMessageFromManager(
                                                        department: department!,
                                                        uid: uid,
                                                        messageId: item['key'],
                                                      );
                                                  setState(() {});

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
                                              // height: 200,
                                              child: Text(
                                                " ${item['message']} ",
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

  Widget oldMessages() {
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
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Geçmiş İletilerim",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: notification.fetchOldMessagesEmployee(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text("geçmiş çalışan iletisi yok"),
                        );
                      }

                      final messages = snapshot.data!;
                      print("messages: $messages");
                      return SizedBox(
                        height: 340,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final item = messages[index];
                            final isExpanded = expandedIndexes.contains(index);
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
                                      if (!isExpanded) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "Başlık:",
                                                    style:
                                                        GoogleFonts.josefinSans(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                  TextSpan(text: "  "),
                                                  TextSpan(
                                                    text: "${item['title']}",
                                                    style:
                                                        GoogleFonts.josefinSans(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  final uid =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid;
                                                  final department =
                                                      await notification
                                                          .getCurrentDepartment(
                                                            uid!,
                                                          );

                                                  print(item.toString());
                                                  print(
                                                    "Department: $department",
                                                  );
                                                  print("UserID: $uid");
                                                  print(
                                                    "MessageID: ${item['key']}",
                                                  );
                                                  await notification
                                                      .deleteMessageEmployee(
                                                        messageId: item['key'],
                                                        department: department!,
                                                        uid: uid,
                                                      );
                                                  setState(() {});
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
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (isExpanded) ...[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: "Başlık:",
                                                    style:
                                                        GoogleFonts.josefinSans(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                  ),
                                                  TextSpan(text: "  "),
                                                  TextSpan(
                                                    text: "${item['title']}",
                                                    style:
                                                        GoogleFonts.josefinSans(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                try {
                                                  final uid =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          ?.uid;
                                                  final department =
                                                      await notification
                                                          .getCurrentDepartment(
                                                            uid!,
                                                          );

                                                  print(item.toString());
                                                  print(
                                                    "Department: $department",
                                                  );
                                                  print("UserID: $uid");
                                                  print(
                                                    "MessageID: ${item['key']}",
                                                  );
                                                  await notification
                                                      .deleteMessageEmployee(
                                                        messageId: item['key'],
                                                        department: department!,
                                                        uid: uid,
                                                      );
                                                  setState(() {});

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
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),

                                        //SizedBox(height: 8),
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
                                              //height: 150,
                                              child: Text(
                                                " ${item['message']} ",
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
