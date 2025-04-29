import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/main.dart';
import 'package:staff_ease/screens/user/bus_list.dart';
import 'package:staff_ease/screens/user/food_list_screen.dart';
import 'package:staff_ease/screens/user/take_takeoff.dart';
import 'package:staff_ease/screens/user/user_home.dart';
import 'package:staff_ease/screens/user/user_notification_screen.dart';
import 'package:staff_ease/screens/user/user_settings.dart';
import 'package:staff_ease/services/auth.dart';

Widget menuBarUser(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.deepPurple.shade100),
          child: Text(
            "Menü",
            style: GoogleFonts.josefinSans(fontSize: 24, color: Colors.white),
          ),
        ),
        menuItem(context, "Ana Sayfa", UserHome(), Icons.home),
        menuItem(
          context,
          "Bildirimler",
          UserNotificationScreen(),
          Icons.notifications,
        ),
        menuItem(context, "Yemek Listesi", FoodListScreen(), Icons.table_chart),
        menuItem(context, "Servis Listesi", BusListScreen(), Icons.list),
        menuItem(
          context,
          "İzin Talep",
          TakeTakeoffScreen(),
          Icons.check_circle,
        ),
        menuItem(context, "Ayarlar", UserSettingScreen(), Icons.settings),
        Padding(
          padding: const EdgeInsets.only(left: 180.0),
          child: IconButton(
            onPressed: () async {
              final Auth authService = Auth();
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
            icon: Icon(Icons.exit_to_app, size: 50),
          ),
        ),
      ],
    ),
  );
}

ListTile menuItem(
  BuildContext context,
  String itemName,
  Widget route,
  IconData icon,
) {
  return ListTile(
    leading: Column(children: [SizedBox(height: 15), Icon(icon, size: 35)]),
    title: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(itemName, style: GoogleFonts.josefinSans(fontSize: 24)),
    ),
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => route),
      );
    },
  );
}
