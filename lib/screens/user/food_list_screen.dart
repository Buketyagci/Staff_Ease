import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/widgets/user_widgets/appbar_user.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  List<dynamic> gunlukMenu = [];

  @override
  void initState() {
    super.initState();
    loadMenuData();
  }

  Future<void> loadMenuData() async {
    try {
      final String response = await rootBundle.loadString('assets/menu.json');
      final Map<String, dynamic> data = json.decode(response);

      setState(() {
        gunlukMenu = data['gunluk_menu'];
      });
    } catch (e) {
      print("hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "Yemek Listesi")),
      drawer: menuBarUser(context),
      body:
          gunlukMenu.isEmpty
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 3,
                ),
                itemCount: gunlukMenu.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> menu = gunlukMenu[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 50),
                        Text(
                          '${index + 1})',
                          style: GoogleFonts.josefinSans(fontSize: 24),
                        ),
                        SizedBox(width: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Çorba: ${menu['corba']}",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "Ana Yemek: ${menu['ana_yemek']}",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "Karbonhidrat: ${menu['karbonhidrat']}",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "Yan Ürün: ${menu['yanci']}",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
