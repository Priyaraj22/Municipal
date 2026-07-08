// screens/dashboard_screen.dart
// Admin dashboard with stats calculated from local storage

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/survey_models.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  int _families = 0;
  int _members = 0;
  int _wards = 0;
  Map<String, int> _bplCounts = {};
  Map<String, int> _casteCounts = {};
  Map<String, int> _genderCounts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await LocalStorageService.getAllSurveys();
      
      int mCount = 0;
      Set<String> wardSet = {};
      Map<String, int> bpl = {};
      Map<String, int> caste = {};
      Map<String, int> gender = {};

      for (var s in data) {
        mCount += s.members.length;
        wardSet.add(s.ward);
        bpl[s.bpl] = (bpl[s.bpl] ?? 0) + 1;
        caste[s.caste] = (caste[s.caste] ?? 0) + 1;
        for (var m in s.members) {
          gender[m.gender] = (gender[m.gender] ?? 0) + 1;
        }
      }

      setState(() {
        _families = data.length;
        _members = mCount;
        _wards = wardSet.length;
        _bplCounts = bpl;
        _casteCounts = caste;
        _genderCounts = gender;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.teal));
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                StatCard(emoji: '🏠', value: '$_families', label: 'Families', color: AppTheme.teal),
                StatCard(emoji: '👥', value: '$_members', label: 'Members', color: AppTheme.blue),
                StatCard(emoji: '🗺️', value: '$_wards', label: 'Active Wards', color: AppTheme.purple),
                StatCard(emoji: '📊', value: '${_bplCounts['BPL'] ?? 0}', label: 'BPL Families', color: AppTheme.amber),
              ],
            ),
            const SizedBox(height: 20),
            if (_bplCounts.isNotEmpty) ...[
              _ChartCard(
                title: 'BPL vs APL',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(_bplCounts, [AppTheme.amber, AppTheme.teal, AppTheme.ink3]),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                legend: _bplCounts,
                colors: [AppTheme.amber, AppTheme.teal, AppTheme.ink3],
              ),
              const SizedBox(height: 12),
            ],
            if (_casteCounts.isNotEmpty) ...[
              _ChartCard(
                title: 'Caste Distribution',
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildBarGroups(_casteCounts),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final keys = _casteCounts.keys.toList();
                              if (v.toInt() < keys.length) {
                                return Text(keys[v.toInt()], style: const TextStyle(fontSize: 11));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                legend: _casteCounts,
                colors: [AppTheme.teal, AppTheme.blue, AppTheme.purple, AppTheme.amber],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> data, List<Color> colors) {
    final total = data.values.fold(0, (a, b) => a + b);
    final keys = data.keys.toList();
    return List.generate(keys.length, (i) {
      final val = data[keys[i]] ?? 0;
      final pct = total > 0 ? (val / total * 100) : 0;
      return PieChartSectionData(
        value: val.toDouble(),
        color: colors[i % colors.length],
        title: '${pct.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
        radius: 60,
      );
    });
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> data) {
    final keys = data.keys.toList();
    final colors = [AppTheme.teal, AppTheme.blue, AppTheme.purple, AppTheme.amber];
    return List.generate(keys.length, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: (data[keys[i]] ?? 0).toDouble(),
          color: colors[i % colors.length],
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    ));
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Map<String, int> legend;
  final List<Color> colors;

  const _ChartCard({required this.title, required this.child, required this.legend, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: legend.keys.toList().asMap().entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('${e.value}: ${legend[e.value]}', style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
