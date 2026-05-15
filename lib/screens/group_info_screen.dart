import 'package:flutter/material.dart';
import '../models/app_models.dart';

class GroupInfoScreen extends StatefulWidget {
  final ProjectGroup group;

  const GroupInfoScreen({super.key, required this.group});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  void _removeMember(String memberId) {
    setState(() {
      MockData.removeUserFromGroup(memberId, widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.adminId == MockData.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: ListView.builder(
        itemCount: widget.group.memberIds.length,
        itemBuilder: (context, index) {
          final memberId = widget.group.memberIds[index];
          final user = MockData.users.firstWhere((u) => u.id == memberId, orElse: () => User(id: '', username: 'Unknown', password: '', avatarUrl: ''));

          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
            title: Text(user.username),
            subtitle: Text(memberId == widget.group.adminId ? 'Admin' : 'Member'),
            trailing: (isAdmin && memberId != widget.group.adminId)
                ? IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeMember(memberId),
                  )
                : null,
          );
        },
      ),
    );
  }
}
