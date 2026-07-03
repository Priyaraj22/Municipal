// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'survey_screen.dart';
import 'records_screen.dart';
import 'dashboard_screen.dart';
import 'ward_progress_screen.dart';
import 'all_records_screen.dart';
import 'indicators_screen.dart';
import 'login_screen.dart';
import 'admin_complaints_screen.dart';
import 'surveyor_corrections_screen.dart';
import '../widgets/ai_assistant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _surveyorIndex = 0; // 0 = Survey, 1 = My Records, 2 = Corrections
  int _adminIndex = 0;     // 0 = Dashboard, 1 = Indicators, 2 = Wards, 3 = All Records, 4 = Complaints
  int _correctionCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchCorrectionCount();
  }

  Future<void> _fetchCorrectionCount() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAdmin && auth.collectorName != null) {
      try {
        final res = await ApiService.getSurveyorCorrections(auth.collectorName!);
        if (mounted) setState(() => _correctionCount = res.length);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    final surveyorPages = [
      const SurveyScreen(),
      const RecordsScreen(),
      const SurveyorCorrectionsScreen(),
    ];

    final adminPages = const [
      DashboardScreen(),
      IndicatorsScreen(),
      WardProgressScreen(),
      AllRecordsScreen(),
      AdminComplaintsScreen(),
    ];

    final body = isAdmin ? adminPages[_adminIndex] : surveyorPages[_surveyorIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rajapalayam · Family Survey'),
            Text(
              isAdmin
                  ? '👨‍💼 Admin View'
                  : '🪪 ${auth.collectorName ?? ''} · ${auth.collectorWard ?? ''}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
      ),
      body: body,
      floatingActionButton: isAdmin ? null : const AiAssistantFab(),
      bottomNavigationBar: isAdmin
          ? NavigationBar(
              selectedIndex: _adminIndex,
              onDestinationSelected: (i) => setState(() => _adminIndex = i),
              backgroundColor: AppTheme.white,
              indicatorColor: const Color(0xFFEBF2FF),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: AppTheme.blue),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart, color: AppTheme.blue),
                  label: 'Indicators',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map, color: AppTheme.blue),
                  label: 'Wards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt, color: AppTheme.blue),
                  label: 'All Records',
                ),
                NavigationDestination(
                  icon: Icon(Icons.announcement_outlined),
                  selectedIcon: Icon(Icons.announcement, color: AppTheme.blue),
                  label: 'Complaints',
                ),
              ],
            )
          : NavigationBar(
              selectedIndex: _surveyorIndex,
              onDestinationSelected: (i) => setState(() => _surveyorIndex = i),
              backgroundColor: AppTheme.white,
              indicatorColor: const Color(0xFFEBF2FF),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note, color: AppTheme.blue),
                  label: 'New Survey',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder, color: AppTheme.blue),
                  label: 'My Records',
                ),
                NavigationDestination(
                  icon: Badge(
                    label: Text('$_correctionCount'),
                    isLabelVisible: _correctionCount > 0,
                    child: const Icon(Icons.notification_important_outlined),
                  ),
                  selectedIcon: const Icon(Icons.notification_important, color: AppTheme.blue),
                  label: 'Corrections',
                ),
              ],
            ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
              child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await auth.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}
