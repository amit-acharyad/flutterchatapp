import 'dart:io';
import 'package:chatapp/src/screens/welcomescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  static String id = "profile";

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? imageFile;

  FirebaseAuth _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile? pickedFile) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedFile!.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (croppedImage != null) {
      File? croppedFile = File(croppedImage.path);
      setState(() {
        imageFile = croppedFile;
      });
    }
    uploadPhoto();
  }

  void uploadPhoto() async {
    try {
      UploadTask uploadTask =
          FirebaseStorage.instance.ref("photos").child(_auth.currentUser!.uid).putFile(imageFile!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {
        print("Photo upload complete");
      });
      String downloadedUrl = await taskSnapshot.ref.getDownloadURL();

      print("Url:$downloadedUrl");
      // _fireStore.collection("images").add({"imgUrl": downloadUrl});
      CollectionReference userCollection = _fireStore.collection('users');
      DocumentReference userDocument =
          userCollection.doc(_auth.currentUser!.uid);
      userDocument.update({'imgUrl': downloadedUrl}).then((value) {
        print("Success");
      }).catchError((onError) {
        print("Error $onError");
      });
    } catch (e) {
      print("Error uploading photo $e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: Center(child: Icon(Icons.person)),
      title: Text("Profile",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      backgroundColor: Colors.blueAccent,),

      body: StreamBuilder(
        stream: _fireStore
            .collection("users")
            .doc(_auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasError) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              print(snapshot.data);
              print(snapshot.data!.data());
              final url =
                  (snapshot.data!.data() as Map<String, dynamic>)['imgUrl'];
              print(url);
              final name =
                  (snapshot.data!.data() as Map<String, dynamic>)['user'];
      
              return Scaffold(
                body: Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  margin: EdgeInsets.only(top: 100, right: 20, left: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: CircleAvatar(
                            radius: 40,
                            child: url != null ? null:Icon(Icons.person),
                            backgroundImage:
                                url != null ? NetworkImage(url) : null,
                          ),
                          onTap: () => _showPhotoOptionsDialog(context),
                        ),
                        ListTile(
                          title: Center(child:Text(" Name")),
                          
                          subtitle: Center(
                            child: Text(
                              "${_auth.currentUser!.displayName}",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ]),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: () async {
                    _auth.signOut();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setBool("keepMeLoggedIn", false);
                    Navigator.of(context).pushReplacementNamed(WelcomeScreen.id);
                  },
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ Icon(Icons.logout,color: Colors.white,),],
                  ),
                ),
              );
            }
          } else {
            print("${snapshot.error.toString()}");
            return Text("Error");
          }
        },
      ),
    );
  }

  _showPhotoOptionsDialog(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    leading: Icon(Icons.browse_gallery),
                    title: Text("Browse from Gallery"),
                    onTap: () {
                      print("Clicked on gallery");
                      selectImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                    leading: Icon(Icons.camera),
                    title: Text("Take Photo"),
                    onTap: () {
                      print("Clicked on Camera");
                      selectImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    }),
              ],
            ),
            actions: [
              IconButton.filled(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close))
            ],
          );
        });
  }
}
