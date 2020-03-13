import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:teachr/chat/chat_object.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:teachr/language/localizations.dart';
import 'package:teachr/themes.dart';
import 'package:teachr/globals.dart' as globals;

class ChatPage extends StatefulWidget {
  ChatPage(this._chatData);

  final ChatroomData _chatData;

  @override
  _ChatPageState createState() => new _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _checkMessageReadState();

    // var list = ChatNotification().returnMessageList();
    // list.forEach((value){
    //   print(value);
    // });
    // print(list.length);

    var chatroomCollection = Firestore.instance
        .collection("chat_messages")
        .where("chatroomID", isEqualTo: widget._chatData.chatroomID)
        .orderBy("time", descending: true);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget._chatData.jobTitle),
          centerTitle: true,
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatroomCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) {
                        DocumentSnapshot document =
                            snapshot.data.documents[index];

                        // Check if the message is sent by the user of the application.
                        bool isOwnMessage = false;
                        if (document['senderID'] == globals.currentUser.id) {
                          isOwnMessage = true;
                        }

                        // Print the message on the left or right side based on sender
                        if (isOwnMessage) {
                          return _ownMessage(document['message']);
                        } else {
                          return _message(document['message']);
                        }
                      },
                      itemCount: snapshot.data.documents.length,
                    );
                  },
                ),
              ),
              new Divider(height: 1.0),
              Container(
                margin: EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        controller: _controller,
                        onSubmitted: _handleSubmit,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: new InputDecoration.collapsed(
                            hintText:
                                LangLocalizations.of(context).trans('send')),
                      ),
                    ),
                    new Container(
                      child: new IconButton(
                          icon: new Icon(
                            Icons.send,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            _handleSubmit(_controller.text);
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future _checkMessageReadState() async {
    var chatroomCollection = Firestore.instance
        .collection("chat_messages")
        .where("chatroomID", isEqualTo: widget._chatData.chatroomID)
        .orderBy("time", descending: true)
        .limit(1);

    final QuerySnapshot result = await chatroomCollection.getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    if (docs.length > 0) {
      var lastMessage = docs.first;

      if (lastMessage['read'] == false &&
          lastMessage['senderID'] != globals.currentUser.id) {
        lastMessage.reference.updateData({"read": true});
      }
    }
  }

  Widget _ownMessage(String message) {
    return Container(
      margin: chatMessageSpacing,
      decoration: new BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: new BorderRadius.only(
              topRight: chatMessageBorderRadius,
              topLeft: chatMessageBorderRadius,
              bottomLeft: chatMessageBorderRadius)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(globals.currentUser.firstname.toString(),
                  style: TextStyle(color: Colors.black)), // First name
              _customSizedTextBox(message, 2), // Message
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 15.0),
          ),
        ],
      ),
    );
  }

  Widget _message(String message) {
    return Container(
      margin: chatMessageSpacing,
      decoration: new BoxDecoration(
          color: lightGrayColor,
          borderRadius: new BorderRadius.only(
              topLeft: chatMessageBorderRadius,
              topRight: chatMessageBorderRadius,
              bottomRight: chatMessageBorderRadius)),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15.0),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget._chatData.teacherName,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.deepOrange),
              ), // First name
              _customSizedTextBox(message, 1), // Message
            ],
          )
        ],
      ),
    );
  }

  Widget _customSizedTextBox(String message, int position) {
    // Chat container width 80%.
    double containerWidth = MediaQuery.of(context).size.width * 0.8;

    Alignment align = Alignment.centerLeft;
    var textStyle = new TextStyle(color: Colors.black);
    if (position == 2) {
      align = Alignment.centerRight;
      textStyle = new TextStyle(color: Colors.white);
    }

    return SizedBox(
      width: containerWidth,
      child: Align(
        alignment: align,
        child: AutoSizeText(
          message,
          minFontSize: 14,
          style: textStyle,
        ),
      ),
    );
  }

  _handleSubmit(String message) {
    if (message.isNotEmpty) {
      int unixtimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      _controller.text = "";
      var db = Firestore.instance;
      db.collection("chat_messages").add({
        "senderID": globals.currentUser.id,
        "chatroomID": widget._chatData.chatroomID,
        "message": message,
        "time": unixtimestamp,
        "read": false
      }).then((val) {
        print("success");
      }).catchError((err) {
        print(err);
      });
    }
  }
}
