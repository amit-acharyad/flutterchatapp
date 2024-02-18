import 'package:flutter/material.dart';

showCustomDialog(BuildContext context, String e) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text("$e"),
          actions: [
            TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close_rounded),
                label: Text("Close"))
          ],
        );
      });
}
