import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'status_detail_screen.dart';

class HighlightReelScreen extends StatelessWidget {
  final ProjectGroup group;

  const HighlightReelScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final groupHighlights = MockData.highlights.where((h) => h.groupId == group.id).toList();
    // Sort by newest first
    groupHighlights.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} Highlights'),
      ),
      body: groupHighlights.isEmpty
          ? const Center(child: Text("No highlights yet. Add one!"))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: groupHighlights.length,
              itemBuilder: (context, index) {
                final highlight = groupHighlights[index];
                final uploader = MockData.users.firstWhere((u) => u.id == highlight.uploaderId, orElse: () => User(id: '', username: 'Unknown', password: '', avatarUrl: ''));

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
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.comment, color: Colors.white54, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${MockData.comments.where((c) => c.statusId == highlight.id).length}",
                                style: const TextStyle(color: Colors.white54),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
