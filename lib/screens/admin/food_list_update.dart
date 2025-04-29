import 'package:flutter/material.dart';
import 'package:staff_ease/widgets/admin_widgets/appbar_admin.dart';
import 'package:staff_ease/widgets/admin_widgets/menubar_admin.dart';

class FoodListUpdateScreen extends StatefulWidget {
  const FoodListUpdateScreen({super.key});

  @override
  State<FoodListUpdateScreen> createState() => _FoodListUpdateScreenState();
}

class _FoodListUpdateScreenState extends State<FoodListUpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: myAppBarAdmin(context, "Yemek Listesi Güncelle", ""),
      ),
      drawer: menuBarAdmin(context),
    );
  }
}
