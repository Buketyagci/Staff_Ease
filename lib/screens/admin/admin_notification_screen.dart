import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/services/notificate_manager.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  bool isLoading = true;
  bool isExpanded = false;

  final NotificateManager _messages = NotificateManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Bildirimler", "")),
      drawer: menuBarAdmin(context),
      body: Center(child: Column(children: [messages()])),
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
                    "Çalışan İletileri",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder(
                    future: _messages.fetchMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Onay bekleyen talep yok"));
                      }

                      final messages = snapshot.data!;
                      return SizedBox(
                        height: 340,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = messages[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                    print(isExpanded);
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
                                              "${item['name']} ${item['surname']}",
                                              style: GoogleFonts.josefinSans(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        //SizedBox(height: 8),
                                        Text(
                                          "başlık: ${item['title']}",
                                          style: GoogleFonts.josefinSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                      if (isExpanded == false) ...[
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
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.delete,
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
                                            SizedBox(
                                              height: 200,
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
}
