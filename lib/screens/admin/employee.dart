import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/model/employee_model.dart';
import 'package:staff_ease/screens/admin/employee_detail.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:staff_ease/utils/data_migration.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  String name = "";

  TextEditingController searchTextCont = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  List<EmployeeModel> allUsers = [];
  List<EmployeeModel> filteredUsers = [];
  Auth auth = Auth();
  String? _selectedDepartment;
  final List<String> departments = [
    'Seçilmedi',
    'Bilgi İşlem',
    'İnsan Kaynakları',
    'Muhasebe',
    'İdari İşler',
    'Yönetim',
    'Pazarlama',
    'Satış',
    'Kalite Kontrol',
    'Lojistik',
    'Satın Alma',
    'Planlama',
    'Ar-Ge',
    'Makine',
    'Bakım Teknik',
    'Müşteri Hizmetleri',
    'İhracat-İthalat',
    'Sağlık ve Güvenlik',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Çalışanlar", name)),
      drawer: menuBarAdmin(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  selectDepartment(),
                  Column(children: [SizedBox(height: 18), searchText()]),
                ],
              ),
              employeeList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget employeeList() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 400,
        height: 600,
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
              FutureBuilder<List<Map<dynamic, dynamic>>>(
                future: auth.getAllEmployeeList(
                  department:
                      (_selectedDepartment != null &&
                              _selectedDepartment != 'Seçilmedi')
                          ? sanitizeDepartment(_selectedDepartment!)
                          : null,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("hata: ${snapshot.error}");
                    return Center(child: Text("Hataa: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Bu departmana ait çalışan yok.",
                        style: GoogleFonts.josefinSans(fontSize: 28),
                      ),
                    );
                  }

                  final employees = snapshot.data!;
                  if (allUsers.isEmpty) {
                    allUsers =
                        employees.map((e) => EmployeeModel.fromMap(e)).toList();
                    filteredUsers = List.from(allUsers);
                  }
                  return SizedBox(
                    height: 550,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final item = filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EmployeeDetail(employee: item),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 227, 246, 236),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color.fromARGB(
                                    255,
                                    152,
                                    192,
                                    171,
                                  ),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.name} ${item.surname}',
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            52,
                                            48,
                                            58,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${item.status}',
                                        style: GoogleFonts.josefinSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            52,
                                            48,
                                            58,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
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
      ),
    );
  }

  Widget searchText() {
    return Container(
      margin: EdgeInsets.all(12),
      height: 70,
      width: 180,
      child: TextField(
        onChanged: (value) {
          if (value.isNotEmpty) {
            final results = auth.filterUsersByQuery(allUsers, value);
            print("allusers: $allUsers");
            print("filteredresult: $results");
            setState(() {
              filteredUsers = results;
            });
          } else {
            setState(() {
              filteredUsers = allUsers;
            });
          }
        },
        cursorWidth: 3,
        controller: searchTextCont,
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Anahtar kelime",
          hintText: "Anahtar kelime",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        maxLength: 30,
      ),
    );
  }

  Widget selectDepartment() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      width: 180,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDepartment ?? 'Seçilmedi',
          items:
              departments.map((String value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDepartment = newValue;
              departmentController.text = newValue ?? "";
            });
          },
          iconSize: 24,
          hint: Text("Kullanıcı departmanı seçin"),
          underline: Container(),
        ),
      ),
    );
  }
}
