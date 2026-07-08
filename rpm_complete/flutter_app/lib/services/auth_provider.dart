// services/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_models.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;
  bool get isLoggedIn => _state.isLoggedIn;
  String? get collectorName => _state.collectorName;
  String? get collectorWard => _state.collectorWard;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('rpm_collector_name');
    final ward = prefs.getString('rpm_collector_ward');

    if (name != null) {
      _state = AuthState(
        isLoggedIn: true,
        collectorName: name,
        collectorWard: ward,
      );
      notifyListeners();
    }
  }

  Future<void> loginCollectorLocal(String name, String ward) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_collector_name', name);
    await prefs.setString('rpm_collector_ward', ward);

    _state = AuthState(
      isLoggedIn: true,
      collectorName: name,
      collectorWard: ward,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rpm_collector_name');
    await prefs.remove('rpm_collector_ward');

    _state = const AuthState();
    notifyListeners();
  }
}
