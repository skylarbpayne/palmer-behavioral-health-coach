import 'package:flutter/material.dart';
import 'screens/health_summary_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/debug_screen.dart';

void main() {
  runApp(const PalmerApp());
}

class PalmerApp extends StatelessWidget {
  const PalmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Palmer Behavioral Health Coach',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HealthSummaryScreen(),
    ChatScreen(),
    DebugScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report),
            label: 'Debug',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4CAF50),
        onTap: _onItemTapped,
      ),
    );
  }
}
