import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:staff_ease/utils/data_migration.dart';
import 'package:staff_ease/widgets/message.dart';

class NotificateManager {
  Message msg = Message();
  Future<bool> sendNotificationToManager({
    required String title,
    required String message,
  }) async {
    String department = "";
    String status = "";
    bool checked = false;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null)
      throw Exception("Giriş yapan kullanıcı bulunamadı");

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
              break;
            }
          }
          if (department.isNotEmpty) break;
        }
      }
      if (department.isEmpty) {
        print("Kullanıcının departmanı bulunamadı.");
      }
    } catch (e) {
      print("Departman aranırken hata oluştu: $e");
    }

    try {
      String messageId =
          FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child(status)
              .child(uid)
              .child('messages')
              .push()
              .key ??
          '';

      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(department)
          .child(status)
          .child(uid)
          .child('messages')
          .child(messageId)
          .set({
            'title': title,
            'message': message,
            'createdAt': ServerValue.timestamp,
            'checked': checked,
          });

      print("Mesaj başarıyla kaydedildi.");
      return true;
    } catch (e) {
      print("Mesaj kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  Future<bool> sendNotificationToEmployee({
    required String title,
    required String message,
  }) async {
    String department = "";
    bool checked = false;
    String status = "";

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null)
      throw Exception("Giriş yapan kullanıcı bulunamadı");

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

              break;
            }
          }
          if (department.isNotEmpty) break;
        }
      }
      if (department.isEmpty) {
        print("Kullanıcının departmanı bulunamadı.");
      }
    } catch (e) {
      print("Departman aranırken hata oluştu: $e");
    }

    try {
      String messageId =
          FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Calisan')
              .child(uid)
              .child('messagesFromManager')
              .push()
              .key ??
          '';
      final ref = FirebaseDatabase.instance.ref();
      final snapshot =
          await ref.child('users').child(department).child('Calisan').get();
      if (snapshot.exists) {
        final usersMap = snapshot.value as Map<dynamic, dynamic>;
        for (var uid in usersMap.keys)
          await FirebaseDatabase.instance
              .ref()
              .child('users')
              .child(department)
              .child('Calisan')
              .child(uid)
              .child('messagesFromManager')
              .child(messageId)
              .set({
                'checked': checked,
                'title': title,
                'message': message,
                'createdAt': ServerValue.timestamp,
              });

        await FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(department)
            .child('Yonetici')
            .child(uid)
            .child('createdMessages')
            .child(messageId)
            .set({
              'title': title,
              'message': message,
              'createdAt': ServerValue.timestamp,
            });
      }

      print("Mesaj başarıyla kaydedildi.");
      return true;
    } catch (e) {
      print("Mesaj kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  Future<List<Map<dynamic, dynamic>>> fetchMessagesManager() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<dynamic, dynamic>> messages = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child('users').get();

      String? department;

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in userData.entries) {
          final statues = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statues.entries) {
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
        final ref = dbRef.child('users').child(department).child('Calisan');

        final employeeSnapshot = await ref.get();
        print("veri çekildi mi: ${employeeSnapshot.exists}");
        print("calisan verisi: ${employeeSnapshot.value}");
        if (employeeSnapshot.exists) {
          final employeeUsers = employeeSnapshot.value as Map<dynamic, dynamic>;
          for (final userEntry in employeeUsers.entries) {
            final userId = userEntry.key;
            final userData = userEntry.value as Map<dynamic, dynamic>;

            if (userData.containsKey('messages') &&
                userData['messages'] is Map) {
              final messagesMap = userData['messages'] as Map<dynamic, dynamic>;
              messagesMap.forEach((messageId, value) {
                if (value['checked'] == false) {
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
    return messages;
  }

  Future<List<Map<dynamic, dynamic>>> fetchMessagesEmployee() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<dynamic, dynamic>> messages = [];

    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child('users').get();

      String? department;

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        for (final departmentEntry in userData.entries) {
          final statues = departmentEntry.value as Map<dynamic, dynamic>;

          for (final statusEntry in statues.entries) {
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
        final ref = dbRef
            .child('users')
            .child(department)
            .child('Calisan')
            .child(user.uid);

        final employeeSnapshot = await ref.get();
        print("veri çekildi mi: ${employeeSnapshot.exists}");
        print("calisan verisi: ${employeeSnapshot.value}");
        if (employeeSnapshot.exists) {
          final employeeData = employeeSnapshot.value as Map<dynamic, dynamic>;

          if (employeeData.containsKey('messagesFromManager') &&
              employeeData['messagesFromManager'] is Map) {
            final messagesMap =
                employeeData['messagesFromManager'] as Map<dynamic, dynamic>;
            messagesMap.forEach((messageId, value) {
              if (value['checked'] == false) {
                messages.add({
                  'key': messageId,
                  'userId': user.uid,
                  'name': employeeData['name'],
                  'surname': employeeData['surname'],
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
    return messages;
  }

  Future<List<Map<dynamic, dynamic>>> fetchOldMessagesEmployee() async {
    final user = FirebaseAuth.instance.currentUser;
    List<Map<dynamic, dynamic>> oldMessagesEmp = [];
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child('users').get();
      String? department;
      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        for (final departmentEntry in userData.entries) {
          final statuses = departmentEntry.value as Map<dynamic, dynamic>;
          for (final statusEntry in statuses.entries) {
            final userMap = statusEntry.value as Map<dynamic, dynamic>;
            for (final uidKey in userMap.keys) {
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
            .child('Calisan')
            .child(user.uid);

        final oldMessageSnapshot = await ref.get();
        if (oldMessageSnapshot.exists) {
          final userData = oldMessageSnapshot.value as Map<dynamic, dynamic>;
          if (userData.containsKey('messages') && userData['messages'] is Map) {
            final oldMessages = userData['messages'] as Map<dynamic, dynamic>;
            oldMessages.forEach((messageId, value) {
              oldMessagesEmp.add({
                "createdAt": value['createdAt'],
                "key": messageId,
                "title": value['title'],
                "message": value['message'],
              });
            });
            oldMessagesEmp.sort((a, b) {
              final aTime = a['createdAt'] ?? 0;
              final bTime = b['createdAt'] ?? 0;
              return (bTime as int).compareTo(aTime as int);
            });
          }
        }
      }
    }
    return oldMessagesEmp;
  }

  Future<void> deleteMessageManager({
    required String department,
    required String uid,
    required String messageId,
  }) async {
    try {
      department = sanitizeDepartment(department);
      print("delete fonksiyonu çalıştı");
      print("department auth: $department");
      print("uid auth: $uid");
      print("messageid auth: $messageId");
      final messageRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(department)
          .child('Calisan')
          .child(uid)
          .child('messages')
          .child(messageId);

      final messageSnapshot = await messageRef.get();
      if (messageSnapshot.exists) {
        await messageRef.update({'checked': true});
        msg.showMessage("İleti başarıyla silindi");
      } else {
        print("veri yok: ${messageSnapshot.value}");
        throw Exception("mesaj verisi bulunamadı");
      }
    } catch (e) {
      print("deletemsg hatası: $e");
      rethrow;
    }
  }

  Future<void> deleteMessageFromManager({
    required String department,
    required String uid,
    required String messageId,
  }) async {
    try {
      department = sanitizeDepartment(department);
      final messageRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(department)
          .child('Calisan')
          .child(uid)
          .child('messagesFromManager')
          .child(messageId);

      final messageSnapshot = await messageRef.get();
      if (messageSnapshot.exists) {
        await messageRef.update({'checked': true});
        msg.showMessage("İleti başarıyla silindi");
      } else {
        print("veri yok: ${messageSnapshot.value}");
        throw Exception("mesaj verisi bulunamadı");
      }
    } catch (e) {
      print("deletemsg hatası: $e");
      rethrow;
    }
  }

  Future<String?> getCurrentDepartment(String uid) async {
    final ref = FirebaseDatabase.instance.ref().child('users');
    final snapshot = await ref.get();
    print("çalıştı");
    if (snapshot.exists) {
      final departments = snapshot.value as Map<dynamic, dynamic>;
      print(departments);

      for (final deptEntry in departments.entries) {
        final deptName = deptEntry.key;
        final statuses = deptEntry.value as Map<dynamic, dynamic>;

        for (final statusEntry in statuses.entries) {
          final users = statusEntry.value as Map<dynamic, dynamic>;

          if (users.containsKey(uid)) {
            return deptName;
          }
        }
      }
    }
    return null;
  }

  Future<void> deleteMessageEmployee({
    required String messageId,
    required String department,
    required String uid,
  }) async {
    try {
      department = sanitizeDepartment(department);
      print("delete fonksiyonu çalıştı");
      print("department auth: $department");
      print("uid auth: $uid");
      print("messageid auth: $messageId");
      final messageRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(department)
          .child('Calisan')
          .child(uid)
          .child('messages')
          .child(messageId);

      final messageSnapshot = await messageRef.get();
      if (messageSnapshot.exists) {
        await messageRef.remove();
        msg.showMessage("İleti başarıyla silindi");
      } else {
        print("veri yok: ${messageSnapshot.value}");
        throw Exception("mesaj verisi bulunamadı");
      }
    } catch (e) {
      print("deletemsg hatası: $e");
      rethrow;
    }
  }
}
