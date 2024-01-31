import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String? id;
  final Timestamp? lastseen;
  final String? email;
  final String? name;
  final String? image;
  Contact({this.id, this.lastseen, this.email, this.name, this.image});
  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final Map<dynamic, dynamic> data = doc.data() as Map<dynamic, dynamic>;
    return Contact(
      id: doc.id,
      lastseen: data['lastSeen'],
      email: data['email'],
      name: data['username'],
      image: data['imageUrl'],
    );
  }
}
