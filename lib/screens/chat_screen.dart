import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'group_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final ProjectGroup group;

  const ChatScreen({super.key, required this.group});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isAdmin = false;
  late Stream<List<Message>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = DatabaseService.streamMessages(widget.group.id);
    _isAdmin = widget.group.adminId == AuthService.currentUser?.uid;
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simplified ID for now
      groupId: widget.group.id,
      senderId: AuthService.currentUser!.uid,
      text: text,
      createdAt: DateTime.now(),
    );

    await DatabaseService.sendMessage(newMessage);
  }

  void _showMessageOptions(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.push_pin, color: Colors.white),
                title: Text('Pin Message', style: TextStyle(color: Colors.white)),
                onTap: () {
                  DatabaseService.updateGroupPinnedMessage(widget.group.id, msg.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_box, color: Colors.white),
                title: Text('Toggle To-Do', style: TextStyle(color: Colors.white)),
                onTap: () {
                  DatabaseService.toggleMessageTodo(msg.id, !msg.isTodo);
                  Navigator.pop(context);
                },
              ),
              if (_isAdmin)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    DatabaseService.deleteMessage(msg.id);
                    if (widget.group.pinnedMessageId == msg.id) {
                      DatabaseService.updateGroupPinnedMessage(widget.group.id, null);
                    }
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.white54),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Message team...",
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We should ideally stream the ProjectGroup as well to instantly reflect pinned message changes,
    // but for this example, we'll keep it simple or reload if needed.
    // For full reactivity, group should also be a StreamBuilder.
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupInfoScreen(group: widget.group),
                ),
              ).then((_) => setState(() {})); 
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              // Pinned message ideally needs a stream to stay perfectly in sync
              if (widget.group.pinnedMessageId != null)
                Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.push_pin, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Pinned message attached",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white54),
                        onPressed: () {
                           DatabaseService.updateGroupPinnedMessage(widget.group.id, null);
                           setState(() { widget.group.pinnedMessageId = null; });
                        },
                      )
                    ],
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No messages yet."));
                    }
                    
                    final messages = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 100.0, left: 16, right: 16),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (_, int index) {
                        final msg = messages[index];
                        return GestureDetector(
                          onLongPress: () => _showMessageOptions(msg),
                          child: _buildSlackStyleMessage(msg),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFloatingInput(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlackStyleMessage(Message msg) {
    return FutureBuilder<User?>(
      future: DatabaseService.getUser(msg.senderId),
      builder: (context, snapshot) {
        final sender = snapshot.data;
        final username = sender?.username ?? 'Loading...';
        final avatar = sender?.avatarUrl ?? 'https://i.pravatar.cc/150';

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: msg.isTodo ? const EdgeInsets.all(12) : null,
          decoration: msg.isTodo 
            ? BoxDecoration(
                border: Border.all(color: Colors.orangeAccent, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.orangeAccent.withValues(alpha: 0.05),
              ) 
            : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(avatar),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 12, color: Colors.white38),
                        ),
                        if (msg.isTodo) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(4)),
                            child: const Text("TO-DO", style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.text,
                      style: TextStyle(color: Colors.white70, fontSize: 15.0, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
