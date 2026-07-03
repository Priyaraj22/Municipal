// services/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_models.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;
  bool get isLoggedIn => _state.isLoggedIn;
  bool get isAdmin => _state.isAdmin;
  bool get isCitizen => _state.isCitizen;
  String? get collectorName => _state.collectorName;
  String? get collectorWard => _state.collectorWard;
  String? get citizenPhone => _state.citizenPhone;
  String? get surveyId => _state.surveyId;

  // ── Persist session across app restarts ──
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('rpm_survey_token');
    final isAdmin = prefs.getBool('rpm_is_admin') ?? false;
    final isCitizen = prefs.getBool('rpm_is_citizen') ?? false;
    final name = prefs.getString('rpm_collector_name');
    final ward = prefs.getString('rpm_collector_ward');
    final phone = prefs.getString('rpm_citizen_phone');
    final sId = prefs.getString('rpm_citizen_survey_id');

    if (token != null && token.isNotEmpty) {
      _state = AuthState(
        isLoggedIn: true,
        isAdmin: isAdmin,
        isCitizen: isCitizen,
        collectorName: name,
        collectorWard: ward,
        citizenPhone: phone,
        surveyId: sId,
        token: token,
      );
      notifyListeners();
    }
  }

  Future<void> loginCollector(String name, List<String> wards) async {
    // Note: API now expects single string but we send List[0] for compatibility with UI call
    final res = await ApiService.loginCollector(name, wards[0]);
    final token = res['token'] as String?;
    await ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_survey_token', token ?? '');
    await prefs.setBool('rpm_is_admin', false);
    await prefs.setBool('rpm_is_citizen', false);
    await prefs.setString('rpm_collector_name', name);
    await prefs.setString('rpm_collector_ward', wards[0]);

    _state = AuthState(
      isLoggedIn: true,
      isAdmin: false,
      isCitizen: false,
      collectorName: name,
      collectorWard: wards[0],
      token: token,
    );
    notifyListeners();
  }

  Future<void> loginAdmin(String password) async {
    final res = await ApiService.loginAdmin(password);
    final token = res['token'] as String?;
    await ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_survey_token', token ?? '');
    await prefs.setBool('rpm_is_admin', true);
    await prefs.setBool('rpm_is_citizen', false);
    await prefs.remove('rpm_collector_name');
    await prefs.remove('rpm_collector_ward');

    _state = AuthState(
      isLoggedIn: true,
      isAdmin: true,
      isCitizen: false,
      token: token,
    );
    notifyListeners();
  }

  Future<void> loginCitizen(String phone) async {
    final res = await ApiService.loginCitizen(phone);
    final token = res['token'] as String?;
    final sId = res['surveyId']?.toString();
    await ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rpm_survey_token', token ?? '');
    await prefs.setBool('rpm_is_admin', false);
    await prefs.setBool('rpm_is_citizen', true);
    await prefs.setString('rpm_citizen_phone', phone);
    await prefs.setString('rpm_citizen_survey_id', sId ?? '');

    _state = AuthState(
      isLoggedIn: true,
      isAdmin: false,
      isCitizen: true,
      citizenPhone: phone,
      surveyId: sId,
      token: token,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rpm_survey_token');
    await prefs.remove('rpm_is_admin');
    await prefs.remove('rpm_is_citizen');
    await prefs.remove('rpm_collector_name');
    await prefs.remove('rpm_collector_ward');
    await prefs.remove('rpm_citizen_phone');
    await prefs.remove('rpm_citizen_survey_id');

    _state = const AuthState();
    notifyListeners();
  }
}
