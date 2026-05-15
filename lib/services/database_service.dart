import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Users ---
  static Future<void> createUserProfile(User user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  static Future<User?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<User>> searchUsers(String query, String currentUserId) async {
    if (query.trim().isEmpty) return [];
    
    // Firestore "starts-with" query on 'username' field
    final endQuery = '${query.trim()}\uf8ff';
    
    final snapshot = await _db.collection('users')
        .where('username', isGreaterThanOrEqualTo: query.trim())
        .where('username', isLessThan: endQuery)
        .limit(20)
        .get();
        
    return snapshot.docs
        .map((doc) => User.fromJson(doc.data()))
        .where((user) => user.id != currentUserId) // Exclude current user
        .toList();
  }

  // --- Groups ---
  static Stream<List<ProjectGroup>> streamUserGroups(String userId) {
    return _db
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectGroup.fromJson(doc.data()))
            .toList());
  }

  static Future<void> createGroup(ProjectGroup group) async {
    await _db.collection('groups').doc(group.id).set(group.toJson());
  }
  
  static Future<void> updateGroupPinnedMessage(String groupId, String? messageId) async {
    await _db.collection('groups').doc(groupId).update({'pinnedMessageId': messageId});
  }
  
  static Future<void> removeUserFromGroup(String groupId, String userId) async {
    await _db.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId])
    });
    
    // Cleanup highlights uploaded by this user in this group
    final highlightsSnapshot = await _db
        .collection('highlights')
        .where('groupId', isEqualTo: groupId)
        .where('uploaderId', isEqualTo: userId)
        .get();
        
    for (var doc in highlightsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- Messages ---
  static Stream<List<Message>> streamMessages(String groupId) {
    return _db
        .collection('messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  static Future<void> sendMessage(Message message) async {
    await _db.collection('messages').doc(message.id).set(message.toJson());
  }
  
  static Future<void> deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }
  
  static Future<void> toggleMessageTodo(String messageId, bool isTodo) async {
    await _db.collection('messages').doc(messageId).update({'isTodo': isTodo});
  }

  // --- Highlights ---
  static Stream<List<StatusHighlight>> streamHighlights(String groupId) {
    return _db
        .collection('highlights')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StatusHighlight.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<StatusHighlight>> streamAllUserHighlights(String userId) {
    // Note: Firestore requires a composite index for complex queries, or we can fetch groups first.
    // For simplicity, we can just listen to highlights if we have the list of groupIds.
    // However, array-contains-any is limited to 10. We'll simplify this in the UI.
    return const Stream.empty(); // Implemented locally in UI for now
  }

  static Future<void> createHighlight(StatusHighlight highlight) async {
    await _db.collection('highlights').doc(highlight.id).set(highlight.toJson());
  }

  // --- Comments ---
  static Stream<List<Comment>> streamComments(String statusId) {
    return _db
        .collection('comments')
        .where('statusId', isEqualTo: statusId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList());
  }

  static Future<void> sendComment(Comment comment) async {
    await _db.collection('comments').doc(comment.id).set(comment.toJson());
  }
}
