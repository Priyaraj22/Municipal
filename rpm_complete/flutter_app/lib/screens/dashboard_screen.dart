// screens/dashboard_screen.dart
// Admin dashboard with stats and charts (matching the web dashboard)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/survey_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getDashboard();
      setState(() { _data = data; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.teal));
    }
    if (_data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load dashboard'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final d = _data!;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats ──
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                StatCard(emoji: '🏠', value: '${d.families}', label: 'Families / குடும்பங்கள்', color: AppTheme.teal),
                StatCard(emoji: '👥', value: '${d.members}', label: 'Members / உறுப்பினர்கள்', color: AppTheme.blue),
                StatCard(emoji: '🗺️', value: '${d.activeWards}', label: 'Active Wards', color: AppTheme.purple),
                StatCard(emoji: '📅', value: '${d.today}', label: 'Today / இன்று', color: AppTheme.amber),
              ],
            ),

            const SizedBox(height: 20),

            // ── BPL vs APL ──
            if (d.bplCounts.isNotEmpty) ...[
              _ChartCard(
                title: '📊 BPL vs APL விநியோகம்',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(d.bplCounts, [AppTheme.amber, AppTheme.teal, AppTheme.ink3]),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                legend: d.bplCounts,
                colors: [AppTheme.amber, AppTheme.teal, AppTheme.ink3],
              ),
              const SizedBox(height: 12),
            ],

            // ── Caste Distribution ──
            if (d.casteCounts.isNotEmpty) ...[
              _ChartCard(
                title: '🏘️ சாதி / Caste Category',
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: _buildBarGroups(d.casteCounts),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final keys = d.casteCounts.keys.toList();
                              if (v.toInt() < keys.length) {
                                return Text(keys[v.toInt()],
                                    style: const TextStyle(fontSize: 11, color: AppTheme.ink2));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
                legend: d.casteCounts,
                colors: [AppTheme.teal, AppTheme.blue, AppTheme.purple, AppTheme.amber, AppTheme.rose],
              ),
              const SizedBox(height: 12),
            ],

            // ── Gender ──
            if (d.genderCounts.isNotEmpty) ...[
              _ChartCard(
                title: '👥 பாலின விநியோகம் / Gender',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(d.genderCounts, [AppTheme.blue, AppTheme.rose, AppTheme.ink3]),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                legend: d.genderCounts,
                colors: [AppTheme.blue, AppTheme.rose, AppTheme.ink3],
              ),
              const SizedBox(height: 12),
            ],

            // ── Insurance ──
            if (d.insuranceCounts.isNotEmpty) ...[
              _ChartCard(
                title: '🏥 காப்பீடு / Insurance Coverage',
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieSections(d.insuranceCounts, [AppTheme.teal, AppTheme.rose, AppTheme.ink3]),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                legend: d.insuranceCounts,
                colors: [AppTheme.teal, AppTheme.rose, AppTheme.ink3],
              ),
              const SizedBox(height: 24),
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
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        radius: 60,
      );
    });
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> data) {
    final keys = data.keys.toList();
    final colors = [AppTheme.teal, AppTheme.blue, AppTheme.purple, AppTheme.amber, AppTheme.rose];
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

  const _ChartCard({
    required this.title,
    required this.child,
    required this.legend,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.ink)),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: legend.keys.toList().asMap().entries.map((e) {
                final i = e.key;
                final key = e.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('$key: ${legend[key]}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.ink2)),
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
