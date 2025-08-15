import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class NativeMessageBox extends StatelessWidget {
  const NativeMessageBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: actions
    );
  }
}

class IOSMessageBox extends StatelessWidget {
  const IOSMessageBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: actions
    );
  }
}