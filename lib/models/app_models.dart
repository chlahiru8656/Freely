
class User {
  final String id;
  final String username;
  final String password; // Mock password
  final String avatarUrl;

  User({required this.id, required this.username, required this.password, required this.avatarUrl});
}

class ProjectGroup {
  final String id;
  final String name;
  final String adminId;
  final List<String> memberIds;
  String? pinnedMessageId;

  ProjectGroup({
    required this.id,
    required this.name,
    required this.adminId,
    required this.memberIds,
    this.pinnedMessageId,
  });
}

class Message {
  final String id;
  final String groupId;
  final String senderId;
  final String text;
  bool isTodo;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.text,
    this.isTodo = false,
    required this.createdAt,
  });
}

enum StatusCategory { brainstorming, prototypes, finalOutput }

class StatusHighlight {
  final String id;
  final String groupId;
  final String uploaderId;
  final String mediaUrl;
  final StatusCategory category;
  final DateTime createdAt;

  StatusHighlight({
    required this.id,
    required this.groupId,
    required this.uploaderId,
    required this.mediaUrl,
    required this.category,
    required this.createdAt,
  });
}

class Comment {
  final String id;
  final String statusId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.statusId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });
}

class MockData {
  static User? currentUser;

  static List<User> users = [
    User(id: 'u1', username: 'alice', password: 'password', avatarUrl: 'https://i.pravatar.cc/150?u=1'),
    User(id: 'u2', username: 'bob', password: 'password', avatarUrl: 'https://i.pravatar.cc/150?u=2'),
    User(id: 'u3', username: 'charlie', password: 'password', avatarUrl: 'https://i.pravatar.cc/150?u=3'),
  ];

  static List<ProjectGroup> groups = [
    ProjectGroup(id: 'g1', name: 'Engineering Project', adminId: 'u1', memberIds: ['u1', 'u2', 'u3']),
    ProjectGroup(id: 'g2', name: 'UI/UX Design Team', adminId: 'u2', memberIds: ['u1', 'u2']),
  ];

  static List<Message> messages = [
    Message(id: 'm1', groupId: 'g1', senderId: 'u2', text: 'Hey team, lets start the backend design.', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
    Message(id: 'm2', groupId: 'g1', senderId: 'u3', text: 'I have prepared the initial schema.', createdAt: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  static List<StatusHighlight> highlights = [
    StatusHighlight(
      id: 'h1', 
      groupId: 'g1', 
      uploaderId: 'u1', 
      mediaUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60', 
      category: StatusCategory.brainstorming, 
      createdAt: DateTime.now().subtract(const Duration(days: 1))
    ),
    StatusHighlight(
      id: 'h2', 
      groupId: 'g2', 
      uploaderId: 'u2', 
      mediaUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60', 
      category: StatusCategory.prototypes, 
      createdAt: DateTime.now().subtract(const Duration(hours: 5))
    ),
  ];

  static List<Comment> comments = [
    Comment(id: 'c1', statusId: 'h1', senderId: 'u2', text: 'Looks like a great start!', createdAt: DateTime.now()),
  ];

  // Dynamic Data Cleanup Protocol
  static void removeUserFromGroup(String userId, String groupId) {
    // 1. Remove from group memberIds
    var group = groups.firstWhere((g) => g.id == groupId);
    group.memberIds.remove(userId);

    // 2. Delete all their statuses in this group
    highlights.removeWhere((h) => h.uploaderId == userId && h.groupId == groupId);
  }
}
