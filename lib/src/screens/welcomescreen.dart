import 'package:chatapp/src/screens/loginscreen.dart';
import 'package:chatapp/src/screens/registerscreen.dart';
import 'package:chatapp/src/widgets/custombutton.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  static String id="welcomescreen";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: "Flutter",
              child: FlutterLogo(
                size: 250,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            AnimatedDefaultTextStyle(
              child: Text("Flutter Chat"),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              duration: Duration(seconds: 5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            CustomButton(
                text: "Login",
                color: Colors.blueAccent,
                onTap: () {
                  print("Login");
                  Navigator.pushNamed(context, LoginScreen.id);
                }),
            SizedBox(height: 15),
            CustomButton(
                text: "Register",
                color: Colors.blue,
                onTap: () {
                  print("Register");
                  Navigator.pushNamed(context, RegisterScreen.id);
                })
          ],
        ),
      ),
    );
  }
}
