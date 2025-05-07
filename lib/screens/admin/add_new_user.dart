import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class AddNewUserScreen extends StatefulWidget {
  const AddNewUserScreen({super.key});

  @override
  State<AddNewUserScreen> createState() => _AddNewUserScreen();
}

class _AddNewUserScreen extends State<AddNewUserScreen> {
  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedDepartment;

  final List<String> genders = ['Erkek', 'Kadın', 'Seçilmedi'];
  final List<String> status = ['Yönetici', 'Çalışan', 'Seçilmedi'];
  final List<String> department = [
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
  String? errorMessage;
  String name = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController departmentController = TextEditingController();

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

  final _dateFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    String newText = newValue.text;

    if (newText.length == 2 || newText.length == 5) {
      newText += "-";
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  });

  final _dateFormatRegex = RegExp(
    r"^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-\d{4}$",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Yeni Çalışan Ekle", name)),
      drawer: menuBarAdmin(context),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              textFields("İsim", "İsim giriniz", false, 400, nameController),
              textFields(
                "Soyisim",
                "Soyisim giriniz",
                false,
                400,
                surnameController,
              ),
              textFields(
                "E-posta",
                "E-posta giriniz",
                false,
                400,
                emailController,
              ),
              textFields(
                "Telefon Numarası",
                "Telefon Numarası giriniz",
                false,
                400,
                phoneController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropDownStatus(),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  //   child: Container(
                  //     height: 60,
                  //     width: 180,
                  //     child: textFields(
                  //       "Yaş",
                  SizedBox(width: 14),
                  dropDownGenderContainer(),
                ],
              ),
              dateTextField("Doğum tarihi (GG-AA-YYYY)", birthdayController),
              dateTextField(
                "İşe giriş tarihi (GG-AA-YYYY)",
                startDateController,
              ),
              dropDownDepartment(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: textFields(
                  "Şifre",
                  "Şifre giriniz",
                  true,
                  400,
                  passwordController,
                ),
              ),
              errorMessage != null ? Text(errorMessage!) : SizedBox.shrink(),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        String name = nameController.text;
        String surname = surnameController.text;
        String email = emailController.text;
        String phone = phoneController.text;
        String password = passwordController.text;
        String birthday = birthdayController.text;
        String startDate = startDateController.text;
        String status = statusController.text;
        String gender = genderController.text;

        if (name.isEmpty ||
            surname.isEmpty ||
            email.isEmpty ||
            phone.isEmpty ||
            password.isEmpty ||
            birthday.isEmpty ||
            startDate.isEmpty ||
            status.isEmpty ||
            gender.isEmpty) {
          _showMessage("Lütfen tüm alanları doldurun");
          return;
        }
        try {
          await Auth().createUser(
            name: nameController.text,
            surname: surnameController.text,
            email: emailController.text,
            phone: phoneController.text,
            gender: genderController.text,
            status: statusController.text,
            birthday: birthdayController.text,
            startDate: startDateController.text,
            password: passwordController.text,
            department: departmentController.text,
          );
          _showMessage("Kullanıcı başarıyla kaydedildi");
        } catch (e) {
          _showMessage("Hata: $e");
        }
      },
      child: Text("Kaydet"),
    );
  }

  Widget dateTextField(String labelt, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: 400,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelt,
            hintText: 'GG-AA-YYYY',
            border: OutlineInputBorder(),
            errorText:
                controller.text.isNotEmpty &&
                        !_dateFormatRegex.hasMatch(controller.text)
                    ? 'Geçersiz tarih formatı'
                    : null,
          ),

          keyboardType: TextInputType.number,
          inputFormatters: [_dateFormatter],
          //onChanged: _onDateChanged,
        ),
      ),
    );
  }

  Widget dropDownGenderContainer() {
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
          value: _selectedGender ?? 'Seçilmedi',
          items:
              genders.map((String value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
              genderController.text = newValue ?? "";
            });
          },
          iconSize: 24,
          hint: Text("Cinsiyet seçin"),
          underline: Container(),
        ),
      ),
    );
  }

  Widget textFields(
    String label,
    String hint,
    bool visible,
    double wdth,
    TextEditingController controller,
  ) {
    return Container(
      width: wdth,
      child: TextField(
        controller: controller,
        cursorWidth: 3,
        obscureText: visible,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          hintText: hint,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        maxLength: 30,
      ),
    );
  }

  Widget dropDownStatus() {
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
          value: _selectedStatus ?? 'Seçilmedi',
          items:
              status.map((String value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedStatus = newValue;
              statusController.text = newValue ?? "";
            });
          },
          iconSize: 24,
          hint: Text("Kullanıcı niteliği seçin"),
          underline: Container(),
        ),
      ),
    );
  }

  Widget dropDownDepartment() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDepartment ?? 'Seçilmedi',
          items:
              department.map((String value) {
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
