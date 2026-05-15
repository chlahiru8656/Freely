import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';


class CreateStatusScreen extends StatefulWidget {
  final List<ProjectGroup> userGroups;

  const CreateStatusScreen({super.key, required this.userGroups});

  @override
  State<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends State<CreateStatusScreen> {
  final _urlController = TextEditingController();
  ProjectGroup? _selectedGroup;
  StatusCategory _selectedCategory = StatusCategory.brainstorming;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userGroups.isNotEmpty) {
      _selectedGroup = widget.userGroups.first;
    }
  }

  void _submitStatus() async {
    if (_urlController.text.trim().isEmpty || _selectedGroup == null) return;
    
    setState(() { _isLoading = true; });

    final newHighlight = StatusHighlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: _selectedGroup!.id,
      uploaderId: AuthService.currentUser!.uid,
      mediaUrl: _urlController.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    await DatabaseService.createHighlight(newHighlight);
    
    if (mounted) {
      Navigator.pop(context); // Go back to feed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Highlight'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitStatus,
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
              : Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              items: widget.userGroups.map((g) {
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
            Icon(Icons.image, size: 100, color: Colors.grey.shade800),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
