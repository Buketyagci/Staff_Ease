import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/model/employee_model.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class EmployeeDetail extends StatefulWidget {
  final EmployeeModel employee;
  const EmployeeDetail({super.key, required this.employee});

  @override
  State<EmployeeDetail> createState() => _EmployeeDetailState();
}

class _EmployeeDetailState extends State<EmployeeDetail> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController surnameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController statusController = TextEditingController();
  late TextEditingController departmentController = TextEditingController();
  late TextEditingController birthdayController = TextEditingController();
  late TextEditingController startDateController = TextEditingController();
  String name = "";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee.name);
    surnameController = TextEditingController(text: widget.employee.surname);
    emailController = TextEditingController(text: widget.employee.email);
    statusController = TextEditingController(text: widget.employee.status);
    departmentController = TextEditingController(
      text: widget.employee.department,
    );
    birthdayController = TextEditingController(text: widget.employee.birthday);
    startDateController = TextEditingController(
      text: widget.employee.startDate,
    );
  }

  String formatDepartmentName(String department) {
    return department
        .replaceAll("_", " ")
        .split(" ")
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(" ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Çalışan Görüntüle", name)),
      drawer: menuBarAdmin(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //SizedBox(height: 50),
              Row(
                children: [
                  SizedBox(height: 10),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back, size: 36),
                  ),
                ],
              ),
              title("Ad"),
              employeeDetail(nameController),
              title("Soyad"),
              employeeDetail(surnameController),
              title("Email"),
              employeeDetail(emailController),
              title("Departman"),
              employeeDepartment(
                formatDepartmentName(departmentController.text),
              ),
              title("Statü"),
              employeeDetail(statusController),
              title("İşe Başlama Tarihi"),
              employeeDetail(startDateController),
              title("Doğum Tarihi"),
              employeeDetail(birthdayController),
            ],
          ),
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

  Widget employeeDetail(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      margin: EdgeInsets.all(12),
      height: 50,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.text, style: GoogleFonts.josefinSans(fontSize: 24)),
        ],
      ),
    );
  }

  Widget employeeDepartment(String value) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 1.5),
    ),
    margin: EdgeInsets.all(12),
    height: 50,
    width: 250,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(value, style: GoogleFonts.josefinSans(fontSize: 24))],
    ),
  );
}
