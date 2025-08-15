import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Function(String) onChanged;
  final TextEditingController controller;

  const MyTextField({
    super.key,
    this.icon,
    this.text = "",
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          label: Row(
            spacing: 12,
            children: [
              Icon(icon),
              Text(text),
            ],
          )
        ),
      ),
    );
  }
}