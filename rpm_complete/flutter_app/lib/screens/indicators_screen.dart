// screens/indicators_screen.dart
// Admin: health & demographic survey indicators from backend

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class IndicatorsScreen extends StatefulWidget {
  const IndicatorsScreen({super.key});

  @override
  State<IndicatorsScreen> createState() => _IndicatorsScreenState();
}

class _IndicatorsScreenState extends State<IndicatorsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _filterWard;
  List<String> _wardNames = [];

  @override
  void initState() {
    super.initState();
    _loadWards();
    _load();
  }

  Future<void> _loadWards() async {
    try {
      final wards = await ApiService.getWards();
      if (mounted) setState(() => _wardNames = wards.map((w) => w.wardName).toList());
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.getIndicators(ward: _filterWard);
      setState(() { _data = result; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ward filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _filterWard,
                hint: const Text('All Wards', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Wards', overflow: TextOverflow.ellipsis)),
                  ..._wardNames.map((w) => DropdownMenuItem(value: w,
                      child: Text(w, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) { setState(() => _filterWard = v); _load(); },
              ),
            ),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.teal))
              : _data == null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Failed to load'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.teal,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: _buildContent(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final families = (_data!['families'] as Map<String, dynamic>?) ?? {};
    final members  = (_data!['members']  as Map<String, dynamic>?) ?? {};
    final couples  = (_data!['eligibleCouples'] as Map<String, dynamic>?) ?? {};
    final casteList = (_data!['caste'] as List<dynamic>?) ?? [];

    final totalFamilies = _i(families['total']);
    final totalMembers  = _i(members['total']);
    final totalCouples  = _i(couples['total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Family Indicators ─────────────────────────────────────────────
        _hdr('🏠 குடும்ப குறியீடுகள் / Family Indicators'),
        _grid4([
          StatCard(emoji: '🏠', value: '${totalFamilies}', label: 'Total Families', color: AppTheme.teal),
          StatCard(emoji: '📍', value: '${_i(families['wardsCovered'])}', label: 'Wards Covered', color: AppTheme.blue),
          StatCard(emoji: '🟡', value: '${_i(families['bpl'])}', label: 'BPL Families', color: AppTheme.amber),
          StatCard(emoji: '🟢', value: '${_i(families['apl'])}', label: 'APL Families', color: AppTheme.tealLight),
        ]),
        const SizedBox(height: 8),
        _bar('Insurance Coverage', _i(families['insured']), totalFamilies,
            AppTheme.teal, 'Insured', 'Uninsured'),

        // ── Caste Distribution ─────────────────────────────────────────────
        if (casteList.isNotEmpty) ...[
          const SizedBox(height: 20),
          _hdr('🏘️ சாதி விநியோகம் / Caste Distribution'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: casteList.map<Widget>((c) {
                  final caste = c['caste'] ?? 'Unknown';
                  final count = _i(c['count']);
                  final pct = totalFamilies > 0 ? count / totalFamilies : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(caste,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                        Text('$count (${(pct * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
                      ]),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.teal,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        // ── Member Indicators ──────────────────────────────────────────────
        const SizedBox(height: 20),
        _hdr('👥 உறுப்பினர் குறியீடுகள் / Member Indicators'),
        _grid4([
          StatCard(emoji: '👥', value: '$totalMembers', label: 'Total Members', color: AppTheme.teal),
          StatCard(emoji: '👨', value: '${_i(members['male'])}', label: 'Male', color: AppTheme.blue),
          StatCard(emoji: '👩', value: '${_i(members['female'])}', label: 'Female', color: AppTheme.rose),
          StatCard(emoji: '🧒', value: '${_i(members['childrenUnder18'])}', label: 'Children (<18)', color: AppTheme.amber),
          StatCard(emoji: '🧑', value: '${_i(members['adults18to59'])}', label: 'Adults (18–59)', color: AppTheme.purple),
          StatCard(emoji: '👴', value: '${_i(members['seniors60Plus'])}', label: 'Seniors (60+)', color: AppTheme.ink2),
        ]),
        const SizedBox(height: 8),
        _bar('Chronic Disease', _i(members['chronicDisease']), totalMembers,
            AppTheme.rose, 'Affected', 'Not Affected'),
        const SizedBox(height: 6),
        _bar('Vaccination (Complete)', _i(members['fullyVaccinated']), totalMembers,
            AppTheme.teal, 'Vaccinated', 'Others'),
        const SizedBox(height: 6),
        _bar('Disability', _i(members['disability']), totalMembers,
            AppTheme.amber, 'With Disability', 'None'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _small('⚰️', 'Deaths Recorded', '${_i(members['deathsRecorded'])}', AppTheme.ink2)),
          const SizedBox(width: 10),
          Expanded(child: _small('👶', 'New Additions', '${_i(members['newAdditions'])}', AppTheme.teal)),
        ]),

        // ── Eligible Couples ───────────────────────────────────────────────
        const SizedBox(height: 20),
        _hdr('💑 தகுதியான தம்பதியர் / Eligible Couples'),
        _grid4([
          StatCard(emoji: '💑', value: '$totalCouples', label: 'Total EC', color: AppTheme.purple),
          StatCard(emoji: '🏥', value: '${_i(couples['ancDone'])}', label: 'ANC Done', color: AppTheme.teal),
          StatCard(emoji: '👶', value: '${_i(couples['childrenBornThisYear'])}', label: 'Births This Year', color: AppTheme.blue),
          StatCard(emoji: '🛡️', value: '${_i(couples['usingContraception'])}', label: 'Using FP', color: AppTheme.amber),
        ]),
        if (totalCouples > 0) ...[
          const SizedBox(height: 8),
          _bar('Family Planning Adoption', _i(couples['usingContraception']),
              totalCouples, AppTheme.purple, 'Using FP', 'Not Using'),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  int _i(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;

  Widget _hdr(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
  );

  Widget _grid4(List<Widget> cards) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 2.2,
    children: cards,
  );

  Widget _bar(String label, int covered, int total, Color color,
      String covLabel, String uncovLabel) {
    final pct = total > 0 ? covered / total : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Text('${(pct * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: pct, backgroundColor: AppTheme.border,
              color: color, minHeight: 8, borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                _dot(color), const SizedBox(width: 4),
                Text('$covLabel: $covered', style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _dot(AppTheme.border), const SizedBox(width: 4),
                Text('$uncovLabel: ${total - covered}', style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
              ]),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _small(String emoji, String label, String value, Color color) =>
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.ink3)),
        ])),
      ]),
    );

  Widget _dot(Color c) => Container(
      width: 8, height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}
