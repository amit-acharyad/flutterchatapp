import 'package:chatapp/src/screens/aichat.dart';
import 'package:chatapp/src/screens/chatscreen.dart';
import 'package:chatapp/src/screens/homescreen.dart';
import 'package:chatapp/src/screens/profilescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  static String id = "mainscreen";
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  @override
  int currentindex = 0;
  static bool isLoggedIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  void checkLoggedIn() async {
    try {
      await _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          print(user.displayName);
          setState(() {
            isLoggedIn = true;
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      print("Error: $e");
    }
  }

  void initState() {
    super.initState();
    checkLoggedIn();
    CollectionReference userCollection = _fireStore.collection('users');
    DocumentReference userDocument = userCollection.doc(_auth.currentUser!.uid);
    Map<String, dynamic> userData = {
      'user': _auth.currentUser?.displayName,
      'uid':_auth.currentUser?.uid
    };
    userDocument
        .get()
        .then((docSnapshot) => {
              if (docSnapshot.exists)
                {
                  userDocument.update(userData).then((_) {
                    print("Updated Successfully");
                  }).catchError((onError) {
                    print("ERROR UPDaTIng $onError");
                  })
                }
              else
                {
                  userDocument.set(userData).then((_) {
                    print("Doc added successfully");
                  }).catchError((onError) {
                    print("ERROR addind doc $onError");
                  })
                }
            })
        .catchError((onError) {
      print("EROR $onError");
    });

  

    // userDocument.update({"imgUrl": url});
  }

  List<Widget> screens = [Home(), ChatScreen(),GeminiChat(), Profile()];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[currentindex],
      bottomNavigationBar: BottomNavigationBar(
          items: List.generate(labels.length, (index) {
            return BottomNavigationBarItem(
                icon: Icon(
                  icons[index],
                  size: currentindex == index ? 30 : 24,
                  color: currentindex == index ? Colors.blue : Colors.black54,
                ),
                label: labels[index]);
          }),
          onTap: (value) async {
            setState(() {
              currentindex = value;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("isLoggedIn", isLoggedIn);
          }),
    );
  }
}

List labels = ["Home", "Chat","Ai Chat", "Profile"];
List icons = [Icons.home, Icons.chat,Icons.mobile_friendly, Icons.person];
