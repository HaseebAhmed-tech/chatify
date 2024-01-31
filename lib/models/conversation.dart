import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'message.dart';

class ConversationSnippet {
  final String? id;
  final String? conversationID;
  final String? image;
  final String? lastMessage;
  final String? name;
  final int? unseenCount;
  final Timestamp? timestamp;
  final String? type;

  ConversationSnippet({
    this.id,
    this.name,
    this.image,
    this.lastMessage,
    this.unseenCount,
    this.conversationID,
    this.timestamp,
    this.type,
  });

  factory ConversationSnippet.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ConversationSnippet(
      id: snapshot.id,
      name: data['name'],
      image: data['image'],
      lastMessage: data['lastMessage'] ?? 'Start a conversation',
      unseenCount: data['unseenCount'],
      conversationID: data['conversationID'],
      timestamp: data['timestamp'],
      type: data['type'],
    );
  }
}

class Conversation {
  final String? id;
  final List? members;
  final List? messages;
  final String? ownerID;

  Conversation({this.id, this.members, this.messages, this.ownerID});

  factory Conversation.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    debugPrint('Conversation Data: $data');
    List? messages = data['messages'];
    debugPrint('Conversation Messages: $messages');
    if (messages!.isNotEmpty) {
      debugPrint('Conversation Messages is not Empty');
      messages = messages.map(
        (m) {
          debugPrint('Conversation SnederID: ${m['senderID']}');
          final messageType =
              m['type'] == 'text' ? MessageType.text : MessageType.image;
          debugPrint('Conversation Type: $messageType');
          debugPrint('Conversation message: ${m['message']}');
          debugPrint('Conversation timestamp: ${m['timestamp']}');
          return Message(
              m['senderID'], m['message'], m['timestamp'], messageType);
        },
      ).toList();
      debugPrint(
          'Conversation Messages(Class) SenderID: ${messages[0].senderID}');
    } else {
      debugPrint('Conversation Messages is Empty');
      messages = [];
    }
    debugPrint('Conversation Return: ${Conversation(
      id: snapshot.id,
      members: data['members'],
      messages: messages,
      ownerID: data['ownerID'],
    )}');

    return Conversation(
      id: snapshot.id,
      members: data['members'],
      messages: messages,
      ownerID: data['ownerID'],
    );
  }
}
