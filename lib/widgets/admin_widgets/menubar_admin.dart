import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_ease/main.dart';
import 'package:staff_ease/screens/admin/add_new_user.dart';
import 'package:staff_ease/screens/admin/admin_home.dart';
import 'package:staff_ease/screens/admin/admin_notification_screen.dart';
import 'package:staff_ease/screens/admin/admin_settings.dart';
import 'package:staff_ease/screens/admin/announce_screen.dart';
import 'package:staff_ease/screens/admin/bus_service_list_update.dart';
import 'package:staff_ease/screens/admin/employee.dart';
import 'package:staff_ease/screens/admin/food_list_update.dart';
import 'package:staff_ease/screens/admin/takeoff_confirm.dart';
import 'package:staff_ease/services/auth.dart';

Widget menuBarAdmin(BuildContext context) {
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
        menuItem(context, "Ana Sayfa", AdminHome(), Icons.home),
        menuItem(context, "Yeni Çalışan", AddNewUserScreen(), Icons.add),
        menuItem(context, "Çalışanlar", Employee(), Icons.people),
        menuItem(
          context,
          "Bildirimler",
          AdminNotificationScreen(),
          Icons.notifications,
        ),
        menuItem(context, "Duyuru", AnnounceScreen(), Icons.campaign),
        menuItem(
          context,
          "İzin Onay",
          TakeOffConfirmScreen(),
          Icons.check_circle,
        ),
        menuItem(
          context,
          "Yemek Listesi Güncelle",
          FoodListUpdateScreen(),
          Icons.table_chart,
        ),
        menuItem(
          context,
          "Servis Listesi Güncelle",
          BusListUpdateScreen(),
          Icons.list,
        ),
        menuItem(context, "Ayarlar", AdminSettingsScreen(), Icons.settings),
        Padding(
          padding: const EdgeInsets.only(left: 180.0),
          child: IconButton(
            onPressed: () async {
              final Auth authService = Auth();
              await authService.signOut();
              Navigator.push(
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
  );
}
