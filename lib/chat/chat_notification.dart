import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:teachr/globals.dart' as globals;

//voor elke chat
//kijken of het laatste bericht door een andere sender is gestuurd
//als dit zo is maak deze titel BOLD

class ChatNotification {
  List<String> chatMessageIDs = new List<String>();

  // Future checkChatMessages() async {
    // await findChatRooms(133);

    // print("dit is global - " + globals.newMessages.toString());
  // }

  //setter
  // void addToMessageList(String chatMessageID) {
  //   print('adding '+chatMessageID);
  //   this.chatMessageIDs.add(chatMessageID);
  //   print(chatMessageIDs.length);
  // }

  //getter
  // List<String> returnMessageList(){
  //   return this.chatMessageIDs;
  // }

  // Future findChatRooms(int userID) async {
  //   // TEST PURPOSES
  //   int userRole = globals.currentUser.role;
  //   if (userID == 155) {
  //     userRole = 2;
  //   }
    // END TEST PURPOSES

    // TODO: Check the global variable with a function
    // TODO: Change global variable when chatroom is entered with unread message

    //get all chat rooms
    // var allChatRooms;
    // if (userRole == 2) {
    //   allChatRooms = Firestore.instance
    //       .collection("chatroom")
    //       .where("schoolID", isEqualTo: userID);
    // } else if (userRole == 1) {
    //   allChatRooms = Firestore.instance
    //       .collection("chatroom")
    //       .where("userID", isEqualTo: userID);
    // }
    // final QuerySnapshot result = await allChatRooms.getDocuments();
    // final List<DocumentSnapshot> docs = result.documents;

    // print(docs.first.data['chatroomID']);

    // await findLastChatMessage(docs.first.data['chatroomID'], userID);

    // docs.forEach((chatroom) {
    //   if (stopLoop != 1 &&
    //       checkLastMessageStatus(chatroom, userID).toString() == 'true') {
    //     stopLoop = 1;
    //     return 1;
    //   }
    //   return 0;
    // });

    // docs.forEach((chatRoom) {
    //   var d = findLastChatMessage(chatRoom['chatroomID'], userID);
    //   if (identical(d, 1)) {
    //     print('IDENTICAL: ' + chatRoom['message'].toString());
    //   }
    // });
  // }

  // Future findLastChatMessage(int chatroomID, int userID) async {
  //   var chatMessages = Firestore.instance
  //       .collection("chat_messages")
  //       .where("chatroomID", isEqualTo: chatroomID)
  //       .orderBy("time", descending: true);

  //   final QuerySnapshot result = await chatMessages.getDocuments();
  //   final List<DocumentSnapshot> docs = result.documents;
  //   if (docs.length > 0) {
  //     var lastMessage = docs.first;
  //     // print(lastMessage['message'] + " - " + lastMessage['read'].toString());

  //     // Last message is not read.
  //     if (lastMessage['read'] == false) {
  //       globals.newMessages = true;
  //       addToMessageList(lastMessage.documentID); 
  //     } else {
  //       globals.newMessages = false;
  //     }
  //   }
  // }

  // Future checkChats(int userID) async {
    // TEST PURPOSES
    // int userRole = 1;
    // if (userID == 155) {
    //   userRole = 2;
    // }
    // END TEST PURPOSES

    // var stopLoop = 0;
    // var allChatRooms;
    // if (userRole == 2) {
    //   allChatRooms = Firestore.instance
    //       .collection("chatroom")
    //       .where("schoolID", isEqualTo: userID);
    // } else if (userRole == 1) {
    //   allChatRooms = Firestore.instance
    //       .collection("chatroom")
    //       .where("userID", isEqualTo: userID);
    // }
    // final QuerySnapshot result = await allChatRooms.getDocuments();
    // final List<DocumentSnapshot> docs = result.documents;

    // print(docs.length.toString() + " <-- length");

    // docs.forEach((chatroom) {
    //   if (stopLoop != 1 &&
    //       checkLastMessageStatus(chatroom, userID).toString() == 'true') {
    //     stopLoop = 1;
    //     return 1;
    //   }
    //   return 0;
    // });

  //   return 0;
  // }

  // Future<int> checkLastMessageStatus(var chatroom, int userID) async {
  //   var chatroomCollection = Firestore.instance
  //       .collection("chat_messages")
  //       .where("chatroomID", isEqualTo: chatroom['chatroomID'])
  //       .orderBy("time", descending: true);

  //   final QuerySnapshot result = await chatroomCollection.getDocuments();
  //   final List<DocumentSnapshot> docs = result.documents;
  //   if (docs.length > 0) {
  //     var lastMessage = docs.first;
  //     // print(lastMessage['senderID'].toString() + " -- " + lastMessage['message'].toString());

  //     if (lastMessage['read'] == false && lastMessage['senderID'] != userID) {
  //       //set diamond status
  //       print('is positive');
  //       return 1;
  //     }
  //   }
  //   return 0;
  // }
}
