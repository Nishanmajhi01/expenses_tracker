import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final String text;
  const Footer({super.key, this.text = '© 2025 Expenses Tracker'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      color: Colors.teal.shade50,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}
