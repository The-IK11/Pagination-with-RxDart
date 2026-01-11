import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pagination_with_rxdart/presentaion/pagination_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pagination Flutter Demo',
      theme: ThemeData(
   textTheme: GoogleFonts.lailaTextTheme(
      Theme.of(context).textTheme,
    ), 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PaginationScreen(),
    );
  }
}

