import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teachr/language/localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachr/chat/chat.dart';
import 'package:teachr/chat/chat_object.dart';
import 'package:http/http.dart' as http;
import 'package:teachr/globals.dart' as globals;

class ChatOverview extends StatefulWidget {
  ChatOverview(this._userID);
  // int unixtimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  final int _userID;
  final int _userRole = globals.currentUser.role;

  @override
  _ChatOverviewState createState() => new _ChatOverviewState();
}

class _ChatOverviewState extends State<ChatOverview> {
  List objectList = [];
  Widget defaultView;
  int initialItemLoad = 0;

  @override
  void initState() {
    super.initState();

    defaultView = loadingSpinner();
    // Subscribe to the Future function.
    _getChatrooms();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: defaultView,
      ),
    );
  }

  Widget chatroomView() {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(LangLocalizations.of(context).trans('chat')),
        centerTitle: true,
        leading: new Container(),
      ),
      body: RefreshIndicator(
        child: new ListView.builder(
            itemCount: objectList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: _setAvatar(objectList[index].avatar),
                title: Text(objectList[index].jobTitle),
                // title: Text(objectList[index].chatroomID.toString()),
                subtitle: Text(
                    LangLocalizations.of(context).trans('matchedon') +
                        ": " +
                        _convertTimestamp(objectList[index].chatroomID)),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // _getLastMessageReadState(objectList[index].chatroomID);
                  _chatPage(objectList[index]);
                },
              );
            }),
        onRefresh: _updateChatrooms,
      ),
    );
  }

  Future<void> _updateChatrooms() async {
    objectList = [];
    await _getChatrooms();
  }

  void _getLastMessageReadState(int chatroomID) async {
    Query collection = Firestore.instance
        .collection("chat_messages")
        .where("chatroomID", isEqualTo: chatroomID)
        .orderBy("time", descending: true)
        .limit(1);
    final QuerySnapshot result = await collection.getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    if (docs.length > 0) {
      bool messageReadState = docs.first['read'];
      if (!messageReadState) {
        // Message is unread
        globals.newMessages = true;
      }
      print(docs.first['message']);
    } else {
      print("ja niets");
    }
  }

  Future _getChatrooms() async {
    initialItemLoad = 1;

    // Default is query for hybrid teacher.
    Query collection = Firestore.instance
        .collection("chatroom")
        .where("userID", isEqualTo: widget._userID);

    if (widget._userRole != 1) {
      // School/teacher
      collection = Firestore.instance
          .collection("chatroom")
          .where("teacherID", isEqualTo: widget._userID);
    }

    final QuerySnapshot result = await collection.getDocuments();
    final List<DocumentSnapshot> docs = result.documents;

    if (docs.length > 0) {
      // Chatrooms exist.
      docs.forEach((document) async {
        final response = await http.get(
            "https://teachrapp.nl/index.php/wp-json/wp/v2/vacature/" +
                document['jobID'].toString());
        if (response.statusCode == 200) {
          // The default avatar image (if wanted).
          String jsonAvatar = "";

          // There is a job offer available.
          var list = json.decode(response.body);

          // Set the avatar image if this is available.
          if (list['school_picture']['guid'] != "") {
            jsonAvatar = list['school_picture']['guid'];
          }

          // TODO: messageCheck --> global.newMessages

          ChatroomData chatroomData = new ChatroomData(
              chatroomID: document['chatroomID'],
              jobID: document['jobID'],
              teacherID: document['teacherID'],
              userID: document['userID'],
              teacherName: list['contact_name'],
              jobTitle: list['title']['rendered'],
              schoolName: list['school_name'],
              avatar: jsonAvatar);
          if (chatroomData != null) {
            setState(() {
              objectList.add(chatroomData);
              defaultView = chatroomView();
            });
          }
        } else {
          print('nothing found on id ' + document['jobID'].toString());
        }
      });
    } else {
      // Return empty view
      setState(() {
        defaultView = new Scaffold(
          appBar: new AppBar(
            title: Text(LangLocalizations.of(context).trans('chat')),
            centerTitle: true,
            leading: new Container(),
          ),
          body: RefreshIndicator(
            child: new ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:10.0),
                ),
                Center(
                  child:
                      Text(LangLocalizations.of(context).trans("nochatfound")),
                ),
              ],
            ),
            onRefresh: _updateChatrooms,
          ),
        );
      }); // End setState.
    }
  }

  _setAvatar(String networkImage) {
    if (networkImage != "") {
      return CircleAvatar(
        backgroundImage: NetworkImage(networkImage),
      );
    }
    return CircleAvatar();
  }

  void _chatPage(ChatroomData chatroomData) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(chatroomData)),
    );
  }

  String _convertTimestamp(int timestamp) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(date);
    return formatted;
  }
}

Widget loadingSpinner() {
  return Stack(
    children: [
      Opacity(
        opacity: 0.3,
        child: const ModalBarrier(dismissible: false, color: Colors.grey),
      ),
      Center(
        child: new CircularProgressIndicator(),
      ),
    ],
  );
}
