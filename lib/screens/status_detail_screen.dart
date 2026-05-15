import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';

class StatusDetailScreen extends StatefulWidget {
  final StatusHighlight highlight;

  const StatusDetailScreen({super.key, required this.highlight});

  @override
  State<StatusDetailScreen> createState() => _StatusDetailScreenState();
}

class _StatusDetailScreenState extends State<StatusDetailScreen> {
  final _commentController = TextEditingController();
  late List<Comment> _comments;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    setState(() {
      _comments = MockData.comments.where((c) => c.statusId == widget.highlight.id).toList();
      _comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  void _submitComment(String text) {
    if (text.trim().isEmpty) return;
    _commentController.clear();
    
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      statusId: widget.highlight.id,
      senderId: MockData.currentUser!.id,
      text: text,
      createdAt: DateTime.now(),
    );
    MockData.comments.add(newComment);
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final uploader = MockData.users.firstWhere((u) => u.id == widget.highlight.uploaderId, orElse: () => User(id: '', username: 'Unknown', password: '', avatarUrl: ''));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(uploader.avatarUrl), radius: 16),
            const SizedBox(width: 8),
            Text(uploader.username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: InteractiveViewer(
              child: Image.network(widget.highlight.mediaUrl, fit: BoxFit.contain),
            ),
          ),
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Thread: ${widget.highlight.category.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      final sender = MockData.users.firstWhere((u) => u.id == comment.senderId, orElse: () => User(id: '', username: 'Unknown', password: '', avatarUrl: ''));
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(sender.avatarUrl), radius: 14),
                        title: Text(sender.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text(comment.text),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            border: InputBorder.none,
                          ),
                          onSubmitted: _submitComment,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.secondaryColor),
                        onPressed: () => _submitComment(_commentController.text),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
