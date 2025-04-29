import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget myAppBarUser(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("$title", style: GoogleFonts.poppins(color: Colors.black)),
      Padding(padding: const EdgeInsets.only(left: 40.0)),
    ],
  );
}
