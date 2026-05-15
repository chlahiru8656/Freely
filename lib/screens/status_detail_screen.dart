import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class StatusDetailScreen extends StatefulWidget {
  final StatusHighlight highlight;

  const StatusDetailScreen({super.key, required this.highlight});

  @override
  State<StatusDetailScreen> createState() => _StatusDetailScreenState();
}

class _StatusDetailScreenState extends State<StatusDetailScreen> {
  final _commentController = TextEditingController();

  void _submitComment(String text) async {
    if (text.trim().isEmpty) return;
    _commentController.clear();
    
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      statusId: widget.highlight.id,
      senderId: AuthService.currentUser!.uid,
      text: text,
      createdAt: DateTime.now(),
    );
    
    await DatabaseService.sendComment(newComment);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: DatabaseService.getUser(widget.highlight.uploaderId),
      builder: (context, snapshot) {
        final uploader = snapshot.data ?? User(id: '', username: 'Unknown', avatarUrl: 'https://i.pravatar.cc/150');

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
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                    const Divider(height: 1, color: Colors.white24),
                    Expanded(
                      child: StreamBuilder<List<Comment>>(
                        stream: DatabaseService.streamComments(widget.highlight.id),
                        builder: (context, commentSnap) {
                          if (!commentSnap.hasData || commentSnap.data!.isEmpty) {
                            return const Center(child: Text("No comments yet.", style: TextStyle(color: Colors.white54)));
                          }
                          final comments = commentSnap.data!;
                          return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return FutureBuilder<User?>(
                                future: DatabaseService.getUser(comment.senderId),
                                builder: (context, userSnap) {
                                  final sender = userSnap.data ?? User(id: '', username: 'Unknown', avatarUrl: 'https://i.pravatar.cc/150');
                                  return ListTile(
                                    leading: CircleAvatar(backgroundImage: NetworkImage(sender.avatarUrl), radius: 14),
                                    title: Text(sender.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                    subtitle: Text(comment.text, style: TextStyle(color: Colors.white70)),
                                  );
                                }
                              );
                            },
                          );
                        }
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white24),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                border: InputBorder.none,
                                filled: false,
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
    );
  }
}
