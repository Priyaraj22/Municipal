// screens/home_screen.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'survey_screen.dart';
import 'records_screen.dart';
import '../widgets/ai_assistant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0; // 0 = New Survey, 1 = My Records

  final List<Widget> _pages = const [
    SurveyScreen(),
    RecordsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rajapalayam · Local Family Survey'),
        centerTitle: true,
      ),
      body: _pages[_tabIndex],
      floatingActionButton: const AiAssistantFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        backgroundColor: AppTheme.white,
        indicatorColor: const Color(0xFFEBF2FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note, color: AppTheme.blue),
            label: 'New Survey',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder, color: AppTheme.blue),
            label: 'Saved Records',
          ),
        ],
      ),
    );
  }
}
