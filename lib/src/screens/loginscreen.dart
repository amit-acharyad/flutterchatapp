import 'package:chatapp/src/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/src/widgets/custombutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/src/widgets/customDialog.dart';
import 'package:chatapp/src/widgets/textfielddecoration.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String id = "loginScreen";

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  late String email;
  bool showspinner = false;
  static bool checkbox = false;

  late String password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late String resetEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "Flutter", child: FlutterLogo(size: 200)),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              margin: EdgeInsets.only(left: 30, right: 20),
              alignment: Alignment.center,
              child: TextField(
                controller: _emailController,
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
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
                controller: _passwordController,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                obscureText: true,
                decoration: decoration("Password", Icon(Icons.lock)),
              ),
            ),
            SizedBox(height: 30),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: checkbox,
                      onChanged: (value) {
                        setState(() {
                          checkbox = value!;
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.blue,
                      side: BorderSide(color: Colors.black, width: 1.5),
                    ),
                    Text("Remember Me"),
                    Spacer(),
                    InkWell(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    Text("Enter your email for password reset"),
                                icon: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.close)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      onChanged: (value) {
                                        resetEmail = value;
                                      },
                                      decoration: decoration(
                                          "Enter Email", Icon(Icons.email)),
                                    ),
                                    SizedBox(height: 10),
                                    CustomButton(
                                        text: "Submit",
                                        color: Colors.blue,
                                        onTap: () async {
                                          try {
                                            await _auth
                                                .sendPasswordResetEmail(
                                                    email: resetEmail)
                                                .then((value) {
                                              Navigator.of(context).pop();
                                              showNewDialog(context);
                                            });
                                          } on FirebaseAuthException catch (e) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("${e.message}"),
                                                    actions: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          icon:
                                                              Icon(Icons.close))
                                                    ],
                                                  );
                                                });
                                          }
                                        })
                                  ],
                                ),
                              );
                            });
                      },
                    )
                  ],
                ),
              ),
            ),
            CustomButton(
                text: "Login",
                color: Colors.blueAccent,
                onTap: () async {
                  setState(() {
                    showspinner = true;
                  });
                  try {
                    await _auth.signInWithEmailAndPassword(
                        email: email, password: password);

                    // setState(() {
                    //   showspinner = false;
                    // });

                    if (checkbox) {
                      _auth.setPersistence(Persistence.LOCAL);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("keepMeLoggedIn", checkbox);
                    }
                    Navigator.of(context).pushNamed(MainScreen.id);
                    _emailController.clear();
                    _passwordController.clear();
                  } on FirebaseException catch (e) {
                    // setState(() {
                    //   showspinner = true;
                    // });
                    print("Error logging in.$e");

                    showCustomDialog(context, e.message ?? "Error");
                    // setState(() {
                    //   showspinner = false;
                    // });
                  }
                  setState(() {
                    showspinner = false;
                  });
                })
          ],
        ),
      ),
    );
  }

  showNewDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Password Reset"),
            content: Text(
                "Your Password reset email has been sent.Please check your email."),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(LoginScreen.id);
                  },
                  icon: Icon(Icons.close))
            ],
          );
        });
  }
}
