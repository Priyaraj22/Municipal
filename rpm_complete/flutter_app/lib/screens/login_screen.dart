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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collectorNameCtrl = TextEditingController();
  String? _selectedWard;
  List<String> _wardNames = [];
  bool _loadingWards = true;

  final _adminPassCtrl = TextEditingController();
  bool _showPass = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    try {
      await context.read<AuthProvider>().loginCollector(name, [_selectedWard!]);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) showToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAdmin() async {
    final pass = _adminPassCtrl.text;
    if (pass.isEmpty) {
      showToast(context, 'Please enter admin password', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().loginAdmin(pass);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) showToast(context, 'Invalid password', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginCitizen(String phone) async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().loginCitizen(phone);
      if (mounted) Navigator.pushReplacementNamed(context, '/'); 
    } catch (e) {
      if (mounted) showToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _collectorNameCtrl.dispose();
    _adminPassCtrl.dispose();
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
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: AppTheme.blue,
                          unselectedLabelColor: AppTheme.ink3,
                          indicatorColor: AppTheme.blue,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: '📋 Surveyor'),
                            Tab(text: '👨‍💼 Admin'),
                            Tab(text: '🏠 Citizen'),
                          ],
                        ),
                        SizedBox(
                          height: 380,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSurveyorTab(),
                              _AdminTab(
                                passCtrl: _adminPassCtrl,
                                onLogin: _isLoading ? null : _loginAdmin,
                                isLoading: _isLoading,
                              ),
                              _CitizenTab(
                                onLogin: _loginCitizen,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
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
      padding: const EdgeInsets.all(20),
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
            child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Text('Start Collection'),
          ),
        ],
      ),
    );
  }
}

class _AdminTab extends StatelessWidget {
  final TextEditingController passCtrl;
  final VoidCallback? onLogin;
  final bool isLoading;
  const _AdminTab({required this.passCtrl, this.onLogin, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Admin Password', prefixIcon: Icon(Icons.lock)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue),
            child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Admin Login'),
          ),
        ],
      ),
    );
  }
}

class _CitizenTab extends StatefulWidget {
  final Function(String) onLogin;
  final bool isLoading;
  const _CitizenTab({required this.onLogin, required this.isLoading});

  @override
  State<_CitizenTab> createState() => _CitizenTabState();
}

class _CitizenTabState extends State<_CitizenTab> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  String? _serverOtp;

  void _requestOtp() async {
    if (_phoneCtrl.text.length < 10) {
      showToast(context, 'Enter valid phone number', isError: true);
      return;
    }
    try {
      final res = await ApiService.requestOtp(_phoneCtrl.text.trim());
      setState(() {
        _otpSent = true;
        _serverOtp = res['otp']?.toString();
      });
      showToast(context, 'OTP generated (Check terminal)');
    } catch (e) {
      showToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Citizen Portal Login', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.blue)),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
          ),
          if (_otpSent) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP', prefixIcon: Icon(Icons.lock_clock)),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : (_otpSent ? () {
              if (_otpCtrl.text == _serverOtp) {
                widget.onLogin(_phoneCtrl.text.trim());
              } else {
                showToast(context, 'Invalid OTP', isError: true);
              }
            } : _requestOtp),
            child: widget.isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_otpSent ? 'Verify & Login' : 'Get OTP'),
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
          const Text('Family Survey System', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
