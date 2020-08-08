import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_firebase/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return authResult.user;
    } catch (e) {}
  }

  void _sendMessage({String text, File imageFile}) async {
    var user = await _getUser();
    if (user == null) {
      _globalKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Não foi possível fazer o login',
        ),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };

    if (imageFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(UniqueKey().toString())
          .putFile(imageFile);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imageUrl'] = url;
    }

    if (text != null) {
      data['text'] = text;
    }

    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance.collection("messages").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    var query = snapshot.data as QuerySnapshot;
                    var documents = query.documents;
                    documents.sort(
                        (a, b) => b.data['timestamp'] - a.data['timestamp']);
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(documents[index].data,
                            _currentUser.uid == documents[index].data['uid']);
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
