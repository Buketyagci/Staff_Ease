import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificateManager {
  Future<bool> sendNotificationToManager({
    required String title,
    required String message,
  }) async {
    String department = "";
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
          });

      print("Mesaj başarıyla kaydedildi.");
      return true;
    } catch (e) {
      print("Mesaj kaydedilirken hata oluştu: $e");
      return false;
    }
  }

  Future<List<Map<dynamic, dynamic>>> fetchMessages() async {
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

        if (employeeSnapshot.exists) {
          final employeeUsers = employeeSnapshot.value as Map<dynamic, dynamic>;
          for (final userEntry in employeeUsers.entries) {
            final userId = userEntry.key;
            final userData = userEntry.value as Map<dynamic, dynamic>;

            if (userData.containsKey('messages') &&
                userData['messages'] is Map) {
              final messagesMap = userData['messages'] as Map<dynamic, dynamic>;
              messagesMap.forEach((messageId, value) {
                messages.add({
                  'key': messageId,
                  'name': userData['name'],
                  'surname': userData['surname'],
                  'title': value['title'],
                  'message': value['message'],
                });
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
}
