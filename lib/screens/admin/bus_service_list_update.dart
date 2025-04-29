import 'package:flutter/material.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class BusListUpdateScreen extends StatefulWidget {
  const BusListUpdateScreen({super.key});

  @override
  State<BusListUpdateScreen> createState() => _BusListUpdateScreenState();
}

class _BusListUpdateScreenState extends State<BusListUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarAdmin(context, "Otobüs Güncelle", "")),
      drawer: menuBarAdmin(context),
    );
  }
}
