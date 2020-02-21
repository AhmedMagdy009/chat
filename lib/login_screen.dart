import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'main.dart';




class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  SharedPreferences prefs;
  String Username;
  String Password;
  FirebaseUser currentUser;
  String admin = 'yPkxctDGxtYhKajtWA7h9fLkIMK2' ;
  bool _ischecked = false;
  @override
  void onchanged(bool value) {
    setState(() {
      _ischecked = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "LOGIN",
          style: TextStyle(
            color: Color(0xff16697a),
          ),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 30,
              color: Color(0xff16697a),
            ),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    onChanged: (value) {
                      Username = value;
                    },
                    decoration: InputDecoration(
                      hintText: '     Email',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    onChanged: (value) {
                      Password = value;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '     Password',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 11),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                          value: _ischecked,
                          onChanged: (bool value) {
                            onchanged(value);
                          }),
                      Text("Remember me")
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                    child: Container(
                      width: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.9
                          : MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.08
                          : MediaQuery.of(context).size.height * 0.1,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 80,
                          bottom: MediaQuery.of(context).size.height / 90),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xff16697a),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Text("Login",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    onTap: () async {
                      try {
                        prefs = await SharedPreferences.getInstance();
                        final newUser = await _auth.signInWithEmailAndPassword(
                            email: Username, password: Password);
                        final FirebaseUser user = await _auth.currentUser();
                        if (newUser != null) {
                          final QuerySnapshot result = await Firestore.instance
                              .collection('users')
                              .where('id', isEqualTo: user.uid)
                              .getDocuments();
                          final List<DocumentSnapshot> documents =
                              result.documents;
                          if (documents.length == 0) {
                            // Update data to server if new user
                            Firestore.instance
                                .collection('users')
                                .document(user.uid)
                                .setData({
                              'name': user.displayName,
                              'photoUrl': user.photoUrl,
                              'id': user.uid,
                              'createdAt': DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              'chattingWith': null
                            });
                            currentUser = user;
                            await prefs.setString('id', currentUser.uid);
                            await prefs.setString(
                                'name', currentUser.displayName);
                            await prefs.setString(
                                'photoUrl', currentUser.photoUrl);
                          } else {
                            // Write data to local
                            await prefs.setString('id', documents[0]['id']);
                            await prefs.setString('name', documents[0]['name']);
                            await prefs.setString(
                                'photoUrl', documents[0]['photoUrl']);
                          }
                        if(user.uid==admin) //admin -> navigate to main screen where he can see all users
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MainScreen(currentUserId: user.uid)));
                        else // user -> navigate to chat screen with peerId = admin id so he can only chat with admin
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Chat(
                                    peerId: admin,
                                    peerAvatar: 'https://firebasestorage.googleapis.com/v0/b/chattest-10fe5.appspot.com/o/logo.png?alt=media&token=1756aa38-c287-4046-b2d4-db10d3ea7c91',
                                  )));
                        }
                      } catch (e) {
                        print(e);
                      }
                    }),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Forgot password?",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
          //write your code here
        ],
      ),
    );
  }
}
