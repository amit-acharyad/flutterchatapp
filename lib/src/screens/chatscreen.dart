import 'package:chatapp/src/screens/welcomescreen.dart';
import 'package:chatapp/src/widgets/textfielddecoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  static String id = "chatscreen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? loggedInUser;
  late String message;
  final _fireStore = FirebaseFirestore.instance;
  final textController = TextEditingController();

  void initState() {
    super.initState();
    getUser();
  }

  getUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print("${loggedInUser?.email}, ${loggedInUser?.displayName}");
      } 
    } catch (e) {
      print("Error fetching user:$e");

      Navigator.of(context).pushReplacementNamed(WelcomeScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Group Chat",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        leading: Container(
          margin: EdgeInsets.only(left: 20),
          child: FlutterLogo(),
        ),

        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore
                    .collection("flutterchat_database")
                    .orderBy("timestamp")
                    .snapshots(),
                builder: (context, snapshot) {
                  List<Widget> messageWidget = [];
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    final messages = snapshot.data?.docs.reversed ?? [];
                    for (var message in messages) {
                      final messageText =
                          (message.data() as Map<String, dynamic>)["message"] ?? '';
                      final messageSender =
                          (message.data() as Map<String, dynamic>)["sender"] ?? '';
                      bool isMe = messageSender == loggedInUser?.displayName;
                      Widget msg = Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$messageSender",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          MessageBubble(messageText: messageText, isMe: isMe),
                        ],
                      );
                      messageWidget.add(msg);
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: messages.length,
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        itemBuilder: (context, index) => messageWidget[index],
                      ),
                    );
                  }
                }),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration:
                          decoration("Your Message Here", Icon(Icons.message)),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _fireStore.collection("flutterchat_database").add({
                          "message": message,
                          "sender": loggedInUser?.displayName,
                          "timestamp": DateTime.now(),
                        });
                        textController.clear();
                      },
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.blue,
                      ))
                ],
              ),
            ),
            Divider(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  String messageText;
  bool isMe;
  MessageBubble({required this.messageText, required this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Material(
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))
            : BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${messageText}",
            style: TextStyle(
                fontSize: 15, color: Colors.white),
          ),
        ),
        color: isMe ? Colors.blueAccent : Colors.black54,
      ),
    );
  }
}
