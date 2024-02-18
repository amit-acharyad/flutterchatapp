import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  String text;
  Color color;
  void Function()? onTap;
  CustomButton({required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30),
      height: 40,
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Center(
        child: InkWell(
          child: Text(text,style: TextStyle(fontSize: 18,color: Colors.white),),
          onTap: onTap,
        ),
      ),
    );
  }
}
