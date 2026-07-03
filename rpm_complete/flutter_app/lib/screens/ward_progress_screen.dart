// screens/ward_progress_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class WardProgressScreen extends StatefulWidget {
  const WardProgressScreen({super.key});

  @override
  State<WardProgressScreen> createState() => _WardProgressScreenState();
}

class _WardProgressScreenState extends State<WardProgressScreen> {
  List<Map<String, dynamic>> _wards = [];
  bool _loading = true;
  int _maxCount = 1;
  int _totalFamilies = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getWardProgress();
      int max = 1;
      int total = 0;
      for (final w in data) {
        final c = (w['families_surveyed'] ?? 0) as int;
        if (c > max) max = c;
        total += c;
      }
      setState(() {
        _wards = data;
        _maxCount = max;
        _totalFamilies = total;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('42 Wards Progress',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('$_totalFamilies total families surveyed',
                      style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
                ],
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
              : _wards.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📊', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No data yet', style: TextStyle(color: AppTheme.ink3)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.teal,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _wards.length,
                        itemBuilder: (ctx, i) {
                          final w = _wards[i];
                          final wardName = w['ward_name'] ?? 'Ward ${i + 1}';
                          final count = (w['families_surveyed'] ?? 0) as int;
                          final progress = _maxCount > 0 ? count / _maxCount : 0.0;
                          final collectors = w['collectors'] ?? '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    // Ward number badge
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEBF2FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${w['ward_no'] ?? i + 1}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.teal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(wardName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 14)),
                                    ),
                                    Text('$count families',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.teal)),
                                  ]),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: const Color(0xFFEBF2FF),
                                    color: count > 0 ? AppTheme.teal : AppTheme.border,
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  if (collectors.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Collectors: $collectors',
                                        style: const TextStyle(
                                            fontSize: 11, color: AppTheme.ink3)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
