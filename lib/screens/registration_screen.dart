import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static String id ="registrationScreen";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth=FirebaseAuth.instance;
  String email;
  String password;
  bool _saving=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
                onChanged: (value) {
                 email=value;
                },
                decoration: kTextFieldDecorationEmail
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
                onChanged: (value) {
                  password=value;
                },
                decoration: kTextFieldDecorationPass
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(color: Colors.blueAccent,tile: 'Register',
                onPressed: ()async{
                  setState(() {
                    _saving=true;
                  });
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email.replaceAll(new RegExp(r"\s+"), ""), password: password);
                    if(newUser!=null){
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      _saving=false;
                    });
                  }
                  catch(e){
                    print(e);
                    setState(() {
                      _saving=false;
                    });
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
