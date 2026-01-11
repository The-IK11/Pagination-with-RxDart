import 'package:flutter/material.dart';

class PaginationScreen extends StatefulWidget {
  const PaginationScreen({super.key});

  @override
  State<PaginationScreen> createState() => _PaginationScreenState();
}

class _PaginationScreenState extends State<PaginationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        animateColor: true,
        backgroundColor: Colors.greenAccent,
        shadowColor: Color.fromARGB(255, 249, 249, 249),
        centerTitle: true,

        title: const Text('Pagination Bottom Load'),
      ),
      body: const Center(
        child: Text('Pagination Screen'),
      ),
    );
  }
}