import 'package:chatify/models/contact.dart';
import 'package:chatify/models/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService();
  static DatabaseService get instance => _instance;
  final FirebaseFirestore? _db;

  DatabaseService() : _db = FirebaseFirestore.instance;

  final String _userCollection = 'Users';
  final String _conversationsCollection = 'Conversations';

  Future<void>? createUserInDB(
      String uid, String username, String email, String imageUrl) {
    try {
      return _db!.collection(_userCollection).doc(uid).set({
        'username': username,
        'email': email,
        'imageUrl': imageUrl,
        'lastSeen': DateTime.now().toUtc(),
        'createdAt': DateTime.now().toUtc(),
      });
    } catch (e) {
      debugPrint('Create user: ${e.toString()}');
      return null;
    }
  }

  Stream<Contact> getUserData(String uid) {
    final ref = _db!.collection(_userCollection).doc(uid);
    return ref
        .get()
        .asStream()
        .map((snapshot) => Contact.fromFirestore(snapshot));
  } // Stream getUserD

  Stream<List<ConversationSnippet>> getUserConversations(String uid) {
    final ref = _db!
        .collection(_userCollection)
        .doc(uid)
        .collection(_conversationsCollection);
    return ref.snapshots().map(
        (conversationSnapshots) => conversationSnapshots.docs.map((snapshot) {
              return ConversationSnippet.fromFirestore(snapshot);
            }).toList());
  } // Stream getUserConversations

  Stream<List<Contact>> getUsersInDB(String uid, String? search) {
    return _db!
        .collection(_userCollection)
        .where('username', isGreaterThanOrEqualTo: search)
        .where('username', isLessThanOrEqualTo: '${search}z')
        .get()
        .asStream()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Contact.fromFirestore(doc))
          .where((mappedItem) => mappedItem.id != uid)
          .toList();
    });
  }

  Future<void> updateUserLastSeenTime(String uid) {
    final ref = _db!.collection(_userCollection).doc(uid);
    return ref.update({'lastSeen': Timestamp.now()});
  }

  Stream<Conversation> getConversation(String conversationID) {
    final ref = _db!.collection(_conversationsCollection).doc(conversationID);
    return ref.snapshots().map((snapshot) {
      return Conversation.fromFirestore(snapshot);
    });
  }

  Future<void> updateMessages(String conversationID, Message message) {
    final ref = _db!.collection(_conversationsCollection).doc(conversationID);
    return ref.update({
      'messages': FieldValue.arrayUnion(
        [
          {
            'message': message.content,
            'senderID': message.senderID,
            'timestamp': message.timestamp,
            'type': message.type == MessageType.text ? 'text' : 'image',
          },
        ],
      ),
    });
  }

  Future<void> updateUserSideConversation(List membersIDs, String senderID,
      String lastMessage, Timestamp timestamp, String type) async {
    membersIDs.remove(senderID);
    final recieverID = membersIDs[0];
    final refSender = _db!
        .collection(_userCollection)
        .doc(senderID)
        .collection(_conversationsCollection)
        .doc(recieverID);
    await refSender.update({
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'type': type,
    });
    final refReciever = _db!
        .collection(_userCollection)
        .doc(recieverID)
        .collection(_conversationsCollection)
        .doc(senderID);
    await refReciever.update({
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'unseenCount': FieldValue.increment(1),
      'type': type,
    });
  }

  Future<void> createUserSideConversation(List membersIDs, String senderID,
      String recImage, String recName, String conversationID) async {
    membersIDs.remove(senderID);
    final recieverID = membersIDs[0];
    final refSender = _db!
        .collection(_userCollection)
        .doc(senderID)
        .collection(_conversationsCollection)
        .doc(recieverID);

    await refSender.set({
      'conversationID': conversationID,
      'image': recImage,
      'name': recName,
      'unseenCount': 0,
    });
    final refReciever = _db!
        .collection(_userCollection)
        .doc(recieverID)
        .collection(_conversationsCollection)
        .doc(senderID);
    final snapShot = await _db!.collection(_userCollection).doc(senderID).get();

    final senderData = snapShot.data();
    print('createUserSideConversation Sender Data: $senderData');
    senderData != null
        ? await refReciever.set({
            'conversationID': conversationID,
            'image': senderData['imageUrl'],
            'name': senderData['username'],
            'unseenCount': 0,
          })
        : null;
  }

  Future<void> createOrGetConversation(
    String currentID,
    String recieverID,
    String recImage,
    String recName,
    Future<void> Function(String conversationID) onSuccess,
  ) async {
    final userConversationRef = _db!
        .collection(_userCollection)
        .doc(currentID)
        .collection(_conversationsCollection);
    try {
      final conversation = await userConversationRef.doc(recieverID).get();
      if (conversation.data() != null) {
        return onSuccess(conversation.data()!['conversationID']);
      } else {
        final conversationRef = _db!.collection(_conversationsCollection).doc();
        await conversationRef.set({
          'members': [currentID, recieverID],
          'ownerID': currentID,
          'messages': [],
        });
        onSuccess(conversationRef.id);

        await createUserSideConversation([currentID, recieverID], currentID,
            recImage, recName, conversationRef.id);
      }
    } catch (e) {
      debugPrint('createOrGetConversation: ${e.toString()}');
    }
  }
}
