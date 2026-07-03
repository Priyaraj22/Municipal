import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/survey_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';

class SurveyorCorrectionsScreen extends StatefulWidget {
  const SurveyorCorrectionsScreen({super.key});

  @override
  State<SurveyorCorrectionsScreen> createState() => _SurveyorCorrectionsScreenState();
}

class _SurveyorCorrectionsScreenState extends State<SurveyorCorrectionsScreen> {
  List<CorrectionRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final res = await ApiService.getSurveyorCorrections(auth.collectorName ?? '');
      setState(() {
        _requests = res;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showReviewDetails(CorrectionRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Review Correction Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.blue)),
              const Divider(height: 32),
              
              const Text('CITIZEN REQUEST', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.ink3)),
              const SizedBox(height: 8),
              _detailRow('Field', req.fieldName),
              _detailRow('Current Value', req.oldValue, isOld: true),
              _detailRow('Proposed Value', req.newValue, isNew: true),
              
              const SizedBox(height: 24),
              const Text('FAMILY CONTEXT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.ink3)),
              const SizedBox(height: 8),
              _detailRow('Family Head', req.headName ?? '-'),
              _detailRow('Door No', req.door ?? '-'),
              _detailRow('Street', req.street ?? '-'),
              
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final surveys = await ApiService.getSurveys();
                    final survey = surveys.firstWhere((s) => s.id == req.surveyId);
                    if (mounted) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SurveyScreen(existing: survey)));
                    }
                  } catch (e) {
                    showToast(context, 'Could not load full survey', isError: true);
                  }
                },
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View/Edit Full Survey'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
              ),
              
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleApprove(req);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.blue),
                      child: const Text('Apply & Update'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isOld = false, bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.ink3))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
                color: isNew ? Colors.green : (isOld ? Colors.red : AppTheme.ink),
                decoration: isOld ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(CorrectionRequest req) async {
    try {
      await ApiService.approveCorrection(req.id!);
      if (mounted) {
        showToast(context, '✅ Correction applied and Citizen notified!');
        _load();
      }
    } catch (e) {
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Correction Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.blue)),
                const Spacer(),
                IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: AppTheme.blue)),
              ],
            ),
          ),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: AppTheme.blue))
              : _requests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _requests.length,
                    itemBuilder: (ctx, i) {
                      final r = _requests[i];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
                        child: ListTile(
                          onTap: () => _showReviewDetails(r),
                          contentPadding: const EdgeInsets.all(16),
                          title: Text('Field: ${r.fieldName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.history, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(r.oldValue, style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(r.newValue, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: AppTheme.ink3),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.done_all_rounded, size: 64, color: AppTheme.blue.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink2)),
          const Text('No pending correction requests.', style: TextStyle(fontSize: 12, color: AppTheme.ink3)),
        ],
      ),
    );
  }
}
