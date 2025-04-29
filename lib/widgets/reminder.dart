import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Reminder extends StatefulWidget {
  Reminder.Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  bool isLoadingA = true;

  bool isLoadingB = true;

  List<Map<String, dynamic>> birthdayUsers = [];

  List<Map<String, dynamic>> anniversaryUsers = [];

  void _loadUserBirthdayData() async {
    final today = DateFormat("dd-MM").format(DateTime.now());
    final ref = FirebaseDatabase.instance.ref().child('users');

    DataSnapshot snapshot = await ref.get();
    List<Map<String, dynamic>> tempUsersBirthday = [];

    if (snapshot.exists) {
      final departments = snapshot.value as Map;
      departments.forEach((_, departmentUsers) {
        if (departmentUsers is Map) {
          departmentUsers.forEach((_, statusData) {
            if (statusData is Map) {
              statusData.forEach((_, userData) {
                if (userData is Map && userData.containsKey('birthday')) {
                  String birthday = userData['birthday'];
                  if (birthday.substring(0, 5) == today) {
                    tempUsersBirthday.add({
                      'name': userData['name'],
                      'surname': userData['surname'],
                      'birthday': birthday,
                    });
                  }
                }
                ;
              });
            }
          });
        }
      });
    }

    setState(() {
      birthdayUsers = tempUsersBirthday;
      isLoadingB = false;
    });
  }

  void _loadUserAnniversaryData() async {
    final today = DateFormat("dd-MM").format(DateTime.now());
    final ref = FirebaseDatabase.instance.ref().child('users');

    DataSnapshot snapshot = await ref.get();
    List<Map<String, dynamic>> tempUsersAnniversary = [];

    if (snapshot.exists) {
      final departments = snapshot.value as Map;
      departments.forEach((_, departmentUsers) {
        if (departmentUsers is Map) {
          departmentUsers.forEach((_, statusData) {
            if (statusData is Map) {
              statusData.forEach((_, userData) {
                if (userData is Map && userData.containsKey('startDate')) {
                  String anniversary = userData['startDate'];
                  if (anniversary.substring(0, 5) == today) {
                    int yearAnn =
                        DateTime.now().year -
                        int.parse(anniversary.substring(6, 10));
                    tempUsersAnniversary.add({
                      'name': userData['name'],
                      'surname': userData['surname'],
                      'department': userData['department'],
                      'startDate': anniversary,
                      'yearAnn': yearAnn,
                    });
                  }
                }
                ;
              });
            }
          });
        }
      });
    }

    setState(() {
      anniversaryUsers = tempUsersAnniversary;
      isLoadingA = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserAnniversaryData();
    _loadUserBirthdayData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 400,
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
                "Hatırlatıcı:",
                style: GoogleFonts.josefinSans(fontSize: 24),
              ),
              SizedBox(height: 15),
              isLoadingB
                  ? CircularProgressIndicator()
                  : birthdayUsers.isEmpty
                  ? Text("")
                  : Column(
                    children:
                        birthdayUsers.map((user) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.cake),
                                SizedBox(width: 10),
                                Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      width: 340,
                                      child: Text(
                                        "${user['name']} ${user['surname']} adlı çalışanın doğum günü",
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 20,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
              isLoadingA
                  ? CircularProgressIndicator()
                  : anniversaryUsers.isEmpty
                  ? Text("")
                  : Column(
                    children:
                        anniversaryUsers.map((user) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.celebration),
                                SizedBox(width: 10),
                                Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      width: 320,
                                      child: Text(
                                        user['yearAnn'] > 0
                                            ? "${user['name']} ${user['surname']} adlı çalışanın şirketimizde ${user['yearAnn']}. yılı"
                                            : "${user['name']} ${user['surname']} adlı çalışan ${user['department']} departmanında işe başladı.",
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 20,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
