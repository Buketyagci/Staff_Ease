import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/services/notificate_manager.dart';

class NotificationWidget extends StatefulWidget {
  final String status;
  final String path;
  const NotificationWidget({
    super.key,
    required this.status,
    required this.path,
  });

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  NotificateManager notification = NotificateManager();
  Set<int> expandedIndexes = {};

  @override
  Widget build(BuildContext context) {
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
                    "Yeni İletiler",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future:
                        (widget.path == 'messages')
                            ? fetchMessagesManagerHome(
                              status: widget.status,
                              path: widget.path,
                            )
                            : fetchMessagesEmployeeHome(
                              status: widget.status,
                              path: widget.path,
                            ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("snapshot error: ${snapshot.error}");
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Yeni ileti yok"));
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
                                      if (widget.path == 'messages') ...[
                                        if (!isExpanded) ...[
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
                                                          messageId:
                                                              item['key'],
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
                                                    print(
                                                      "Onaylama hatası: $e",
                                                    );
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
                                            "Başlık: ${item['title']}",
                                            style: GoogleFonts.josefinSans(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                        if (isExpanded) ...[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${item['name']}  ${item['surname']}",
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
                                                          messageId:
                                                              item['key'],
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
                                                "Başlık: ",
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
                                                  " ${item['message']} ",
                                                  style:
                                                      GoogleFonts.josefinSans(
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

                                      if (widget.path ==
                                          'messagesFromManager') ...[
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
                                                          department:
                                                              department!,
                                                          uid: uid,
                                                          messageId:
                                                              item['key'],
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
                                                    print(
                                                      "Onaylama hatası: $e",
                                                    );
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
                                                          department:
                                                              department!,
                                                          uid: uid,
                                                          messageId:
                                                              item['key'],
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
                                                    print(
                                                      "Onaylama hatası: $e",
                                                    );
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
                                                  style:
                                                      GoogleFonts.josefinSans(
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

  Future<List<Map<dynamic, dynamic>>> fetchMessagesManagerHome({
    required String status,
    required String path,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<dynamic, dynamic>> messages = [];
    int? lastLogout;

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child('users').get();

      String? department;
      String? userStatus;

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in userData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            userStatus = statusEntry.key;
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;
            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;

                final currentUserData = usersMap[uidKey];
                if (currentUserData != null &&
                    currentUserData is Map<dynamic, dynamic>) {
                  lastLogout = currentUserData['lastLogout'] ?? 0;
                }
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }
      if (department != null) {
        final ref = dbRef.child('users').child(department).child(status!);

        final employeeSnapshot = await ref.get();
        if (employeeSnapshot.exists) {
          final employeeUsers = employeeSnapshot.value as Map<dynamic, dynamic>;
          for (final userEntry in employeeUsers.entries) {
            final userId = userEntry.key;
            final userData = userEntry.value as Map<dynamic, dynamic>;
            print("userdata: $userData");
            if (userData.containsKey(path) && userData[path] is Map) {
              final messagesMap = userData[path] as Map<dynamic, dynamic>;
              messagesMap.forEach((messageId, value) {
                final createdAt = value['createdAt'];
                final isAfterLogout =
                    (lastLogout != null && createdAt != null)
                        ? createdAt > lastLogout
                        : false;
                if (value['checked'] == false && isAfterLogout) {
                  messages.add({
                    'key': messageId,
                    'userId': userId,
                    'name': userData['name'],
                    'surname': userData['surname'],
                    'department': userData['department'],
                    'title': value['title'],
                    'message': value['message'],
                    'createdAt': value['createdAt'],
                  });
                }
              });

              messages.sort((a, b) {
                final aTime = a['createdAt'] ?? 0;
                final bTime = b['createdAt'] ?? 0;
                return (bTime as int).compareTo(aTime as int);
              });
            } else {
              print("messages alanı bulunamadı");
            }
          }
        }
      }
    }
    print("mesajlar: $messages");
    return messages;
  }

  Future<List<Map<dynamic, dynamic>>> fetchMessagesEmployeeHome({
    required String status,
    required String path,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<dynamic, dynamic>> messages = [];
    int? lastLogout;

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child('users').get();

      String? department;
      //String? userStatus;

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in userData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            //userStatus = statusEntry.key;
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;
            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;

                final currentUserData = usersMap[uidKey];
                if (currentUserData != null &&
                    currentUserData is Map<dynamic, dynamic>) {
                  lastLogout = currentUserData['lastLogout'] ?? 0;
                }
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }
      if (department != null) {
        final ref = dbRef
            .child('users')
            .child(department)
            .child(status)
            .child(user.uid);

        final employeeSnapshot = await ref.get();
        if (employeeSnapshot.exists) {
          final employeeData = employeeSnapshot.value as Map<dynamic, dynamic>;
          print("employeeData: $employeeData");
          if (employeeData.containsKey(path) && employeeData[path] is Map) {
            final messagesMap = employeeData[path] as Map<dynamic, dynamic>;
            messagesMap.forEach((messageId, value) {
              final createdAt = value['createdAt'];
              final isAfterLogout =
                  (lastLogout != null && createdAt != null)
                      ? createdAt > lastLogout
                      : false;
              if (value['checked'] == false && isAfterLogout) {
                messages.add({
                  'key': messageId,
                  'userId': user.uid,
                  //'name': employeeData['name'],
                  //'surname': employeeData['surname'],
                  'department': employeeData['department'],
                  'title': value['title'],
                  'message': value['message'],
                  'createdAt': value['createdAt'],
                });
              }
            });

            messages.sort((a, b) {
              final aTime = a['createdAt'] ?? 0;
              final bTime = b['createdAt'] ?? 0;
              return (bTime as int).compareTo(aTime as int);
            });
          } else {
            print("messages alanı bulunamadı");
          }
        }
      }
    }
    print("mesajlar: $messages");
    return messages;
  }
}
