import 'package:flutter/material.dart';
import 'package:staff_ease/widgets/user_widgets/appbar_user.dart';
import 'package:staff_ease/widgets/user_widgets/menubar_user.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: myAppBarUser(context, "Bildirimler")),
      drawer: menuBarUser(context),
    );
  }
}
