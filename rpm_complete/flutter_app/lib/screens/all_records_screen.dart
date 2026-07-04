// screens/all_records_screen.dart
// Admin: view all records with filters

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import '../models/survey_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'survey_screen.dart';
import 'records_screen.dart';

class AllRecordsScreen extends StatefulWidget {
  const AllRecordsScreen({super.key});

  @override
  State<AllRecordsScreen> createState() => _AllRecordsScreenState();
}

class _AllRecordsScreenState extends State<AllRecordsScreen> {
  List<Survey> _surveys = [];
  List<Survey> _filtered = [];
  bool _loading = true;
  String _search = '';
  String? _filterWard;
  String? _filterBpl;
  String? _filterCaste;
  List<String> _wardNames = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final surveys = await ApiService.getSurveys();
      final wards = surveys.map((s) => s.ward).toSet().toList()..sort();
      setState(() {
        _surveys = surveys;
        _wardNames = wards;
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _surveys.where((s) {
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          if (!s.head.toLowerCase().contains(q) &&
              !s.door.toLowerCase().contains(q) &&
              !s.street.toLowerCase().contains(q) &&
              !(s.collector ?? '').toLowerCase().contains(q)) return false;
        }
        if (_filterWard != null && s.ward != _filterWard) return false;
        if (_filterBpl != null && s.bpl != _filterBpl) return false;
        if (_filterCaste != null && s.caste != _filterCaste) return false;
        return true;
      }).toList();
    });
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Clear All Data?'),
        content: const Text(
            'This will permanently delete ALL survey records. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.deleteAllSurveys();
        _load();
        if (mounted) showToast(context, 'All records cleared');
      } catch (e) {
        if (mounted) showToast(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _exportExcel() async {
    try {
      showToast(context, 'Preparing Master Excel export…');
      // Admin export can be filtered by currently selected ward or be the entire DB
      final url = await ApiService.getExportUrl(
        ward: _filterWard,
      );

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Master_Records_${DateTime.now().millisecondsSinceEpoch}.xlsx');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          showToast(context, '✅ Master Excel downloaded');
          OpenFile.open(file.path);
        }
      } else {
        throw Exception('Download failed (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) showToast(context, 'Export failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: '🔍 Search by name, door, street, collector…',
                  prefixIcon: Icon(Icons.search, color: AppTheme.ink3),
                ),
                onChanged: (v) { _search = v; _applyFilter(); },
              ),
              const SizedBox(height: 8),
              // Use Wrap instead of Row for filters to prevent overflow
              Wrap(
                spacing: 4,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 40) / 2,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _filterWard,
                      hint: const Text('Ward', style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Wards', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ..._wardNames.map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) { setState(() => _filterWard = v); _applyFilter(); },
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 4,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _filterBpl,
                      hint: const Text('BPL', style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ...['BPL', 'APL', 'Unknown'].map((v) =>
                            DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) { setState(() => _filterBpl = v); _applyFilter(); },
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 4,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _filterCaste,
                      hint: const Text('Caste', style: TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ...['SC', 'ST', 'MBC', 'BC', 'OC'].map((v) =>
                            DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) { setState(() => _filterCaste = v); _applyFilter(); },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${_filtered.length} records',
                  style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: _exportExcel,
                    icon: const Icon(Icons.download_rounded, size: 14, color: AppTheme.blue),
                    label: const Text('Master', style: TextStyle(color: AppTheme.blue, fontSize: 11)),
                  ),
                  IconButton(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  IconButton(onPressed: _confirmClearAll, icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.rose), padding: const EdgeInsets.only(left: 8), constraints: const BoxConstraints()),
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
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📋', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No records found', style: TextStyle(color: AppTheme.ink3)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.teal,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) => _AdminSurveyTile(
                          survey: _filtered[i],
                          onRefresh: _load,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _AdminSurveyTile extends StatelessWidget {
  final Survey survey;
  final VoidCallback onRefresh;
  const _AdminSurveyTile({required this.survey, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.7, maxChildSize: 0.95, minChildSize: 0.4, expand: false,
            builder: (_, ctrl) => SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              child: _SurveyDetail(survey: survey),
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(survey.head.isEmpty ? 'Unknown' : survey.head,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: AppTheme.blue),
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurveyScreen(existing: survey),
                      ),
                    );
                    if (res == true) onRefresh();
                  },
                  visualDensity: VisualDensity.compact,
                ),
                if (survey.bpl.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: survey.bpl == 'BPL' ? const Color(0xFFFEF3C7) : const Color(0xFFEBF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(survey.bpl, style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: survey.bpl == 'BPL' ? AppTheme.amber : AppTheme.blue,
                    )),
                  ),
              ]),
              const SizedBox(height: 4),
              Text('${survey.ward} · Door: ${survey.door}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
              if (survey.collector != null)
                Text('Surveyor: ${survey.collector}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _pill('👥 ${survey.members.length}'),
                  if (survey.caste.isNotEmpty) _pill(survey.caste),
                  if (survey.insurance.isNotEmpty) _pill('🏥 ${survey.insurance}'),
                  Text(survey.date?.split('T').first ?? '',
                      style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
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
}

class _SurveyDetail extends StatelessWidget {
  final Survey survey;
  const _SurveyDetail({required this.survey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text(survey.surveyId ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
        Text(survey.head, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        Text('${survey.door}, ${survey.street} · ${survey.ward}', style: const TextStyle(color: AppTheme.ink2)),
        if (survey.collector != null)
          Text('Surveyor: ${survey.collector}', style: const TextStyle(fontSize: 12, color: AppTheme.blue)),
        const Divider(height: 24),
        _row('BPL/APL', survey.bpl),
        _row('Caste', survey.caste),
        _row('Insurance', survey.insurance),
        _row('Housing', survey.housing),
        _row('Water', survey.water),
        _row('Toilet', survey.toilet),
        const Divider(height: 24),
        Text('Family Members (${survey.members.length})',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ...survey.members.map((m) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text([if (m.rel.isNotEmpty) m.rel, if (m.age.isNotEmpty) 'Age ${m.age}',
                if (m.gender.isNotEmpty) m.gender].join(' · '),
                style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
            ]),
          ),
        )),
      ],
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.ink3))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
