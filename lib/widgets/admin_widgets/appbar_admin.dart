import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget myAppBarAdmin(BuildContext context, String title, String name) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("$title $name", style: GoogleFonts.poppins(color: Colors.black)),
      Padding(padding: const EdgeInsets.only(left: 40.0)),
    ],
  );
}
