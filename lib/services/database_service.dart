import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollections =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollections =
      FirebaseFirestore.instance.collection('groups');

  //saving user data in db
  Future saveUserData(String fullName, String email) async {
    return await userCollections.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  //getting user data from db
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollections.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //getting groups as stream of snapshots
  getGroups() async {
    return userCollections.doc(uid).snapshots();
  }

  //creating group
  createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentrefrence = await groupCollections.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    await groupDocumentrefrence.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentrefrence.id,
    });
    DocumentReference userDocumentReference = userCollections.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentrefrence.id}_$groupName"])
    });
  }

  // get chats
  getChats(String groupId) async {
    return groupCollections
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getAdmin(String groupId) async {
    DocumentReference d = groupCollections.doc(groupId);
    DocumentSnapshot snapshot = await d.get();
    return snapshot['admin'];
  }

  getGroupMembers(String groupId) async {
    return groupCollections.doc(groupId).snapshots();
  }

  //searching groups
  searchGroups(String groupName) async {
    return groupCollections.where("groupName", isEqualTo: groupName).get();
  }

  //to check wether user has joined the group or not
  Future<bool> hasUserJoined(String groupName, groupId, String userName) async {
    DocumentReference documentReference = userCollections.doc(uid);
    DocumentSnapshot snapshot = await documentReference.get();
    List<dynamic> groups = await snapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  //toggling the grp join button
  Future toggleGroupJoin(
      String groupId, String groupName, String userName) async {
    DocumentReference userd = userCollections.doc(uid);
    DocumentReference groupd = groupCollections.doc(groupId);

    DocumentSnapshot snapshot = await userd.get();
    List<dynamic> groups = await snapshot['groups'];
    // if user is joined remove him, if not join add him
    if (groups.contains("${groupId}_$groupName")) {
      await userd.update({
        'groups': FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupd.update({
        'members': FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userd.update({
        'groups': FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupd.update({
        'members': FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  sendMessage(String groupId, Map<String, dynamic> chatMessage) async {
    groupCollections.doc(groupId).collection('messages').add(chatMessage);
    groupCollections.doc(groupId).update({
      'recentMessage': chatMessage['message'],
      'recentMessageSender': chatMessage['sender'],
      'recentMessageData': chatMessage['time'].toString()
    });
  }
}
