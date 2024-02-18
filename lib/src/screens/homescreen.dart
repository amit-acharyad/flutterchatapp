import 'package:chatapp/src/screens/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.people),
      ),title:Text("People",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),) ,backgroundColor: Colors.blueAccent,),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection("users").snapshots(),
          builder: (context, snapshot) {
            List<Widget> userWidget = [];
            if (!snapshot.hasError) {
              if (snapshot.hasData) {
                final users = snapshot.data?.docs ?? [];
                for (var user in users) {
                  String userName =
                      (user.data() as Map<String, dynamic>)['user'];
                  String uid = (user.data() as Map<String, dynamic>)['uid'];
                  String imgUrl =
                      (user.data() as Map<String, dynamic>)['imgUrl'] ??
                          'randomurl';
                  if (!(uid == _auth.currentUser?.uid)) {
                    userWidget.add(userTile(userName, imgUrl,uid, context));
                  }
                }
                return ListView.builder(
                    itemCount: userWidget.length,
                    itemBuilder: (context, index) {
                      return userWidget[index];
                    });
              } else if (snapshot.data?.docs == null) {
                return Center(child: CircularProgressIndicator());
              }
            } else {
              print("Error Occured");
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Error fetching data"),
                    actions: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close))
                    ],
                  );
                },
              );
            }
            return Text("Unknown Territory");
          }),
    );
  }

  userTile(String name, String imgUrl,String uid,context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: imgUrl != null ? NetworkImage(imgUrl) : null,
        child: imgUrl != null ? null : Icon(Icons.person),
      ),
      title: Text(name),
     
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(width: 1.5,color: Colors.white)),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Chat(
                receiverId: uid,
                receiverName: name,
                )));
      },
    );
  }
}
