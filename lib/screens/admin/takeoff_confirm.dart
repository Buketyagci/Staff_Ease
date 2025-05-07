import 'package:flutter/material.dart';
import 'package:staff_ease/services/auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';
//import 'package:staff_ease/widgets/message.dart';

class TakeOffConfirmScreen extends StatefulWidget {
  const TakeOffConfirmScreen({super.key});

  @override
  State<TakeOffConfirmScreen> createState() => _TakeOffConfirmScreenState();
}

class _TakeOffConfirmScreenState extends State<TakeOffConfirmScreen> {
  //List<Map<String, dynamic>> _uncheckedRequests = [];
  bool isLoading = true;
  final Auth _dayOffRequests = Auth();
  final Auth _currentDayOff = Auth();

  final Auth confirm = Auth();

  @override
  void initState() {
    super.initState();
    //_loadDayOffRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "İzin Onay", "")),
      drawer: menuBarAdmin(context),
      body: SingleChildScrollView(
        child: Center(
          child: Column(children: [waitingRequests(), currentRequests()]),
        ),
      ),
    );
  }

  Widget waitingRequests() {
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
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Onay Bekleyen İzinler",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: _dayOffRequests.fetchDayOffRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Hata: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Onay bekleyen talep yok."));
                      }

                      final requests = snapshot.data!;
                      return SizedBox(
                        height: 340,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final item = requests[index];
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
                                    Text(
                                      '${item['name']} ${item['surname']}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${item["start"]} → ${item["finish"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Tür: ${item["type"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            try {
                                              print(
                                                "Department: ${item['department']}",
                                              );
                                              print(
                                                "UserID: ${item['userId']}",
                                              );
                                              print(
                                                "MessageID: ${item['key']}",
                                              );
                                              await confirm
                                                  .approveDayOffRequest(
                                                    department:
                                                        item['department'],
                                                    uid: item['userId'],
                                                    requestId: item['key'],
                                                  );
                                              setState(() {});
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Talep onaylandı ve izin gün sayısı güncellendi',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              print("Onaylama hatası: $e");
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Onaylama hatası: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            confirm.cancelDayOffRequest(
                                              department: item['department'],
                                              uid: item['userId'],
                                              requestId: item['key'],
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 28,
                                          ),
                                        ),
                                      ],
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

  Widget currentRequests() {
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
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Güncel İzinler",
                    style: GoogleFonts.josefinSans(fontSize: 24),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<dynamic, dynamic>>>(
                    future: _currentDayOff.fetchCurrentDayOff(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        print("hata: ${snapshot.error}");
                        return Center(child: Text("Hataa: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("İzinli çalışan yok."));
                      }

                      final currentDayOff = snapshot.data!;
                      return SizedBox(
                        height: 340,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: currentDayOff.length,
                          itemBuilder: (context, index) {
                            final item = currentDayOff[index];
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
                                    Text(
                                      '${item['name']} ${item['surname']}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '${item["start"]} → ${item["finish"]}',
                                      style: GoogleFonts.josefinSans(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Tür: ${item["type"]}',
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
