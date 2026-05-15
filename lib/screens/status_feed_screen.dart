import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'highlight_reel_screen.dart';
import 'create_status_screen.dart';

class StatusFeedScreen extends StatelessWidget {
  const StatusFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        ],
      ),
      body: currentUserId == null 
        ? const Center(child: Text("Please sign in."))
        : StreamBuilder<List<ProjectGroup>>(
            stream: DatabaseService.streamUserGroups(currentUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No groups available."));
              }

              final userGroups = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userGroups.length,
                itemBuilder: (context, index) {
                  final group = userGroups[index];
                  
                  // For each group, we stream its highlights to get the count
                  return StreamBuilder<List<StatusHighlight>>(
                    stream: DatabaseService.streamHighlights(group.id),
                    builder: (context, highlightSnap) {
                      final groupHighlights = highlightSnap.data ?? [];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HighlightReelScreen(group: group)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: groupHighlights.isNotEmpty ? AppTheme.secondaryColor.withValues(alpha: 0.2) : Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: groupHighlights.isNotEmpty ? AppTheme.secondaryColor : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(Icons.movie_filter, color: groupHighlights.isNotEmpty ? AppTheme.secondaryColor : Colors.white54, size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      const SizedBox(height: 4),
                                      Text(
                                        groupHighlights.isNotEmpty ? "${groupHighlights.length} updates" : "No recent updates",
                                        style: TextStyle(color: groupHighlights.isNotEmpty ? AppTheme.secondaryColor : Colors.white54),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.white54),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );
                },
              );
            }
          ),
      floatingActionButton: StreamBuilder<List<ProjectGroup>>(
        stream: currentUserId != null ? DatabaseService.streamUserGroups(currentUserId) : const Stream.empty(),
        builder: (context, snapshot) {
          final groups = snapshot.data ?? [];
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateStatusScreen(userGroups: groups)),
              );
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text("New Highlight", style: TextStyle(fontWeight: FontWeight.bold)),
          );
        }
      ),
    );
  }
}
