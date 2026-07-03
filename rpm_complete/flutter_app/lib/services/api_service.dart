// services/api_service.dart
// REST layer — mirrors the Express backend routes exactly.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_models.dart';

class ApiService {
  // ── CONFIGURE YOUR SERVER URL ──────────────────────────────────────────────
  // Set this to your machine's LAN IP before building the APK.
  // Example: 'http://192.168.1.100:3000/api'
  static String baseUrl = 'http://172.16.147.122:3000/api';

  static const String _tokenKey = 'rpm_survey_token';

  // ── Token ──────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  // ── Core HTTP wrapper ──────────────────────────────────────────────────────
  static Future<dynamic> _fetch(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = Uri.parse('$baseUrl$path');
    http.Response response;

    try {
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: json.encode(body ?? {}))
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: json.encode(body ?? {}))
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
          break;
        default:
          response = await http.get(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
      }
    } catch (e) {
      throw ApiException('Network error — is the server running at $baseUrl?', 0);
    }

    dynamic parsed;
    if (response.body.isNotEmpty) {
      try {
        parsed = json.decode(response.body);
      } catch (_) {
        parsed = null;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = (parsed is Map)
          ? (parsed['error'] ?? parsed['message'] ?? 'Request failed (${response.statusCode})')
          : 'Request failed (${response.statusCode})';
      throw ApiException(msg.toString(), response.statusCode);
    }

    return parsed;
  }

  // ════ AUTH ═════════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> loginCollector(String name, String ward) async {
    final r = await _fetch('/auth/login',
        method: 'POST', body: {'role': 'collector', 'name': name, 'ward': ward});
    return r as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loginAdmin(String password) async {
    final r = await _fetch('/auth/login',
        method: 'POST', body: {'role': 'admin', 'password': password});
    return r as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> loginCitizen(String phone) async {
    final r = await _fetch('/auth/login',
        method: 'POST', body: {'role': 'citizen', 'phone': phone});
    return r as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> requestOtp(String phone) async {
    final r = await _fetch('/auth/request-otp',
        method: 'POST', body: {'phone': phone});
    return r as Map<String, dynamic>;
  }

  // ════ COMPLAINTS ════════════════════════════════════════════════════════════
  static Future<void> registerComplaint(Map<String, dynamic> data) async {
    await _fetch('/complaints', method: 'POST', body: data);
  }

  static Future<List<Complaint>> getMyComplaints(String phone) async {
    final r = await _fetch('/complaints/my?phone=${Uri.encodeComponent(phone)}');
    final list = r as List;
    return list.map((c) => Complaint.fromJson(c as Map<String, dynamic>)).toList();
  }

  static Future<void> updateComplaintStatus(int id, String status) async {
    await _fetch('/complaints/status', method: 'PUT', body: {'id': id, 'status': status});
  }

  static Future<void> submitComplaintFeedback(int id, String status, {String? feedback, int? rating}) async {
    await _fetch('/complaints/feedback', method: 'PUT', body: {
      'id': id,
      'status': status,
      'feedback': feedback,
      'rating': rating,
    });
  }

  // ════ CORRECTIONS ══════════════════════════════════════════════════════════
  static Future<void> requestCorrection(Map<String, dynamic> data) async {
    await _fetch('/complaints/corrections', method: 'POST', body: data);
  }

  static Future<List<CorrectionRequest>> getSurveyorCorrections(String name) async {
    final r = await _fetch('/complaints/corrections/surveyor?name=${Uri.encodeComponent(name)}');
    final list = r as List;
    return list.map((c) => CorrectionRequest.fromJson(c as Map<String, dynamic>)).toList();
  }

  static Future<void> approveCorrection(int id) async {
    await _fetch('/complaints/corrections/$id/approve', method: 'PUT');
  }


  // ════ WARDS ════════════════════════════════════════════════════════════════
  // GET /api/wards → JSON array of {id, ward_no, ward_name, lgd_code}
  static Future<List<Ward>> getWards() async {
    final r = await _fetch('/wards');
    final list = r as List;
    return list.map((w) => Ward.fromJson(w as Map<String, dynamic>)).toList();
  }

  // GET /api/wards/progress → JSON array
  static Future<List<Map<String, dynamic>>> getWardProgress() async {
    final r = await _fetch('/wards/progress');
    return List<Map<String, dynamic>>.from(r as List);
  }

  // ════ SURVEYS ═══════════════════════════════════════════════════════════════
  // GET /api/surveys[?ward=...&collector=...] → JSON array
  static Future<List<Survey>> getSurveys({String? ward, String? collector}) async {
    final params = <String, String>{};
    if (ward != null && ward.isNotEmpty)      params['ward']      = ward;
    if (collector != null && collector.isNotEmpty) params['collector'] = collector;
    final qs = params.isNotEmpty
        ? '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')
        : '';
    final r = await _fetch('/surveys$qs');
    final list = r as List;
    return list.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList();
  }

  // POST /api/surveys → single survey object
  static Future<Survey> createSurvey(Survey survey) async {
    final r = await _fetch('/surveys', method: 'POST', body: survey.toJson());
    return Survey.fromJson(r as Map<String, dynamic>);
  }

  // PUT /api/surveys/:id
  static Future<Survey> updateSurvey(String id, Survey survey) async {
    final r = await _fetch('/surveys/$id', method: 'PUT', body: survey.toJson());
    return Survey.fromJson(r as Map<String, dynamic>);
  }

  // DELETE /api/surveys/:id
  static Future<void> deleteSurvey(String id) async {
    await _fetch('/surveys/$id', method: 'DELETE');
  }

  // DELETE /api/surveys  (admin only)
  static Future<void> deleteAllSurveys() async {
    await _fetch('/surveys', method: 'DELETE');
  }

  // ════ DASHBOARD ═══════════════════════════════════════════════════════════
  // GET /api/dashboard → flat stats object
  static Future<DashboardData> getDashboard() async {
    final r = await _fetch('/dashboard');
    return DashboardData.fromJson(r as Map<String, dynamic>);
  }

  // ════ INDICATORS ══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getIndicators({String? ward}) async {
    final qs = (ward != null && ward.isNotEmpty)
        ? '?ward=${Uri.encodeComponent(ward)}'
        : '';
    final r = await _fetch('/indicators$qs');
    return (r as Map<String, dynamic>)['indicators'] as Map<String, dynamic>? ?? r;
  }

  // ════ EXPORT ══════════════════════════════════════════════════════════════
  static Future<String> getExportUrl({String? ward, String? collector}) async {
    final token = await getToken();
    final params = <String, String>{};
    if (ward != null && ward.isNotEmpty)      params['ward']      = ward;
    if (collector != null && collector.isNotEmpty) params['collector'] = collector;
    if (token != null) params['token'] = token;
    final qs = params.isNotEmpty
        ? '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')
        : '';
    return '$baseUrl/export/excel$qs';
  }
}

class ApiException implements Exception {
  final String message;
  final int status;
  ApiException(this.message, this.status);

  @override
  String toString() => message;
}
