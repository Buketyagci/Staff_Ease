import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class RefreshEmployee extends StatefulWidget {
  const RefreshEmployee({super.key});

  @override
  State<RefreshEmployee> createState() => _RefreshEmployeeState();
}

class _RefreshEmployeeState extends State<RefreshEmployee> {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Çalışan Görüntüle", name)),
      drawer: menuBarAdmin(context),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            title("Ad"),
            employeeName(),
            title("Soyad"),
            employeeName(),
            title("Email"),
            employeeName(),
            title("Departman"),
            employeeName(),
            title("Statü"),
            employeeName(),
          ],
        ),
      ),
    );
  }

  Widget title(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("$title", style: GoogleFonts.josefinSans(fontSize: 24)),
    );
  }

  Widget employeeName() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),

      margin: EdgeInsets.all(12),
      height: 50,
      width: 250,
      child: Text("$name"),
    );
  }
}
