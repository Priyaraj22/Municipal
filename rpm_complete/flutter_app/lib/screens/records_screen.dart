// screens/records_screen.dart
// View locally saved surveys

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/survey_models.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Survey> _surveys = [];
  List<Survey> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final surveys = await LocalStorageService.getAllSurveys();
      if (!mounted) return;
      setState(() {
        _surveys = surveys;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _surveys
          : _surveys.where((s) {
              return s.head.toLowerCase().contains(q) ||
                  s.door.toLowerCase().contains(q) ||
                  s.street.toLowerCase().contains(q);
            }).toList();
    });
  }

  Future<void> _exportXL() async {
    try {
      showToast(context, 'Generating Excel…');
      final path = await LocalStorageService.exportToExcel();
      showToast(context, '✅ Excel saved: $path');
      OpenFile.open(path);
    } catch (e) {
      showToast(context, 'Export failed: $e', isError: true);
    }
  }

  Future<void> _exportXML() async {
    try {
      showToast(context, 'Generating XML…');
      final path = await LocalStorageService.exportToXML();
      showToast(context, '✅ XML saved: $path');
      OpenFile.open(path);
    } catch (e) {
      showToast(context, 'Export failed: $e', isError: true);
    }
  }

  Future<void> _exportJSON() async {
    try {
      showToast(context, 'Generating JSON…');
      final path = await LocalStorageService.exportToJSON();
      showToast(context, '✅ JSON saved: $path');
      OpenFile.open(path);
    } catch (e) {
      showToast(context, 'Export failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '🔍 Search by name, door, street…',
              prefixIcon: Icon(Icons.search, color: AppTheme.ink3),
            ),
            onChanged: (v) {
              _search = v;
              _applyFilter();
            },
          ),
        ),

        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text('${_filtered.length} records',
                  style: const TextStyle(fontSize: 13, color: AppTheme.ink3)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: _exportXL,
                    icon: const Icon(Icons.table_chart_outlined, size: 16, color: AppTheme.blue),
                    label: const Text('XL', style: TextStyle(color: AppTheme.blue, fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _exportXML,
                    icon: const Icon(Icons.code, size: 16, color: AppTheme.purple),
                    label: const Text('XML', style: TextStyle(color: AppTheme.purple, fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _exportJSON,
                    icon: const Icon(Icons.data_object, size: 16, color: Colors.orange),
                    label: const Text('JSON', style: TextStyle(color: Colors.orange, fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
              : _filtered.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.teal,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _SurveyTile(
                          survey: _filtered[i],
                          onEdit: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurveyScreen(existing: _filtered[i]),
                              ),
                            );
                            if (res == true) _load();
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _SurveyTile extends StatelessWidget {
  final Survey survey;
  final VoidCallback onEdit;
  const _SurveyTile({required this.survey, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final date = survey.date != null
        ? survey.date!.split('T').first
        : '';

    return Card(
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      survey.head.isEmpty ? 'Unknown Family' : survey.head,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (survey.status == 'Hold')
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                      child: const Text('HOLD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: AppTheme.blue),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${survey.door}, ${survey.street} · ${survey.ward}',
                style: const TextStyle(fontSize: 13, color: AppTheme.ink2),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _pill('👥 ${survey.members.length} members'),
                  if (survey.caste.isNotEmpty) _pill(survey.caste),
                  Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.ink2)),
  );

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: _SurveyDetail(survey: survey),
        ),
      ),
    );
  }
}

class _SurveyDetail extends StatelessWidget {
  final Survey survey;
  const _SurveyDetail({required this.survey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(survey.surveyId ?? 'Survey', style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
        Text(survey.head, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        if (survey.phone.isNotEmpty)
          Text('📞 ${survey.phone}', style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${survey.door}, ${survey.street} · ${survey.ward}',
            style: const TextStyle(color: AppTheme.ink2)),
        const Divider(height: 24),
        _DetailRow('BPL/APL', survey.bpl),
        _DetailRow('Caste', survey.caste),
        _DetailRow('Insurance', survey.insurance),
        _DetailRow('Housing', survey.housing),
        _DetailRow('Water Source', survey.water),
        _DetailRow('Toilet', survey.toilet),
        _DetailRow('ABHA', survey.abha),
        _DetailRow('Ration Card', survey.ration),
        const Divider(height: 24),
        Text('Family Members (${survey.members.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        ...survey.members.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  [if (m.rel.isNotEmpty) m.rel, if (m.age.isNotEmpty) 'Age ${m.age}',
                    if (m.gender.isNotEmpty) m.gender].join(' · '),
                  style: const TextStyle(fontSize: 12, color: AppTheme.ink3),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.ink3)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📂', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No records found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink2)),
          Text('Submit a survey first',
              style: TextStyle(fontSize: 13, color: AppTheme.ink3)),
        ],
      ),
    );
  }
}
