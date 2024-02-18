import 'package:flutter/material.dart';

InputDecoration decoration(String label, Icon icon) {
  return InputDecoration(
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent),
          borderRadius: BorderRadius.circular(20)),
      prefixIcon: icon,
      prefixIconColor: Colors.grey,
      contentPadding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      fillColor: Colors.grey[200],
      label: Text(label));
}
