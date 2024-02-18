import 'package:chatapp/src/screens/chatscreen.dart';
import 'package:chatapp/src/widgets/textfielddecoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiChat extends StatefulWidget {
  @override
  State<GeminiChat> createState() => _GeminiChatState();
}

class _GeminiChatState extends State<GeminiChat> {
  final gemini = Gemini.instance;

  final TextEditingController textController = TextEditingController();

  String? message;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final messageWidget = [];
  void initState() {
    super.initState();
    _firestore.collection('ai_chats');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore
            .collection('ai_chats')
            .doc(_auth.currentUser?.uid)
            .collection("${_auth.currentUser?.uid}")
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, snapshot) {
          List messageWidget = [];
          if (snapshot.hasData) {
            var messages = snapshot.data?.docs.reversed ?? [];
            for (var message1 in messages) {
              String text = (message1.data() as Map<String, dynamic>)['text'] ??
                  'Could not generate Response';
              String sender =
                  (message1.data() as Map<String, dynamic>)['sender']??'';
              bool isMe = sender == 'Me' ? true : false;
              messageWidget.add(Column(
               crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
                children: [
                  Text(sender),
                  MessageBubble(messageText: text, isMe: isMe),
                ],
              ));
            }

            return Scaffold(
                appBar: AppBar(),
                body: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                                reverse: true,
                                itemCount: messageWidget.length,
                                itemBuilder: (context, index) {
                                  return messageWidget[index];
                                })),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textController,
                                decoration: decoration(
                                    "Chat with Gemini", Icon(Icons.chat)),
                                onChanged: (value) {
                                  message = value;
                                },
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  textController.clear();
                                  _firestore
                                      .collection('ai_chats')
                                      .doc(_auth.currentUser?.uid)
                                      .collection("${_auth.currentUser?.uid}")
                                      .add({
                                    'text': message,
                                    'sender': "Me",
                                    'timestamp': DateTime.now()
                                  }).then((value) {
                                    print("Success");
                                  }).onError((error, stackTrace) {
                                    print("Error ${error.toString()}");
                                  });

                                  gemini.text(message!).then((value) {
                                    print(value?.output);

                                    _firestore
                                        .collection('ai_chats')
                                        .doc(_auth.currentUser?.uid)
                                        .collection("${_auth.currentUser?.uid}")
                                        .add({
                                      'text': value?.output,
                                      'sender': 'Gemini',
                                      'timestamp': DateTime.now()
                                    }).then((value) {
                                      print("Success");
                                    }).onError((error, stackTrace) {
                                      print("Error ${error.toString()}");
                                    });
                                  });
                                },
                                icon: Icon(Icons.send,color: Colors.blue,))
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
