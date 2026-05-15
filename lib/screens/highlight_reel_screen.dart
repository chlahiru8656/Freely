import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'status_detail_screen.dart';

class HighlightReelScreen extends StatelessWidget {
  final ProjectGroup group;

  const HighlightReelScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} Highlights'),
      ),
      body: StreamBuilder<List<StatusHighlight>>(
        stream: DatabaseService.streamHighlights(group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No highlights yet. Add one!"));
          }

          final groupHighlights = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groupHighlights.length,
            itemBuilder: (context, index) {
              final highlight = groupHighlights[index];
              
              return FutureBuilder<User?>(
                future: DatabaseService.getUser(highlight.uploaderId),
                builder: (context, userSnapshot) {
                  final uploader = userSnapshot.data ?? User(id: '', username: 'Unknown', avatarUrl: 'https://i.pravatar.cc/150');

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusDetailScreen(highlight: highlight),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  highlight.mediaUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.secondaryColor, width: 1),
                                  ),
                                  child: Text(
                                    highlight.category.name.toUpperCase(),
                                    style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(uploader.avatarUrl),
                                  radius: 16,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(uploader.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Posted ${highlight.createdAt.day}/${highlight.createdAt.month}/${highlight.createdAt.year}",
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.comment, color: Colors.white54, size: 20),
                                const SizedBox(width: 4),
                                StreamBuilder<List<Comment>>(
                                  stream: DatabaseService.streamComments(highlight.id),
                                  builder: (context, commentSnap) {
                                    final count = commentSnap.data?.length ?? 0;
                                    return Text(
                                      "$count",
                                      style: TextStyle(color: Colors.white54),
                                    );
                                  }
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
          );
        }
      ),
    );
  }
}
