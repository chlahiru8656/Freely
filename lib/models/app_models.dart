class User {
  final String id;
  final String username;
  final String? phoneNumber;
  final String avatarUrl;

  User({
    required this.id,
    required this.username,
    this.phoneNumber,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
    };
  }
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

  factory ProjectGroup.fromJson(Map<String, dynamic> json) {
    return ProjectGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      adminId: json['adminId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      pinnedMessageId: json['pinnedMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'adminId': adminId,
      'memberIds': memberIds,
      'pinnedMessageId': pinnedMessageId,
    };
  }
}

class Message {
  final String id;
  final String groupId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  bool isTodo;

  Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isTodo = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isTodo: json['isTodo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isTodo': isTodo,
    };
  }
}

enum StatusCategory {
  brainstorming,
  prototypes,
  finalOutput
}

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

  factory StatusHighlight.fromJson(Map<String, dynamic> json) {
    return StatusHighlight(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      uploaderId: json['uploaderId'] as String,
      mediaUrl: json['mediaUrl'] as String,
      category: StatusCategory.values.firstWhere((e) => e.name == json['category']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'uploaderId': uploaderId,
      'mediaUrl': mediaUrl,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      statusId: json['statusId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statusId': statusId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Temporary MockData stub. We will remove this once DatabaseService is fully active,
// but keep it for now so compilation doesn't break while we migrate screens one by one.
class MockData {
  static User? currentUser;
  static List<User> users = [];
  static List<ProjectGroup> groups = [];
  static List<Message> messages = [];
  static List<StatusHighlight> highlights = [];
  static List<Comment> comments = [];

  static void removeUserFromGroup(String userId, String groupId) {}
}
