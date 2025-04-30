class EmployeeModel {
  final String name;
  final String surname;
  final String email;
  final String status;
  final String department;
  final String startDate;
  final String birthday;

  EmployeeModel({
    required this.name,
    required this.surname,
    required this.email,
    required this.status,
    required this.department,
    required this.startDate,
    required this.birthday,
  });

  factory EmployeeModel.fromMap(Map<dynamic, dynamic> map) {
    return EmployeeModel(
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? '',
      department: map['department'] ?? '',
      startDate: map['startDate'] ?? '',
      birthday: map['birthday'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'status': status,
      'department': department,
      'startDate': startDate,
      'birthday': birthday,
    };
  }
}
