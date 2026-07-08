// screens/all_records_screen.dart
// Admin: view all records locally

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/survey_models.dart';
import '../services/local_storage_service.dart';
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
      final surveys = await LocalStorageService.getAllSurveys();
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
                  hintText: '🔍 Search by name, door, street...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.ink3),
                ),
                onChanged: (v) { _search = v; _applyFilter(); },
              ),
              const SizedBox(height: 8),
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
                    onPressed: () async {
                      final path = await LocalStorageService.exportToExcel();
                      showToast(context, 'Excel saved!');
                      OpenFile.open(path);
                    },
                    icon: const Icon(Icons.table_chart, size: 14, color: AppTheme.blue),
                    label: const Text('XL', style: TextStyle(color: AppTheme.blue, fontSize: 11)),
                  ),
                  IconButton(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
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
        onTap: () {},
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
              ]),
              const SizedBox(height: 4),
              Text('${survey.ward} · Door: ${survey.door}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
            ],
          ),
        ),
      ),
    );
  }
}
