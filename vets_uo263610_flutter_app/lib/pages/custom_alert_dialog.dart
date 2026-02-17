import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
  });
  factory CustomAlertDialog.create(
    BuildContext context,
    String title,
    String message,
  ) {
    return CustomAlertDialog(title: title, message: message);
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text(title), content: Text(message));
  }
}
