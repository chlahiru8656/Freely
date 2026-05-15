import 'package:flutter/material.dart';
import '../models/app_models.dart';


class CreateStatusScreen extends StatefulWidget {
  const CreateStatusScreen({super.key});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final _urlController = TextEditingController();
  ProjectGroup? _selectedGroup;
  StatusCategory _selectedCategory = StatusCategory.brainstorming;

  @override
  void initState() {
    super.initState();
    final userGroups = MockData.groups.where((g) => g.memberIds.contains(MockData.currentUser?.id)).toList();
    if (userGroups.isNotEmpty) {
      _selectedGroup = userGroups.first;
    }
  }

  void _submitStatus() {
    if (_urlController.text.trim().isEmpty || _selectedGroup == null) return;
    
    final newHighlight = StatusHighlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: _selectedGroup!.id,
      uploaderId: MockData.currentUser!.id,
      mediaUrl: _urlController.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    MockData.highlights.add(newHighlight);
    Navigator.pop(context); // Go back to feed
  }

  @override
  Widget build(BuildContext context) {
    final userGroups = MockData.groups.where((g) => g.memberIds.contains(MockData.currentUser?.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Highlight'),
        actions: [
          TextButton(
            onPressed: _submitStatus,
            child: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Image/Video URL',
                border: OutlineInputBorder(),
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 24),
            const Text("Select Project Group", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<ProjectGroup>(
              value: _selectedGroup,
              isExpanded: true,
              items: userGroups.map((g) {
                return DropdownMenuItem(
                  value: g,
                  child: Text(g.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedGroup = val);
              },
            ),
            const SizedBox(height: 24),
            const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<StatusCategory>(
              value: _selectedCategory,
              isExpanded: true,
              items: StatusCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const Spacer(),
            Icon(Icons.image, size: 100, color: Colors.grey.shade300),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
