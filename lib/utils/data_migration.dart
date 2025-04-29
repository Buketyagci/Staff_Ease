import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> migrateUsersToRealtimeDatabase() async {
  final firestore = FirebaseFirestore.instance;
  final realtime = FirebaseDatabase.instance.ref();

  try {
    final usersSnapshot = await firestore.collection("users").get();

    for (final doc in usersSnapshot.docs) {
      final userData = doc.data();

      // Departmanı al ve sanitize et
      final rawDepartment = userData["department"] ?? "Genel";
      final sanitizedDepartment = sanitizeDepartment(rawDepartment);

      // Timestamp türlerini dönüştür
      final convertedData = userData.map((key, value) {
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
        return MapEntry(key, value);
      });

      // Realtime'a şu formatta yaz: users/{departman}/{userId}
      await realtime
          .child("users/$sanitizedDepartment/${doc.id}")
          .set(convertedData);

      print("Aktarıldı: $sanitizedDepartment/${doc.id}");
    }

    print("Tüm kullanıcılar departmanlara göre Realtime Database'e aktarıldı.");
  } catch (e) {
    print("Hata oluştu: $e");
  }
}

String sanitizeDepartment(String department) {
  return department
      .replaceAll("İ", "I")
      .replaceAll("ı", "i")
      .replaceAll("ğ", "g")
      .replaceAll("ü", "u")
      .replaceAll("ş", "s")
      .replaceAll("ö", "o")
      .replaceAll("ç", "c")
      .replaceAll(" ", "_");
}

String sanitizeStatus(String status) {
  return status
      .replaceAll("İ", "I")
      .replaceAll("Ç", "C")
      .replaceAll("ı", "i")
      .replaceAll("ğ", "g")
      .replaceAll("ü", "u")
      .replaceAll("ş", "s")
      .replaceAll("ö", "o")
      .replaceAll("ç", "c")
      .replaceAll(" ", "_");
}
