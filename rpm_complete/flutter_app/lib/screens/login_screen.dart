// screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _collectorNameCtrl = TextEditingController();
  String? _selectedWard;
  List<String> _wardNames = [];
  bool _loadingWards = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWards();
  }

  Future<void> _loadWards() async {
    try {
      final wards = await ApiService.getWards();
      setState(() {
        _wardNames = wards.map((w) => w.wardName).toList();
        _loadingWards = false;
      });
    } catch (e) {
      setState(() {
        _wardNames = List.generate(42, (i) => 'Ward ${i + 1}');
        _loadingWards = false;
      });
    }
  }

  Future<void> _loginCollector() async {
    final name = _collectorNameCtrl.text.trim();
    if (name.isEmpty) {
      showToast(context, 'Please enter your name', isError: true);
      return;
    }
    if (_selectedWard == null) {
      showToast(context, 'Please select your ward', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await context.read<AuthProvider>().loginCollectorLocal(name, _selectedWard!);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _collectorNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _HeaderSection(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            '📋 Surveyor Login',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.blue),
                          ),
                        ),
                        _buildSurveyorTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyorTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _collectorNameCtrl,
            decoration: const InputDecoration(labelText: 'Your Name / உங்கள் பெயர் *'),
          ),
          const SizedBox(height: 14),
          _loadingWards
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedWard,
                  hint: const Text('— Select Ward —'),
                  decoration: const InputDecoration(labelText: 'Select Assigned Ward *'),
                  items: _wardNames.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setState(() => _selectedWard = v),
                ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _loginCollector,
            child: const Text('Start Local Collection'),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(color: AppTheme.blue, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const Text('🏛', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text('Rajapalayam Municipality', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Local Family Survey', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
