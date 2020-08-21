import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id ="ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController=TextEditingController();
  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  String messageText;
  void getCurrentUser()async{
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }
  /*void getMessages() async{
    final messages= await _firestore.collection('messages').getDocuments();
    for ( var message in messages.documents){
      print(message.data);
    }*/
  void messagesStream() async{
    await for(var snapshot in _firestore.collection("messages").snapshots()){
      for(var message in snapshot.documents) {
        print(message.data);
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
                _auth.signOut();
                Navigator.pop((context));
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messages").orderBy('date').snapshots(),
              // ignore: missing_return
              builder:(context, snapshot){
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data.documents.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.data["text"];
                  final messageSender = message.data["sender"];
                  final messageBubble = MessageBubble(
                    sender: messageSender,
                    text: messageText,
                    isMe: loggedInUser.email==messageSender,
                  );
                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                      children: messageBubbles,
                    ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: TextField(
                        controller: messageTextController,
                        style: TextStyle(color: Colors.black,fontSize: 20),
                        onChanged: (value) {
                          messageText=value;
                        },
                        decoration: InputDecoration(hintText: "Type your message here...",hintStyle: TextStyle(color: Colors.grey,fontSize: 20),),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection("messages").add({
                        "text":messageText,
                        "sender":loggedInUser.email,
                        "date": FieldValue.serverTimestamp()
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text,this.isMe});
  final isMe;
  final String text;
  final String sender;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(fontSize: 12,color: Colors.black54)),
          Material(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(isMe ? 30 : 0),bottomLeft:Radius.circular(30),bottomRight: Radius.circular(30),topRight: Radius.circular(isMe ? 0 :30)),              elevation: 5,
              color: isMe ? Colors.lightBlueAccent: Color(0xffE4E6EB),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Text(
                  '$text',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black54, fontSize: 20),
                ),
              )
          ),
        ],
      )
    );
  }
}
