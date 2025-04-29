import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:staff_ease/utils/data_migration.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  final databaseRef = FirebaseDatabase.instance.ref();

  static String? username;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  void _showMessage(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.teal.shade100,
      textColor: Colors.grey,
      fontSize: 16.0,
    );
  }

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> createUser({
    required String name,
    required String surname,
    required String email,
    required String phone,
    required String gender,
    required String status,
    required String birthday,
    required String startDate,
    required String password,
    required String department,
  }) async {
    try {
      DateTime birthdayDate = DateTime.parse(
        birthday.split("-").reversed.join("-"),
      );
      int dayOff = 15;
      int sickList = 0;
      int age = calculateAge(birthdayDate);

      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          String currentUserId = currentUser.uid;
          print("giriş yapan kullanıcı: $currentUserId");
        }
        String sanitizedStatus = sanitizeStatus(status);
        String sanitizedDepartment = sanitizeDepartment(department);
        await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(sanitizedDepartment)
            .child(sanitizedStatus)
            .child(user.uid)
            .set({
              'name': name,
              'surname': surname,
              'email': email,
              'age': age,
              'dayOff': dayOff,
              'sickList': sickList,
              'status': status,
              'gender': gender,
              'birthday': birthday,
              'startDate': startDate,
              'password': password,
              'createdAt': ServerValue.timestamp,
              'department': department,
            });
        print("Kullanıcı başarıyla kaydedildi.");

        DataSnapshot userSnapshot =
            (await FirebaseDatabase.instance
                    .ref()
                    .child('users')
                    .child(department)
                    .child(status)
                    .child(user.uid)
                    .once())
                as DataSnapshot;

        print(userSnapshot.value!);
      }
    } catch (e) {
      print("Kayıt hatası: $e");
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'E-posta veya şifre boş olamaz!',
      );
    }

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw FirebaseAuthException(
        code: 'no-internet',
        message: 'İnternet bağlantısı yok!',
      );
    }
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      print("Giriş başarılı: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print("Giriş hatası: ${e.message}");
      throw e;
    }
  }

  Future<void> initializeUserName() async {
    try {
      // Eğer zaten kullanıcı adı alınmışsa, tekrar sorgulama yapmaya gerek yok
      if (username != null) {
        return; // Kullanıcı adı zaten mevcut, işlemi bitir
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print("currentuser: $uid");

        final List<String> departments = [
          'Secilmedi',
          'Bilgi_Islem',
          'Insan_Kaynaklari',
          'Muhasebe',
          'Idari_Isler',
          'Yonetim',
          'Pazarlama',
          'Satis',
          'Kalite_Kontrol',
          'Lojistik',
          'Satin_Alma',
          'Planlama',
          'ArGe',
          'Makine',
          'Bakim_Teknik',
          'Musteri_Hizmetleri',
          'Ihracat_Ithalat',
          'Saglik_ve_Guvenlik',
        ];

        // Departmanları dolaşarak kullanıcı adını bulma
        for (String department in departments) {
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Calisan')
              .child(uid);

          DatabaseEvent event = await userRef.once();

          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>,
            );
            username = data['name'] ?? "Userrrr"; // Kullanıcı adını saklıyoruz
            return; // Kullanıcı adı alındı, işlemi bitir
          }

          DatabaseReference adminRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Yonetici')
              .child(uid);

          DatabaseEvent adminEvent = await adminRef.once();

          if (adminEvent.snapshot.exists && adminEvent.snapshot.value != null) {
            final adminData = Map<String, dynamic>.from(
              adminEvent.snapshot.value as Map<dynamic, dynamic>,
            );
            username =
                adminData['name'] ?? "Admin"; // Yönetici adı da saklanabilir
            return; // Yönetici adı alındı, işlemi bitir
          }
        }
        username = "User"; // Eğer isim bulunmazsa, default değer
      }
    } catch (e) {
      print("Ad alma hatası: $e");
      username = "Userr"; // Hata durumunda default isim
    }
  }

  String getCurrentUserName() {
    if (username != null) {
      return username!;
    } else {
      return "User";
    }
  }

  Future<String?> getUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print("currentuser: $uid");
        final List<String> departments = [
          'Secilmedi',
          'Bilgi_Islem',
          'Insan_Kaynaklari',
          'Muhasebe',
          'Idari_Isler',
          'Yonetim',
          'Pazarlama',
          'Satis',
          'Kalite_Kontrol',
          'Lojistik',
          'Satin_Alma',
          'Planlama',
          'ArGe',
          'Makine',
          'Bakim_Teknik',
          'Musteri_Hizmetleri',
          'Ihracat_Ithalat',
          'Saglik_ve_Guvenlik',
        ];

        for (String department in departments) {
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Calisan')
              .child(uid);

          DatabaseEvent event = await userRef.once();

          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              event.snapshot.value as Map<dynamic, dynamic>,
            );
            final userName = data['name'] ?? "Userrrr";
            return userName;
          }

          DatabaseReference adminRef = FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Yonetici')
              .child(uid);

          DatabaseEvent adminEvent = await adminRef.once();

          if (adminEvent.snapshot.exists && adminEvent.snapshot.value != null) {
            final adminData = Map<String, dynamic>.from(
              adminEvent.snapshot.value as Map<dynamic, dynamic>,
            );
            final adminName = adminData['name'] ?? "Admin";
            return adminName;
          }
        }

        print("Current UID: $uid");
        print("Kullanıcı adı bulunamadı.");
        return "User";
      } else {
        print("currentUser null");
        return "Userrr";
      }
    } catch (e) {
      print("Ad alma hatası: $e");
      return "Userr";
    }
  }

  Future<int> getDayOffCount() async {
    if (currentUser == null) {
      print("Kullanıcı giriş yapmamış");
      return 0;
    }
    try {
      final uid = currentUser!.uid;
      final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child(
        'users',
      );

      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> departments = snapshot.value as Map;

        for (var departmentEntry in departments.entries) {
          Map<dynamic, dynamic> userTypes = departmentEntry.value;

          for (var userTypeEntry in userTypes.entries) {
            Map<dynamic, dynamic> users = userTypeEntry.value;

            if (users.containsKey(uid)) {
              Map<dynamic, dynamic> userData = users[uid];
              print("Kullanıcı bulundu: $userData");

              if (userData.containsKey('dayOff')) {
                print("izin günü : ${userData['dayOff']}");
                return userData['dayOff'];
              } else {
                print("dayOff alanı bulunamadı.");
                return 0;
              }
            }
          }
        }

        print("Kullanıcı hiçbir departmanda bulunamadı.");
        return 0;
      } else {
        print("Kullanıcı verisi bulunamadı.");
        return 0;
      }
    } catch (e) {
      print("Hata oluştu: $e");
      return 0;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> createDayOffRequest({
    required String dayOffStart,
    required String dayOffEnd,
    required String type,
  }) async {
    bool isConfirmed = false;
    bool isChecked = false;

    String department = "";
    String status = "";

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final uid = currentUser.uid;

    try {
      final DataSnapshot snapshot =
          await FirebaseDatabase.instance.ref().child('users').get();

      if (snapshot.exists) {
        final departments = snapshot.value as Map;
        for (var departmentEntry in departments.entries) {
          final departmentName = departmentEntry.key;
          final statuses = departmentEntry.value as Map;

          for (var statusEntry in statuses.entries) {
            final statusName = statusEntry.key;
            status = statusName;
            final usersMap = statusEntry.value as Map;

            if (usersMap.containsKey(uid)) {
              department = departmentName;
              print("Kullanıcı departmanı bulundu: $department");
              final userData = usersMap[uid] as Map;
              final startDateString = userData['startDate'] as String?;
              if (startDateString == null) {
                _showMessage("İşe başlama tarihi bulunamadı.");
                return false;
              }

              try {
                final formatter = DateFormat('dd-MM-yyyy');
                final startDate = formatter.parseStrict(startDateString);
                final now = DateTime.now();
                final daysWorked = now.difference(startDate).inDays;

                if (daysWorked < 180) {
                  _showMessage(
                    "İşe başlayalı 6 ay olmadan izin talebinde bulunamazsınız.",
                  );
                  return false;
                }
              } catch (e) {
                print("Tarih formatı çözümlenemedi: $e");
                _showMessage("Geçersiz işe başlama tarihi formatı.");
                return false;
              }
              if (userData.containsKey('dayOffRequests')) {
                final existingRequest =
                    userData['dayOffRequests'] as Map<dynamic, dynamic>;
                DateTime newStart = DateTime.parse(dayOffStart);
                DateTime newEnd = DateTime.parse(dayOffEnd);
                for (var request in existingRequest.values) {
                  if (request['dayOffStart'] != null &&
                      request['dayOffEnd'] != null) {
                    DateTime existingStart = DateTime.parse(
                      request['dayOffStart'],
                    );
                    DateTime existingEnd = DateTime.parse(request['dayOffEnd']);

                    bool datesOverlap =
                        (newStart.isBefore(existingEnd) ||
                            newStart.isAtSameMomentAs(existingEnd)) &&
                        (newEnd.isAfter(existingStart) ||
                            newEnd.isAtSameMomentAs(existingStart));

                    if (datesOverlap) {
                      _showMessage(
                        "Bu tarihler arasında zaten bir izin talebiniz var.",
                      );
                      return false;
                    }
                  }
                }
              }

              break;
            }
          }
          if (department.isNotEmpty) break;
        }
      }

      if (department.isEmpty) {
        print("Kullanıcının departmanı bulunamadı.");
        return false;
      }
    } catch (e) {
      print("Departman aranırken hata oluştu: $e");
      return false;
    }

    int totalDay = 0;
    try {
      DateTime start = DateTime.parse(dayOffStart);
      DateTime end = DateTime.parse(dayOffEnd);
      totalDay = end.difference(start).inDays + 1;
      int weekendCount = 0;
      DateTime tempDate = start;
      while (tempDate.isBefore(end.add(const Duration(days: 1)))) {
        print(tempDate.weekday);
        if (tempDate.weekday == DateTime.saturday ||
            tempDate.weekday == DateTime.sunday) {
          weekendCount++;
          print(weekendCount);
        }
        tempDate = tempDate.add(const Duration(days: 1));
      }
      print(totalDay);
      print("weekend: $weekendCount");
      totalDay = totalDay - weekendCount;
      try {
        final userSnapshot =
            await FirebaseDatabase.instance
                .ref()
                .child('users')
                .child(department)
                .child(status)
                .child(uid)
                .get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.value as Map;

          final currentDayOff = userData['dayOff'];

          if (currentDayOff is int && totalDay > currentDayOff) {
            _showMessage(
              "Toplam $totalDay gün izin istiyorsunuz fakat sadece $currentDayOff gün izin hakkınız kaldı",
            );
            return false;
          }
        } else {
          _showMessage("İzin hakkınız sistemde bulunamadı");
          return false;
        }
      } catch (e) {}
      if (totalDay <= 0) {
        _showMessage(
          "İzin başlangıç ve bitiş tarihi geçersiz veya tüm günler hafta sonuna denk geliyor",
        );
        return false;
      }
    } catch (e) {
      print("Tarihler işlenirken hata: $e");
    }

    try {
      String requestId =
          FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child(status)
              .child(uid)
              .child('dayOffRequests')
              .push()
              .key ??
          '';

      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(department)
          .child(status)
          .child(uid)
          .child('dayOffRequests')
          .child(requestId)
          .set({
            'dayOffStart': dayOffStart,
            'dayOffEnd': dayOffEnd,
            'totalDay': totalDay,
            'type': type,
            'checked': isChecked,
            'createdAt': ServerValue.timestamp,
            'status': isConfirmed,
          });

      print("İzin talebi başarıyla kaydedildi.");
      return true;
    } catch (e) {
      print("İzin talebi kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  Future<void> approveDayOffRequest({
    required String department,
    required String uid,
    required String requestId,
  }) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(department)
        .child('Calisan')
        .child(uid)
        .child('dayOffRequests')
        .child(requestId);

    final userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(department)
        .child('Calisan')
        .child(uid);

    print("userref: $userRef");

    final userSnapshot = await userRef.get();
    print("userSnapshot exists: ${userSnapshot.exists}");
    print("userSnapshot value: ${userSnapshot.value}");

    if (userSnapshot.exists) {
      print("kullanıcı verisi mevcut, işlem devam ediyor");

      final userData = userSnapshot.value as Map<dynamic, dynamic>;
      final currentSickList =
          userData['sickList'] != null && userData['sickList'] is int
              ? userData['sickList'] as int
              : 0;
      final currentDayOff =
          userData['dayOff'] != null && userData['dayOff'] is int
              ? userData['dayOff'] as int
              : 0;

      final requestSnapshot = await ref.get();
      final totalDay = requestSnapshot.child('totalDay').value;
      final type = requestSnapshot.child('type').value;

      if (totalDay != null && totalDay is int) {
        await ref.update({'checked': true, 'status': true});

        if (type == "Raporlu") {
          final updatedSickList = currentSickList + totalDay;
          await userRef.update({'sickList': updatedSickList});
          print("Raporlu izin onaylandı sickList güncellendi");
        } else {
          final dayoffUpdate = currentDayOff - totalDay;

          await userRef.update({'dayOff': dayoffUpdate});

          print("izin onaylandı, güncellemesi tamamlandı");
        }
      } else {
        throw Exception('Toplam izin günü verisi eksik veya geçersiz');
      }
    } else {
      throw Exception('Kullanıcı verisi bulunamadı');
    }
  }

  Future<void> cancelDayOffRequest({
    required String department,
    required String uid,
    required String requestId,
  }) async {
    final ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(department)
        .child('Calisan')
        .child(uid)
        .child('dayOffRequests')
        .child(requestId);

    final userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(department)
        .child('Calisan')
        .child(uid);

    print("userref: $userRef");

    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      await ref.update({'checked': true});
    } else {
      throw Exception('Kullanıcı verisi bulunamadı');
    }
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(
        date,
      ); // ISO8601 formatındaki tarihi DateTime'a çevir
      return DateFormat(
        'dd-MM-yyyy',
      ).format(parsedDate); // Gün-Ay-Yıl formatında döndür
    } catch (e) {
      print("Tarih format hatası: $e");
      return date; // Hata olursa orijinal tarih döner
    }
  }

  Future<List<Map<dynamic, dynamic>>> fetchDayOffRequests() async {
    final user = _firebaseAuth.currentUser;
    List<Map<dynamic, dynamic>> requests = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final usersSnapshot = await dbRef.child('users').get();

      String? department;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in usersData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;

            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }

      if (department != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Calisan');

        final calisanSnapshot = await ref.get();
        //print("Veri çekildi mi? ${calisanSnapshot.exists}");
        //print("Calisan Verisi: ${calisanSnapshot.value}");
        if (calisanSnapshot.exists) {
          final calisanUsers = calisanSnapshot.value as Map<dynamic, dynamic>;
          for (final userEntry in calisanUsers.entries) {
            final userId = userEntry.key;
            final userData = userEntry.value as Map<dynamic, dynamic>;
            //print("kullanıcı verisi: $userData");

            if (userData.containsKey('dayOffRequests') &&
                userData['dayOffRequests'] is Map) {
              final requestsMap =
                  userData['dayOffRequests'] as Map<dynamic, dynamic>;
              requestsMap.forEach((requestId, value) {
                if (value['checked'] == false) {
                  requests.add({
                    "key": requestId,
                    "type": value["type"],
                    "start": formatDate(value["dayOffStart"]),
                    "finish": formatDate(value["dayOffEnd"]),
                    "userId": userId,
                    "department": department,
                    "name": userData['name'],
                    "surname": userData['surname'],
                    "checked": value["checked"],
                    "status": value["status"],
                  });
                }
              });
            } else {
              //print("dayOffRequests alanı bulunamadı veya null");
            }
            ;
          }
        }
      }
    }

    return requests;
  }

  Future<List<Map<dynamic, dynamic>>> fetchDayOffRequestsOfUser() async {
    final user = _firebaseAuth.currentUser;
    List<Map<dynamic, dynamic>> requestsOfUser = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final usersSnapshot = await dbRef.child('users').get();

      String? department;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in usersData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;

            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;
                print("Kullanıcının departmanı: $department");
                print("Statü: ${statusEntry.key}");
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }

      if (department != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Calisan')
            .child(user.uid);

        final dayOffSnapshot = await ref.get();
        print("Veri çekildi mi? ${dayOffSnapshot.exists}");
        print("İzin Verisi: ${dayOffSnapshot.value}");
        if (dayOffSnapshot.exists) {
          final userData = dayOffSnapshot.value as Map<dynamic, dynamic>;

          if (userData.containsKey('dayOffRequests') &&
              userData['dayOffRequests'] is Map) {
            final dayOffRequests =
                userData['dayOffRequests'] as Map<dynamic, dynamic>;

            dayOffRequests.forEach((requestId, value) {
              if (value['checked'] == false) {
                requestsOfUser.add({
                  "key": requestId,
                  "type": value["type"],
                  "start": formatDate(value["dayOffStart"]),
                  "finish": formatDate(value["dayOffEnd"]),
                  "userId": user.uid,
                  "name": userData['name'],
                  "surname": userData['surname'],
                });
              }
            });
          } else {
            print("dayOffRequests alanı bulunamadı veya null");
          }
        }
      }
    }
    return requestsOfUser;
  }

  Future<List<Map<dynamic, dynamic>>> fetchOldDayOffRequestsOfUser() async {
    final user = _firebaseAuth.currentUser;
    List<Map<dynamic, dynamic>> oldRequestsOfUser = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final usersSnapshot = await dbRef.child('users').get();

      String? department;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in usersData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;

            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;
                print("Kullanıcının departmanı: $department");
                print("Statü: ${statusEntry.key}");
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }

      if (department != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Calisan')
            .child(user.uid);

        final dayOffSnapshot = await ref.get();
        print("Veri çekildi mi? ${dayOffSnapshot.exists}");
        print("İzin Verisi: ${dayOffSnapshot.value}");
        if (dayOffSnapshot.exists) {
          final userData = dayOffSnapshot.value as Map<dynamic, dynamic>;

          if (userData.containsKey('dayOffRequests') &&
              userData['dayOffRequests'] is Map) {
            final dayOffRequests =
                userData['dayOffRequests'] as Map<dynamic, dynamic>;

            dayOffRequests.forEach((requestId, value) {
              if (value['checked'] == true) {
                oldRequestsOfUser.add({
                  "key": requestId,
                  "type": value["type"],
                  "start": formatDate(value["dayOffStart"]),
                  "finish": formatDate(value["dayOffEnd"]),
                  "userId": user.uid,
                  "name": userData['name'],
                  "status": value['status'],
                  "surname": userData['surname'],
                });
              }
            });
          } else {
            print("oldDayOffRequests alanı bulunamadı veya null");
          }
        }
      }
    }
    return oldRequestsOfUser;
  }

  Future<List<Map<dynamic, dynamic>>> fetchCurrentDayOff() async {
    final user = _firebaseAuth.currentUser;
    List<Map<dynamic, dynamic>> currentDayOff = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final usersSnapshot = await dbRef.child('users').get();

      String? department;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in usersData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;

            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }

      if (department != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Calisan');

        final calisanSnapshot = await ref.get();
        if (calisanSnapshot.exists) {
          final calisanUsers = calisanSnapshot.value as Map<dynamic, dynamic>;
          for (final userEntry in calisanUsers.entries) {
            final userId = userEntry.key;
            final userData = userEntry.value as Map<dynamic, dynamic>;

            if (userData.containsKey('dayOffRequests') &&
                userData['dayOffRequests'] is Map) {
              final requestsMap =
                  userData['dayOffRequests'] as Map<dynamic, dynamic>;

              requestsMap.forEach((requestId, value) {
                if (value['status'] == true) {
                  if (value['dayOffStart'] != null &&
                      value['dayOffEnd'] != null) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final startDate = DateTime.parse(value['dayOffStart']);
                    final start = DateTime(
                      startDate.year,
                      startDate.month,
                      startDate.day,
                    );
                    final endDate = DateTime.parse(value['dayOffEnd']);
                    final end = DateTime(
                      endDate.year,
                      endDate.month,
                      endDate.day,
                    );
                    print(start);
                    print(end);
                    print(today);
                    if ((start.isBefore(today) ||
                            start.isAtSameMomentAs(today)) &&
                        (end.isAfter(today) || end.isAtSameMomentAs(today))) {
                      currentDayOff.add({
                        "key": requestId,
                        "type": value["type"],
                        "start": formatDate(value["dayOffStart"]),
                        "finish": formatDate(value["dayOffEnd"]),
                        "userId": userId,
                        "department": department,
                        "name": userData['name'],
                        "surname": userData['surname'],
                        "checked": value["checked"],
                        "status": value["status"],
                      });
                    }
                  }
                }
              });
            }
          }
        }
      }
    }
    print("currentDayOff: $currentDayOff");
    return currentDayOff;
  }

  Future<List<Map<dynamic, dynamic>>> fetchCurrentDayOffUser() async {
    final user = _firebaseAuth.currentUser;
    List<Map<dynamic, dynamic>> currentDayOffUser = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final usersSnapshot = await dbRef.child('users').get();

      String? department;

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in usersData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statuses.entries) {
            final usersMap = statusEntry.value as Map<dynamic, dynamic>;

            for (final uidKey in usersMap.keys) {
              if (uidKey == user.uid) {
                department = departmentEntry.key;
                print("Kullanıcının departmanı: $department");
                print("Statü: ${statusEntry.key}");
                break;
              }
            }
            if (department != null) break;
          }
          if (department != null) break;
        }
      }

      if (department != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Calisan')
            .child(user.uid);

        final dayOffSnapshot = await ref.get();
        print("Veri çekildi mi? ${dayOffSnapshot.exists}");
        print("İzin Verisi: ${dayOffSnapshot.value}");
        if (dayOffSnapshot.exists) {
          final userData = dayOffSnapshot.value as Map<dynamic, dynamic>;

          if (userData.containsKey('dayOffRequests') &&
              userData['dayOffRequests'] is Map) {
            final dayOffRequests =
                userData['dayOffRequests'] as Map<dynamic, dynamic>;

            dayOffRequests.forEach((requestId, value) {
              if (value['status'] == true) {
                if (value['dayOffStart'] != null &&
                    value['dayOffEnd'] != null) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final startDate = DateTime.parse(value['dayOffStart']);
                  final start = DateTime(
                    startDate.year,
                    startDate.month,
                    startDate.day,
                  );
                  final endDate = DateTime.parse(value['dayOffEnd']);
                  final end = DateTime(
                    endDate.year,
                    endDate.month,
                    endDate.day,
                  );
                  print(start);
                  print(end);
                  print(today);
                  if ((start.isBefore(today) ||
                          start.isAtSameMomentAs(today)) &&
                      (end.isAfter(today) || end.isAtSameMomentAs(today))) {
                    currentDayOffUser.add({
                      "key": requestId,
                      "type": value["type"],
                      "start": formatDate(value["dayOffStart"]),
                      "finish": formatDate(value["dayOffEnd"]),
                      //"userId": userId,
                      "department": department,
                      "name": userData['name'],
                      "surname": userData['surname'],
                      "checked": value["checked"],
                      "status": value["status"],
                    });
                  }
                }
              }
              if (value['checked'] == false) {
                currentDayOffUser.add({
                  "key": requestId,
                  "type": value["type"],
                  "start": formatDate(value["dayOffStart"]),
                  "finish": formatDate(value["dayOffEnd"]),
                  "userId": user.uid,
                  "name": userData['name'],
                  "surname": userData['surname'],
                });
              }
            });
          } else {
            print("dayOffRequests alanı bulunamadı veya null");
          }
        }
      }
    }
    return currentDayOffUser;
  }

  Future<String?> getCurrentUserDepartment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Kullanıcı giriş yapmamış");
      return null;
    }

    final dbRef = FirebaseDatabase.instance.ref();
    final usersSnapshot = await dbRef.child('users').get();

    if (usersSnapshot.exists) {
      final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

      for (final departmentEntry in usersData.entries) {
        final department = departmentEntry.key;
        final statuses = departmentEntry.value as Map<dynamic, dynamic>;

        for (final statusEntry in statuses.entries) {
          final usersMap = statusEntry.value as Map<dynamic, dynamic>;

          for (final uidKey in usersMap.keys) {
            if (uidKey == user.uid) {
              print("Kullanıcı bulundu, departman: $department");
              return department;
            }
          }
        }
      }
    }

    print("Kullanıcı veritabanında bulunamadı.");
    return null;
  }

  Future<String?> getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Kullanıcı giriş yapmamış");
      return null;
    }

    final dbRef = FirebaseDatabase.instance.ref();
    final usersSnapshot = await dbRef.child('users').get();

    if (usersSnapshot.exists) {
      final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

      for (final departmentEntry in usersData.entries) {
        final statuses = departmentEntry.value as Map<dynamic, dynamic>;

        for (final statusEntry in statuses.entries) {
          final usersMap = statusEntry.value as Map<dynamic, dynamic>;

          for (final uidKey in usersMap.keys) {
            final useruid = uidKey.key;
            if (uidKey == user.uid) {
              print("Kullanıcı bulundu, useruid: $useruid");
              return useruid;
            }
          }
        }
      }
    }

    print("Kullanıcı veritabanında bulunamadı.");
    return null;
  }

  Future<String?> getCurrentUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Kullanıcı giriş yapmamış");
      return null;
    }

    final dbRef = FirebaseDatabase.instance.ref();
    final usersSnapshot = await dbRef.child('users').get();

    if (usersSnapshot.exists) {
      final usersData = usersSnapshot.value as Map<dynamic, dynamic>;

      for (final departmentEntry in usersData.entries) {
        final statuses = departmentEntry.value as Map<dynamic, dynamic>;

        for (final statusEntry in statuses.entries) {
          final status = statusEntry.key;
          final usersMap = statusEntry.value as Map<dynamic, dynamic>;

          for (final uidKey in usersMap.keys) {
            if (uidKey == user.uid) {
              print("Kullanıcı bulundu, status: $status");
              return status;
            }
          }
        }
      }
    }

    print("Kullanıcı veritabanında bulunamadı.");
    return null;
  }

  bool canRequestPermission(DateTime startDate) {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;

    return difference >= 180;
  }

  List<Map<dynamic, dynamic>> filterUsersByQuery(
    List<Map<dynamic, dynamic>> allUsers,
    String query,
  ) {
    final sanitizedQuery = query.toLowerCase();
    return allUsers.where((user) {
      final name = (user['name'] ?? '').toLowerCase();
      final surname = (user['surname'] ?? '').toLowerCase();
      return name.contains(sanitizedQuery) || surname.contains(sanitizedQuery);
    }).toList();
  }

  Future<List<Map<dynamic, dynamic>>> getAllEmployeeList({
    String? department,
  }) async {
    final database = FirebaseDatabase.instance.ref();
    List<Map<dynamic, dynamic>> allEmployeeList = [];

    final departmentSnapshot = await database.child('users').get();

    if (departmentSnapshot.exists) {
      for (var deparment in departmentSnapshot.children) {
        final departmentName = deparment.key!;
        print('Tespit edilen departman: $departmentName');
        print('Seçilen departman: $department');

        // Eğer "Seçilmedi" değilse ve sanitize edilmiş hali eşleşmiyorsa continue
        if (department != null &&
            department != "Seçilmedi" &&
            sanitizeDepartment(department) != departmentName) {
          continue;
        }

        for (String role in ['Yonetici', 'Calisan']) {
          final roleSnapshot =
              await database
                  .child('users')
                  .child(departmentName)
                  .child(role)
                  .get();

          if (roleSnapshot.exists) {
            for (var child in roleSnapshot.children) {
              allEmployeeList.add({
                'uid': child.key,
                ...Map<String, dynamic>.from(child.value as Map),
                'role': role,
                'department': departmentName,
              });
            }
          }
        }
      }
    }
    return allEmployeeList;
  }
}
