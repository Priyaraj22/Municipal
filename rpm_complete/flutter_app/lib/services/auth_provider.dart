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

  Future<bool> loginSurveyor(String name, String password) async {
    // Check if the password provided is in the list of 20 valid passwords
    if (VALID_SURVEYOR_PASSWORDS.contains(password.trim())) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rpm_collector_name', name);

      _state = AuthState(
        isLoggedIn: true,
        collectorName: name,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rpm_collector_name');

    _state = const AuthState();
    notifyListeners();
  }
}
