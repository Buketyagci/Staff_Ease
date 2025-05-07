import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/screens/admin/admin_notification_screen.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';
import 'package:staff_ease/widgets/notification.dart';
import 'package:staff_ease/widgets/reminder.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String name = "";
  Set<int> expandedIndexes = {};

  final Auth auth = Auth();
  //final NotificateManager notification = NotificateManager();
  final NotificationWidget notification = NotificationWidget(
    status: 'Calisan',
    path: 'messages',
  );

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    String? user = await Auth().getUserName();
    setState(() {
      name = user ?? "User";
    });
  }

  String getTodayName() {
    final now = DateTime.now();
    const days = [
      "Pazartesi",
      "Salı",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];
    return days[now.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdminHome(context, name)),
      drawer: menuBarAdmin(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Reminder.Reminder(),
              NotificationWidget(status: 'Calisan', path: 'messages'),
              currentDayOffContainer(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget notifications() {
  //   return Padding(
  //     padding: const EdgeInsets.all(10),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.all(Radius.circular(15)),
  //         border: Border.all(
  //           color: const Color.fromARGB(255, 157, 155, 161),
  //           width: 2,
  //         ),
  //       ),
  //       width: 400,
  //       height: 400,
  //       child: Column(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   "Yeni Çalışan İletileri",
  //                   style: GoogleFonts.josefinSans(fontSize: 24),
  //                 ),
  //                 SizedBox(height: 10),
  //                 FutureBuilder<List<Map<dynamic, dynamic>>>(
  //                   future: notification.fetchMessagesManagerHome(),
  //                   builder: (context, snapshot) {
  //                     if (snapshot.connectionState == ConnectionState.waiting) {
  //                       return Center(child: CircularProgressIndicator());
  //                     } else if (snapshot.hasError) {
  //                       print("snapshot error: ${snapshot.error}");
  //                       return Center(child: Text("Hata: ${snapshot.error}"));
  //                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //                       return Center(child: Text("Yeni çalışan iletisi yok"));
  //                     }

  //                     final messages = snapshot.data!;
  //                     print("messages: $messages");
  //                     return SizedBox(
  //                       height: 340,
  //                       child: ListView.builder(
  //                         shrinkWrap: true,
  //                         physics: AlwaysScrollableScrollPhysics(),
  //                         itemCount: messages.length,
  //                         itemBuilder: (context, index) {
  //                           final item = messages[index];
  //                           final isExpanded = expandedIndexes.contains(index);

  //                           return Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                               vertical: 10,
  //                               horizontal: 16,
  //                             ),
  //                             child: GestureDetector(
  //                               onTap: () {
  //                                 setState(() {
  //                                   if (expandedIndexes.contains(index)) {
  //                                     expandedIndexes.remove(index);
  //                                   } else {
  //                                     expandedIndexes.add(index);
  //                                   }
  //                                 });
  //                               },
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                   color: const Color.fromARGB(
  //                                     255,
  //                                     241,
  //                                     235,
  //                                     255,
  //                                   ),
  //                                   borderRadius: BorderRadius.circular(12),
  //                                   border: Border.all(
  //                                     color: Colors.deepPurple.shade400,
  //                                     width: 1,
  //                                   ),
  //                                 ),
  //                                 padding: const EdgeInsets.all(12),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     if (isExpanded == false) ...[
  //                                       Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           Text(
  //                                             "${item['name']} ${item['surname']}",
  //                                             style: GoogleFonts.josefinSans(
  //                                               fontSize: 24,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.deepPurple,
  //                                             ),
  //                                           ),
  //                                           SizedBox(width: 100),
  //                                           IconButton(
  //                                             onPressed: () async {
  //                                               try {
  //                                                 print(
  //                                                   "Department: ${item['department']}",
  //                                                 );
  //                                                 print(
  //                                                   "UserID: ${item['userId']}",
  //                                                 );
  //                                                 print(
  //                                                   "MessageID: ${item['key']}",
  //                                                 );
  //                                                 await notification
  //                                                     .deleteMessageManager(
  //                                                       department:
  //                                                           item['department'],
  //                                                       uid: item['userId'],
  //                                                       messageId: item['key'],
  //                                                     );
  //                                                 ScaffoldMessenger.of(
  //                                                   context,
  //                                                 ).showSnackBar(
  //                                                   SnackBar(
  //                                                     content: Text(
  //                                                       "Mesaj silindi",
  //                                                     ),
  //                                                   ),
  //                                                 );
  //                                               } catch (e) {
  //                                                 print("Onaylama hatası: $e");
  //                                               }
  //                                             },
  //                                             icon: Icon(
  //                                               Icons.cancel_outlined,
  //                                               color: Colors.red,
  //                                               size: 30,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                       //SizedBox(height: 8),
  //                                       Text(
  //                                         "Başlık:   ${item['title']}",
  //                                         style: GoogleFonts.josefinSans(
  //                                           fontSize: 16,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                     if (isExpanded) ...[
  //                                       Row(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.spaceBetween,
  //                                         children: [
  //                                           Text(
  //                                             "${item['name']} ${item['surname']}",
  //                                             style: GoogleFonts.josefinSans(
  //                                               fontSize: 24,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.deepPurple,
  //                                             ),
  //                                           ),
  //                                           SizedBox(width: 100),
  //                                           IconButton(
  //                                             onPressed: () async {
  //                                               try {
  //                                                 await notification
  //                                                     .deleteMessageManager(
  //                                                       department:
  //                                                           item['department'],
  //                                                       uid: item['userId'],
  //                                                       messageId: item['key'],
  //                                                     );
  //                                                 ScaffoldMessenger.of(
  //                                                   context,
  //                                                 ).showSnackBar(
  //                                                   SnackBar(
  //                                                     content: Text(
  //                                                       "Mesaj silindi",
  //                                                     ),
  //                                                   ),
  //                                                 );
  //                                               } catch (e) {
  //                                                 print("Onaylama hatası");
  //                                               }
  //                                             },
  //                                             icon: Icon(
  //                                               Icons.cancel_outlined,
  //                                               color: Colors.red,
  //                                               size: 30,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                       //SizedBox(height: 8),
  //                                       Row(
  //                                         children: [
  //                                           Text(
  //                                             "Başlık:",
  //                                             style: GoogleFonts.josefinSans(
  //                                               fontSize: 20,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           ),
  //                                           Text(
  //                                             " ${item['title']}",
  //                                             style: GoogleFonts.josefinSans(
  //                                               fontSize: 20,
  //                                               color: Colors.blueGrey,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                       SizedBox(height: 20),
  //                                       Row(
  //                                         children: [
  //                                           Text(
  //                                             "İleti:",
  //                                             style: GoogleFonts.josefinSans(
  //                                               fontSize: 20,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           ),
  //                                           SizedBox(width: 20),
  //                                           Expanded(
  //                                             child: Text(
  //                                               " ${item['message']} ",
  //                                               style: GoogleFonts.josefinSans(
  //                                                 fontSize: 20,
  //                                                 color: Colors.blueGrey,
  //                                               ),
  //                                               softWrap: true,
  //                                               maxLines: 10,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget currentDayOffContainer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 15),
            Text(
              "Güncel İzinler",
              style: GoogleFonts.josefinSans(fontSize: 24),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<Map<dynamic, dynamic>>>(
              future: auth.fetchCurrentDayOff(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print("hata: ${snapshot.error}");
                  return Center(child: Text("Hataa: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("İzinli çalışan yok."));
                }

                final currentDayOff = snapshot.data!;
                return SizedBox(
                  height: 340,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: currentDayOff.length,
                    itemBuilder: (context, index) {
                      final item = currentDayOff[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 241, 235, 255),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.shade400,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item['name']} ${item['surname']}',
                                style: GoogleFonts.josefinSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${item["start"]} → ${item["finish"]}',
                                style: GoogleFonts.josefinSans(fontSize: 16),
                              ),
                              Text(
                                'Tür: ${item["type"]}',
                                style: GoogleFonts.josefinSans(fontSize: 14),
                              ),
                            ],
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
    );
  }

  myAppBarAdminHome(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 60),
        Text(
          "Hoşgeldin ${name.isNotEmpty ? name : "Kullanıcı"}",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminNotificationScreen(),
                ),
              );
            },
            icon: Icon(Icons.notifications, size: 40, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
