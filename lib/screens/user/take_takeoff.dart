import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:staff_ease/widgets/user_widgets/appbar_user.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';
import 'package:table_calendar/table_calendar.dart';

class TakeTakeoffScreen extends StatefulWidget {
  const TakeTakeoffScreen({super.key});

  @override
  State<TakeTakeoffScreen> createState() => _TakeTakeoffScreenState();
}

class _TakeTakeoffScreenState extends State<TakeTakeoffScreen> {
  int dayOff = 0;
  int sickList = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedStartDay;
  DateTime? _selectedFinishDay;
  List<String> dayOffType = ['İzin', 'Raporlu', 'Seçilmedi'];
  String? _selectedType;
  final Auth _dayOffRequests = Auth();
  final Auth _oldDayOffRequests = Auth();
  final Auth _currentDayOffUser = Auth();

  TextEditingController dayOffStartController = TextEditingController();
  TextEditingController dayOffEndController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDayOffCount();
  }

  Future<void> _loadDayOffCount() async {
    int count = await Auth().getDayOffCount();
    setState(() {
      dayOff = count;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "İzin Talep")),
      drawer: menuBarUser(context),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              dayOffContainer(),
              dayOffRequestCreate(),
              myDayOffRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget dayOffContainer() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        width: 400,
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Kalan izin hakkı: ${dayOff}",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(width: 10),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                              child: Text(
                                "Kullanılan izin: ",
                                style: GoogleFonts.josefinSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Card(
                              child: Text(
                                "${15 - dayOff}",
                                style: GoogleFonts.josefinSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24.0,
                              ),
                              child: Text(
                                "Kullanılan raporlu izin: ",
                                style: GoogleFonts.josefinSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Card(
                              child: Text(
                                "$sickList",
                                style: GoogleFonts.josefinSans(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dayOffRequestCreate() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        width: 400,
        height: 1100,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "İzin Talebi Oluştur",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(width: 10),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                "İzin Başlangıç Tarihi Seçin",
                                style: GoogleFonts.josefinSans(fontSize: 24),
                              ),
                            ),
                            TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay: DateTime.now(),
                              lastDay: DateTime.utc(2025, 12, 31),
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedStartDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedStartDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              calendarStyle: CalendarStyle(
                                isTodayHighlighted: false,
                                selectedDecoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Colors.deepPurple.shade100,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                "İzin Bitiş Tarihi Seçin",
                                style: GoogleFonts.josefinSans(fontSize: 24),
                              ),
                            ),
                            TableCalendar(
                              focusedDay: _focusedDay,
                              firstDay: DateTime.now(),
                              lastDay: DateTime.utc(2025, 12, 31),
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedFinishDay, day);
                              },
                              onDaySelected: (selectedFinishDay, focusedDay) {
                                setState(() {
                                  _selectedFinishDay = selectedFinishDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              calendarStyle: CalendarStyle(
                                isTodayHighlighted: false,
                                selectedDecoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Colors.deepPurple.shade100,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
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
                    value: _selectedType ?? 'Seçilmedi',
                    items:
                        dayOffType.map((String value) {
                          return DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                        typeController.text = newValue ?? "";
                      });
                      _selectedType == "Raporlu"
                          ? _showMessage("Yöneticinize raporunuzu gönderiniz")
                          : null;
                    },
                    iconSize: 24,
                    hint: Text("Cinsiyet seçin"),
                    underline: Container(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: createTakeOff(),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton createTakeOff() {
    return ElevatedButton(
      onPressed: () async {
        String dayOffStart = _selectedStartDay?.toIso8601String() ?? "";
        String dayOffEnd = _selectedFinishDay?.toIso8601String() ?? "";
        String type = _selectedType ?? "";

        try {
          if (dayOffEnd.isEmpty || dayOffStart.isEmpty || type.isEmpty) {
            _showMessage("Lütfen tüm alanları doldurun");
            return;
          }
          if (dayOff == 0) {
            _showMessage("İzin hakkınız bulunmamaktadır");
            return;
          }

          bool success = await Auth().createDayOffRequest(
            dayOffStart: dayOffStart,
            dayOffEnd: dayOffEnd,
            type: type,
          );
          if (success) {
            _selectedStartDay = null;
            _selectedFinishDay = null;
            _selectedType = null;
            _showMessage("İzin talebiniz başarıyla oluşturuldu");
          }
        } catch (e) {
          _showMessage("Hata: $e");
        }
      },

      child: Text("Talep Oluştur"),
    );
  }

  Widget myDayOffRequests() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(255, 157, 155, 161),
            width: 2,
          ),
        ),
        width: 400,
        height: 1400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "İzin Taleplerim",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Onay Bekleyen İzinler",
                    style: GoogleFonts.josefinSans(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: _dayOffRequests.fetchDayOffRequestsOfUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Onay bekleyen talep yok."));
                      }

                      final requestsOfUsers = snapshot.data!;
                      return SizedBox(
                        height: 360,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: requestsOfUsers.length,
                          itemBuilder: (context, index) {
                            final dayOff = requestsOfUsers[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    241,
                                    235,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepPurple.shade400,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dayOff["start"]} → ${dayOff["finish"]}',
                                          style: GoogleFonts.josefinSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.hourglass_top,
                                          color: const Color.fromARGB(
                                            255,
                                            154,
                                            85,
                                            233,
                                          ),
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Tür: ${dayOff["type"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Güncel İzinler",
                    style: GoogleFonts.josefinSans(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: _currentDayOffUser.fetchCurrentDayOffUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Güncel izin yok."));
                      }

                      final currentDayOffUser = snapshot.data!;
                      return SizedBox(
                        height: 360,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: currentDayOffUser.length,
                          itemBuilder: (context, index) {
                            final dayOff = currentDayOffUser[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    241,
                                    235,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepPurple.shade400,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dayOff["start"]} → ${dayOff["finish"]}',
                                          style: GoogleFonts.josefinSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.hourglass_top,
                                          color: const Color.fromARGB(
                                            255,
                                            154,
                                            85,
                                            233,
                                          ),
                                          size: 28,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Tür: ${dayOff["type"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Geçmiş İzin Talepleri",
                    style: GoogleFonts.josefinSans(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: _oldDayOffRequests.fetchOldDayOffRequestsOfUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Geçmiş talep yok."));
                      }

                      final oldRequestsOfUsers = snapshot.data!;
                      return SizedBox(
                        height: 360,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: oldRequestsOfUsers.length,
                          itemBuilder: (context, index) {
                            final dayOff = oldRequestsOfUsers[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    241,
                                    235,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepPurple.shade400,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${dayOff["start"]} → ${dayOff["finish"]}',
                                          style: GoogleFonts.josefinSans(
                                            fontSize: 16,
                                          ),
                                        ),
                                        dayOff["status"] == true
                                            ? Icon(
                                              Icons.check_box,
                                              size: 24,
                                              color: Colors.green,
                                            )
                                            : Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                      ],
                                    ),
                                    Text(
                                      'Tür: ${dayOff["type"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
          ],
        ),
      ),
    );
  }
}
