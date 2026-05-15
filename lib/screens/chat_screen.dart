import 'package:flutter/material.dart';
import '../models/app_models.dart';
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
  late List<Message> _messages;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _isAdmin = widget.group.adminId == MockData.currentUser?.id;
  }

  void _loadMessages() {
    setState(() {
      _messages = MockData.messages.where((m) => m.groupId == widget.group.id).toList();
      _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: widget.group.id,
      senderId: MockData.currentUser!.id,
      text: text,
      createdAt: DateTime.now(),
    );

    MockData.messages.add(newMessage);
    _loadMessages();
  }

  void _showMessageOptions(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin, color: Colors.white),
                title: const Text('Pin Message', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    widget.group.pinnedMessageId = msg.id;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_box, color: Colors.white),
                title: const Text('Mark as To-Do', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    msg.isTodo = true;
                  });
                  Navigator.pop(context);
                },
              ),
              if (_isAdmin)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    MockData.messages.removeWhere((m) => m.id == msg.id);
                    if (widget.group.pinnedMessageId == msg.id) {
                      widget.group.pinnedMessageId = null;
                    }
                    _loadMessages();
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
          color: AppTheme.surfaceColor,
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
              icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                style: const TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
    Message? pinnedMsg;
    if (widget.group.pinnedMessageId != null) {
      pinnedMsg = MockData.messages.cast<Message?>().firstWhere(
        (m) => m?.id == widget.group.pinnedMessageId,
        orElse: () => null,
      );
    }

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
              if (pinnedMsg != null)
                Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.push_pin, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Pinned: ${pinnedMsg.text}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            widget.group.pinnedMessageId = null;
                          });
                        },
                      )
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 100.0, left: 16, right: 16),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) {
                    final msg = _messages[index];
                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(msg),
                      child: _buildSlackStyleMessage(msg),
                    );
                  },
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
    final sender = MockData.users.firstWhere((u) => u.id == msg.senderId, orElse: () => User(id: '', username: 'Unknown', password: '', avatarUrl: ''));

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
            backgroundImage: NetworkImage(sender.avatarUrl),
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
                      sender.username,
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
                  style: const TextStyle(color: Colors.white70, fontSize: 15.0, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
