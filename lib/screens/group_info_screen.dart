import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class GroupInfoScreen extends StatefulWidget {
  final ProjectGroup group;

  const GroupInfoScreen({super.key, required this.group});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  void _removeMember(String memberId) async {
    await DatabaseService.removeUserFromGroup(widget.group.id, memberId);
    setState(() {
      widget.group.memberIds.remove(memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.adminId == AuthService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
      ),
      body: ListView.builder(
        itemCount: widget.group.memberIds.length,
        itemBuilder: (context, index) {
          final memberId = widget.group.memberIds[index];
          
          return FutureBuilder<User?>(
            future: DatabaseService.getUser(memberId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(title: Text("Loading..."));
              }
              final user = snapshot.data ?? User(id: '', username: 'Unknown', avatarUrl: 'https://i.pravatar.cc/150');

              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                title: Text(user.username, style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  memberId == widget.group.adminId ? 'Admin' : 'Member',
                  style: TextStyle(color: Colors.white54),
                ),
                trailing: (isAdmin && memberId != widget.group.adminId)
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeMember(memberId),
                      )
                    : null,
              );
            }
          );
        },
      ),
    );
  }
}
