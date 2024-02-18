import 'package:chatapp/src/screens/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/src/widgets/custombutton.dart';
import 'package:chatapp/src/widgets/customDialog.dart';
import 'package:chatapp/src/widgets/textfielddecoration.dart';


import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterScreen extends StatefulWidget {
  static String id = "registerscreen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late String email;
  bool showspinner = false;
  late String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String displayName;

  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "Flutter", child: FlutterLogo(size: 200)),
             Container(
              alignment: Alignment.center,
              width: MediaQuery.sizeOf(context).width * 0.8,
              margin: EdgeInsets.only(left: 30, right: 20, bottom: 20),
              child: TextField(
                onChanged: (value) {
                  displayName = value;
                },
                
                decoration: decoration("Name", Icon(Icons.person)),
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              margin: EdgeInsets.only(left: 30, right: 20),
              alignment: Alignment.center,
              child: TextField(
                onChanged: (value) {
                  email = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: decoration("Enter E-mail", Icon(Icons.email)),
              ),
            ),
           
            Container(
              alignment: Alignment.center,
              width: MediaQuery.sizeOf(context).width * 0.8,
              margin: EdgeInsets.only(left: 30, right: 20, top: 30),
              child: TextField(
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
                decoration: decoration("Password", Icon(Icons.lock)),
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
                text: "Register",
                color: Colors.blueAccent,
                onTap: () async {
                  try {
                    setState(() {
                      showspinner = true;
                    });
                    UserCredential _userCredential = await _auth.createUserWithEmailAndPassword(
                        email: email, password: password);
                    await _userCredential.user
                        ?.updateDisplayName(displayName);
                    setState(() {
                      showspinner = false;
                    });
                    Navigator.pushNamed(context, LoginScreen.id);
                  } on FirebaseException catch (e) {
                    setState(() {
                      showspinner = true;
                    });
                    print("Error Creating user: $e");
                    showCustomDialog(context, e.message ?? "Error");
                    setState(() {
                      showspinner = false;
                    });
                  }
                })
          ],
        ),
      ),
    );
  }

 

 
}
