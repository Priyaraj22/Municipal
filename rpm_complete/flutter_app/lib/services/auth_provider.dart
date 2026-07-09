// services/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_models.dart';
import '../models/surveyor_accounts.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;
  bool get isLoggedIn => _state.isLoggedIn;
  String? get collectorName => _state.collectorName;

  // Single default account (admin)
  static const String ADMIN_USERNAME = 'admin';
  static const String ADMIN_PASSWORD = '123';

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('rpm_collector_name');

    if (name != null) {
      _state = AuthState(
        isLoggedIn: true,
        collectorName: name,
      );
      notifyListeners();
    }
  }

  Future<bool> loginSurveyor(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    // 1. Check against the admin account
    if (u == ADMIN_USERNAME && p == ADMIN_PASSWORD) {
      return _saveSession(ADMIN_USERNAME);
    }

    // 2. Check against the list of 20 default accounts
    final account = SURVEYOR_ACCOUNTS.firstWhere(
      (a) => a.username == u && a.password == p,
      orElse: () => const SurveyorAccount('', ''),
    );

    if (account.username.isNotEmpty) {
      return _saveSession(account.username);
    }
    
    return false;
  }

  Future<bool> _saveSession(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_collector_name', name);

    _state = AuthState(
      isLoggedIn: true,
      collectorName: name,
    );
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rpm_collector_name');

    _state = const AuthState();
    notifyListeners();
  }
}
