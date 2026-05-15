import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'status_feed_screen.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'profile_setup_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // The Dashboard
    const StatusFeedScreen(), // The Highlights
    Center(
      child: ElevatedButton(
        onPressed: () => AuthService.signOut(),
        child: const Text('Sign Out'),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  void _checkProfile() async {
    final firebaseUser = AuthService.currentUser;
    if (firebaseUser != null) {
      final userProfile = await DatabaseService.getUser(firebaseUser.uid);
      if (userProfile == null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation),
            label: 'Highlights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
