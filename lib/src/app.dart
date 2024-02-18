import 'package:chatapp/src/screens/chatscreen.dart';
import 'package:chatapp/src/screens/loginscreen.dart';
import 'package:chatapp/src/screens/mainscreen.dart';
import 'package:chatapp/src/screens/profilescreen.dart';
import 'package:chatapp/src/screens/registerscreen.dart';
import 'package:flutter/material.dart';
import 'screens/welcomescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getValues(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute:
                  snapshot.data??false
                      ? MainScreen.id
                      : WelcomeScreen.id,
              routes: {
                WelcomeScreen.id: (context) => WelcomeScreen(),
                LoginScreen.id: (context) => LoginScreen(),
                RegisterScreen.id: (context) => RegisterScreen(),
                ChatScreen.id: (context) => ChatScreen(),
                MainScreen.id: (context) => MainScreen(),
                Profile.id: (context) => Profile(),
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }));
  }

  Future<bool> getValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool keepMeLoggedIn = prefs.getBool("keepMeLoggedIn") ?? false;
    bool userLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    return keepMeLoggedIn && userLoggedIn;
  }
}
