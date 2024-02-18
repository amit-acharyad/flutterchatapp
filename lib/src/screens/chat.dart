import 'package:chatapp/src/screens/chatscreen.dart';
import 'package:chatapp/src/widgets/textfielddecoration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  String receiverId;
  String receiverName;

  Chat({required this.receiverId, required this.receiverName});

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth _auth = FirebaseAuth.instance;

  

  String? textMessage;

  TextEditingController _messageController = TextEditingController();

  Widget build(BuildContext context) {
    String docId = receiverId + _auth.currentUser!.uid;
    String adocId = String.fromCharCodes(docId.runes.toList()..sort());
    return Scaffold(
      appBar: AppBar(
       
        title:Text("Flutter Chat") ,
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            StreamBuilder(
                stream: _firestore
                    .collection('chats')
                    .doc(adocId)
                    .collection(adocId)
                    .orderBy('timestamp')
                    .snapshots(),
                builder: ((context, snapshot) {
                  List messageWidget = [];
                  if (snapshot.hasData) {
                    var messages = snapshot.data?.docs.reversed ?? [];
                    for (var message in messages) {
                      String sender =
                          (message.data() as Map<String, dynamic>)['sender'];
                      String msg =
                          (message.data() as Map<String, dynamic>)['message'] ??
                              '';
                      bool isMe = sender == _auth.currentUser?.displayName;
                      messageWidget.add(Column(
                        crossAxisAlignment:
                             isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Text(sender),
                          MessageBubble(messageText: msg, isMe: isMe),
                        ],
                      ));
                    }

                    return Expanded(
                      child: ListView.builder(
                        reverse: true,
                          itemCount: messageWidget.length,
                          itemBuilder: ((context, index) {
                            return messageWidget[index];
                          })),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                })),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        textMessage = value;
                      },
                      controller: _messageController,
                      decoration:
                          decoration("Your Message Here", Icon(Icons.message)),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _firestore
                            .collection('chats')
                            .doc(adocId)
                            .collection(adocId)
                            .add({
                          'sender': _auth.currentUser?.displayName,
                          'message': _messageController.text.trim(),
                          'timestamp': DateTime.now()
                        });
                        _messageController.clear();
                      },
                      child: Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
