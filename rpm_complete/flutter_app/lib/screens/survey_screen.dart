// screens/survey_screen.dart
// 4-step family survey form matching the web app

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_models.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'member_form.dart';
import 'couple_form.dart';

class SurveyScreen extends StatefulWidget {
  final Survey? existing;
  const SurveyScreen({super.key, this.existing});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _step = 0;
  bool _submitting = false;
  bool _draftExists = false;

  // ── Step 0: Family/Location fields ──
  String? _ward;
  List<String> _wardNames = [];
  final _streetCtrl = TextEditingController();
  final _doorCtrl = TextEditingController();
  final _famnoCtrl = TextEditingController();
  final _abhaCtrl = TextEditingController();
  final _pmjaCtrl = TextEditingController();
  final _phrCtrl = TextEditingController();
  final _rationCtrl = TextEditingController();
  final _smartcardCtrl = TextEditingController();
  final _headCtrl = TextEditingController();
  String? _bpl;
  String? _caste;
  String? _insurance;
  String? _housing;
  String? _water;
  String? _toilet;

  // ── Step 1: Members ──
  final List<FamilyMember> _members = [];

  // ── Step 2: Couples ──
  final List<EligibleCouple> _couples = [];

  @override
  void initState() {
    super.initState();
    _loadWards();
    _checkDraft();
    
    // Auto-save listeners for text fields
    final ctrls = [
      _streetCtrl, _doorCtrl, _famnoCtrl, _abhaCtrl, _pmjaCtrl,
      _phrCtrl, _rationCtrl, _smartcardCtrl, _headCtrl
    ];
    for (var c in ctrls) {
      c.addListener(_saveDraft);
    }

    if (widget.existing != null) {
      final s = widget.existing!;
      _ward = s.ward;
      _streetCtrl.text = s.street;
      _doorCtrl.text = s.door;
      _famnoCtrl.text = s.famno;
      _abhaCtrl.text = s.abha;
      _pmjaCtrl.text = s.pmja;
      _phrCtrl.text = s.phr;
      _rationCtrl.text = s.ration;
      _smartcardCtrl.text = s.smartcard;
      _headCtrl.text = s.head;
      _bpl = s.bpl.isEmpty ? null : s.bpl;
      _caste = s.caste.isEmpty ? null : s.caste;
      _insurance = s.insurance.isEmpty ? null : s.insurance;
      _housing = s.housing.isEmpty ? null : s.housing;
      _water = s.water.isEmpty ? null : s.water;
      _toilet = s.toilet.isEmpty ? null : s.toilet;
      _members.addAll(s.members);
      _couples.addAll(s.couples);
    }
  }

  Future<void> _checkDraft() async {
    if (widget.existing != null) return;
    final auth = context.read<AuthProvider>();
    if (auth.collectorName == null) return;

    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('draft_${auth.collectorName}');
    if (draft != null) {
      setState(() => _draftExists = true);
    }
  }

  Future<void> _saveDraft() async {
    if (widget.existing != null) return;
    final auth = context.read<AuthProvider>();
    if (auth.collectorName == null) return;

    final prefs = await SharedPreferences.getInstance();
    final survey = Survey(
      ward: _ward ?? '',
      street: _streetCtrl.text.trim(),
      door: _doorCtrl.text.trim(),
      famno: _famnoCtrl.text.trim(),
      abha: _abhaCtrl.text.trim(),
      pmja: _pmjaCtrl.text.trim(),
      phr: _phrCtrl.text.trim(),
      ration: _rationCtrl.text.trim(),
      smartcard: _smartcardCtrl.text.trim(),
      head: _headCtrl.text.trim(),
      bpl: _bpl ?? '',
      caste: _caste ?? '',
      insurance: _insurance ?? '',
      housing: _housing ?? '',
      water: _water ?? '',
      toilet: _toilet ?? '',
      collector: auth.collectorName?.trim(),
      collectorWard: auth.collectorWard?.trim(),
      members: _members,
      couples: _couples,
    );
    await prefs.setString('draft_${auth.collectorName}', json.encode(survey.toJson()));
  }

  Future<void> _restoreDraft() async {
    final auth = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    final draft = prefs.getString('draft_${auth.collectorName}');
    if (draft != null) {
      final s = Survey.fromJson(json.decode(draft));
      setState(() {
        _ward = s.ward.isEmpty ? null : s.ward;
        _streetCtrl.text = s.street;
        _doorCtrl.text = s.door;
        _famnoCtrl.text = s.famno;
        _abhaCtrl.text = s.abha;
        _pmjaCtrl.text = s.pmja;
        _phrCtrl.text = s.phr;
        _rationCtrl.text = s.ration;
        _smartcardCtrl.text = s.smartcard;
        _headCtrl.text = s.head;
        _bpl = s.bpl.isEmpty ? null : s.bpl;
        _caste = s.caste.isEmpty ? null : s.caste;
        _insurance = s.insurance.isEmpty ? null : s.insurance;
        _housing = s.housing.isEmpty ? null : s.housing;
        _water = s.water.isEmpty ? null : s.water;
        _toilet = s.toilet.isEmpty ? null : s.toilet;
        _members.clear();
        _members.addAll(s.members);
        _couples.clear();
        _couples.addAll(s.couples);
        _draftExists = false;
      });
      showToast(context, 'Draft restored / வரைவு மீட்கப்பட்டது');
    }
  }

  Future<void> _discardDraft() async {
    final auth = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_${auth.collectorName}');
    setState(() => _draftExists = false);
    showToast(context, 'Draft discarded / வரைவு நீக்கப்பட்டது');
  }

  Future<void> _loadWards() async {
    try {
      final wards = await ApiService.getWards();
      final auth = context.read<AuthProvider>();
      setState(() {
        _wardNames = wards.map((w) => w.wardName).toList();
        // Pre-select collector's ward
        if (auth.collectorWard != null) _ward = auth.collectorWard;
      });
    } catch (_) {
      setState(() {
        _wardNames = List.generate(42, (i) => 'Ward ${i + 1}');
      });
    }
  }

  void _clearForm() {
    setState(() {
      _step = 0;
      _ward = context.read<AuthProvider>().collectorWard;
      _streetCtrl.clear(); _doorCtrl.clear(); _famnoCtrl.clear();
      _abhaCtrl.clear(); _pmjaCtrl.clear(); _phrCtrl.clear();
      _rationCtrl.clear(); _smartcardCtrl.clear(); _headCtrl.clear();
      _bpl = null; _caste = null; _insurance = null;
      _housing = null; _water = null; _toilet = null;
      _members.clear(); _couples.clear();
    });
  }

  bool _validateStep0() {
    if (_ward == null || _ward!.isEmpty) {
      showToast(context, 'Ward No. is required / வார்டு எண் தேவை', isError: true);
      return false;
    }
    if (_streetCtrl.text.trim().isEmpty) {
      showToast(context, 'Street name is required / தெரு பெயர் தேவை', isError: true);
      return false;
    }
    if (_doorCtrl.text.trim().isEmpty) {
      showToast(context, 'Door No. is required / கதவு எண் தேவை', isError: true);
      return false;
    }
    if (_headCtrl.text.trim().isEmpty) {
      showToast(context, 'Family Head name is required / குடும்பத்தலைவர் பெயர் தேவை', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _submitSurvey() async {
    if (_members.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No members added'),
          content: const Text('Submit without family members?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Go Back')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _submitting = true);

    final auth = context.read<AuthProvider>();
    final survey = Survey(
      ward: _ward ?? '',
      street: _streetCtrl.text.trim(),
      door: _doorCtrl.text.trim(),
      famno: _famnoCtrl.text.trim(),
      abha: _abhaCtrl.text.trim(),
      pmja: _pmjaCtrl.text.trim(),
      phr: _phrCtrl.text.trim(),
      ration: _rationCtrl.text.trim(),
      smartcard: _smartcardCtrl.text.trim(),
      head: _headCtrl.text.trim(),
      bpl: _bpl ?? '',
      caste: _caste ?? '',
      insurance: _insurance ?? '',
      housing: _housing ?? '',
      water: _water ?? '',
      toilet: _toilet ?? '',
      collector: auth.collectorName?.trim(),
      collectorWard: auth.collectorWard?.trim(),
      members: _members,
      couples: _couples,
    );

    try {
      if (widget.existing != null && widget.existing!.id != null) {
        await ApiService.updateSurvey(widget.existing!.id!, survey);
        if (mounted) {
          showToast(context, '✅ Survey updated successfully! / புதுப்பிக்கப்பட்டது');
          Navigator.pop(context, true);
        }
      } else {
        await ApiService.createSurvey(survey);
        final auth = context.read<AuthProvider>();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('draft_${auth.collectorName}');
        if (mounted) {
          showToast(context, '✅ Survey submitted successfully! / சமர்ப்பிக்கப்பட்டது');
          _clearForm();
          if (Navigator.canPop(context)) Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) showToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Stack(
      children: [
        Column(
          children: [
            // ── Collector Banner ──
            _CollectorBanner(),

            if (_draftExists)
              _DraftBanner(onRestore: _restoreDraft, onDiscard: _discardDraft),

            // ── Step Indicator ──
            StepIndicator(
              currentStep: _step,
              totalSteps: 4,
              labels: const ['🏠 Family', '👥 Members', '💑 Couples', '✅ Review'],
              onTap: (i) {
                if (i > _step && _step == 0 && !_validateStep0()) return;
                setState(() => _step = i);
              },
            ),

            // ── Page Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: [
                  _Step0Family(this),
                  _Step1Members(this),
                  _Step2Couples(this),
                  _Step3Review(this),
                ][_step],
              ),
            ),
          ],
        ),
        if (_submitting) const LoadingOverlay(message: 'Submitting survey…'),
      ],
    );

    // If we have an existing survey, we are in "Edit Mode" as a separate screen
    if (widget.existing != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Survey / திருத்து'),
        ),
        body: content,
      );
    }

    return content;
  }
}

// ── Collector Banner ──
class _CollectorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0E1FF)),
      ),
      child: Row(
        children: [
          const Text('🪪', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${auth.collectorName ?? 'Surveyor'} — ${auth.collectorWard ?? ''}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.blue),
              ),
              const Text('பதிவு செய்யும் ஊழியர் விவரம்',
                  style: TextStyle(fontSize: 11, color: AppTheme.ink3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ════ STEP 0: FAMILY DETAILS ════
class _Step0Family extends StatelessWidget {
  final _SurveyScreenState s;
  const _Step0Family(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Location Details
        SectionCard(
          icon: const SectionIcon(emoji: '📍', color: Color(0xFFEBF2FF)),
          title: 'இடம் விவரங்கள் / Location Details',
          subtitle: 'Ward No., Street, Door, IDs',
          body: Column(
            children: [
              _DropField('Ward No. *', s._wardNames, s._ward,
                  (v) => s.setState(() { s._ward = v; s._saveDraft(); }), hint: '— Select —'),
              _TxtField('Street Name *', s._streetCtrl, 'தெரு பெயர் / Street name'),
              _TxtField('Door No. *', s._doorCtrl, 'e.g. 12A'),
              const SizedBox(height: 12),
              _TxtField('Family Register No.', s._famnoCtrl, 'FR number'),
              _TxtField('ABHA ID', s._abhaCtrl, 'ABHA number'),
              _TxtField('PMJA No.', s._pmjaCtrl, 'PMJA number'),
              _TxtField('PHR No.', s._phrCtrl, 'PHR number'),
              _TxtField('Ration Card No.', s._rationCtrl, 'Ration card number'),
              _TxtField('Smart Card ID', s._smartcardCtrl, 'Smart card number'),
            ],
          ),
        ),

        // Family Head
        SectionCard(
          icon: const SectionIcon(emoji: '👤', color: Color(0xFFEFF6FF)),
          title: 'குடும்பத் தலைவர் / Family Head & Category',
          subtitle: 'Head name, BPL/APL, Caste, Insurance',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TxtField('Family Head Name *', s._headCtrl, 'குடும்பத்தலைவர் பெயர்'),
              const SizedBox(height: 12),
              _ChipRow('BPL / APL நிலை *', ['BPL', 'APL', 'Unknown'],
                  s._bpl, (v) => s.setState(() { s._bpl = v; s._saveDraft(); })),
              const SizedBox(height: 12),
              _ChipRow('சாதி / Caste *', ['SC', 'ST', 'MBC', 'BC', 'OC'],
                  s._caste, (v) => s.setState(() { s._caste = v; s._saveDraft(); })),
              const SizedBox(height: 12),
              _ChipRow('Health Insurance', ['Yes', 'No', 'Unknown'],
                  s._insurance, (v) => s.setState(() { s._insurance = v; s._saveDraft(); })),
            ],
          ),
        ),

        // Housing
        SectionCard(
          icon: const SectionIcon(emoji: '🏗️', color: Color(0xFFFAF5FF)),
          title: 'வசதிகள் / Housing & Amenities',
          subtitle: 'வீட்டு வகை, குடிநீர், கழிவறை',
          body: Column(
            children: [
              _DropField(
                  'வீட்டு வகை / Type of House',
                  ['Pucca / கான்கிரீட் வீடு', 'Semi-Pucca / அரை கான்கிரீட்',
                    'Kutcha / குடிசை', 'Own House / சொந்த வீடு',
                    'Rental / வாடகை வீடு', 'Government Quarters / அரசு குடியிருப்பு', 'Others / மற்றவை'],
                  s._housing, (v) => s.setState(() { s._housing = v; s._saveDraft(); })),
              _DropField(
                  'குடிநீர் ஆதாரம் / Water Source',
                  ['Municipal Tap / குழாய் நீர்', 'Borewell / ஆழ்துளை கிணறு',
                    'Open Well / திறந்த கிணறு', 'Tanker / தண்ணீர் லாரி',
                    'River / ஆறு', 'Rainwater / மழைநீர் சேகரிப்பு', 'Others / மற்றவை'],
                  s._water, (v) => s.setState(() { s._water = v; s._saveDraft(); })),
              _DropField(
                  'கழிவறை வசதி / Toilet Facility',
                  ['Own Toilet / தனி கழிவறை', 'Shared Toilet / பொது கழிவறை',
                    'Community Toilet / சமுதாயக் கழிவறை', 'Open Defecation / திறந்தவெளி',
                    'None / கழிவறை இல்லை'],
                  s._toilet, (v) => s.setState(() { s._toilet = v; s._saveDraft(); })),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                if (s._validateStep0()) s.setState(() => s._step = 1);
              },
              child: const Text('அடுத்து: உறுப்பினர்கள் → Next'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ════ STEP 1: MEMBERS ════
class _Step1Members extends StatelessWidget {
  final _SurveyScreenState s;
  const _Step1Members(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...s._members.asMap().entries.map((entry) {
          final i = entry.key;
          final m = entry.value;
          return MemberCard(
            index: i,
            member: m,
            onDelete: () => s.setState(() { s._members.removeAt(i); s._saveDraft(); }),
            onEdit: () => _openMemberForm(context, i, m),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => _openMemberForm(context, null, null),
          icon: const Icon(Icons.add),
          label: const Text('Add Family Member / உறுப்பினர் சேர்க்க'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppTheme.teal),
            foregroundColor: AppTheme.teal,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => s.setState(() => s._step = 0),
              child: const Text('← Back'),
            ),
            ElevatedButton(
              onPressed: () => s.setState(() => s._step = 2),
              child: const Text('அடுத்து: தம்பதியர் → Next'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _openMemberForm(BuildContext context, int? index, FamilyMember? existing) async {
    final result = await Navigator.push<FamilyMember>(
      context,
      MaterialPageRoute(
        builder: (_) => MemberFormScreen(existing: existing),
      ),
    );
    if (result != null) {
      s.setState(() {
        if (index != null) {
          s._members[index] = result;
        } else {
          s._members.add(result);
        }
        s._saveDraft();
      });
    }
  }
}

// ════ STEP 2: COUPLES ════
class _Step2Couples extends StatelessWidget {
  final _SurveyScreenState s;
  const _Step2Couples(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    SectionIcon(emoji: '💑', color: Color(0xFFFAF5FF)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Eligible Couple Register',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('15–49 வயது தம்பதியர் விவரம் (optional)',
                              style: TextStyle(fontSize: 12, color: AppTheme.ink3)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openCoupleForm(context, null, null),
                  icon: const Icon(Icons.add),
                  label: const Text('தம்பதியர் சேர்க்க / Add Eligible Couple'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.purple),
                    foregroundColor: AppTheme.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...s._couples.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return CoupleCard(
            index: i,
            couple: c,
            onDelete: () => s.setState(() { s._couples.removeAt(i); s._saveDraft(); }),
            onEdit: () => _openCoupleForm(context, i, c),
          );
        }),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => s.setState(() => s._step = 1),
              child: const Text('← Back'),
            ),
            ElevatedButton(
              onPressed: () => s.setState(() => s._step = 3),
              child: const Text('மதிப்பாய்வு → Review'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _openCoupleForm(BuildContext context, int? index, EligibleCouple? existing) async {
    final result = await Navigator.push<EligibleCouple>(
      context,
      MaterialPageRoute(builder: (_) => CoupleFormScreen(existing: existing)),
    );
    if (result != null) {
      s.setState(() {
        if (index != null) s._couples[index] = result;
        else s._couples.add(result);
        s._saveDraft();
      });
    }
  }
}

// ════ STEP 3: REVIEW ════
class _Step3Review extends StatelessWidget {
  final _SurveyScreenState s;
  const _Step3Review(this.s);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('✅', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Text('Review Before Submission',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ]),
                const Divider(height: 24),
                _ReviewRow('Ward', s._ward ?? '-'),
                _ReviewRow('Door No.', s._doorCtrl.text),
                _ReviewRow('Street', s._streetCtrl.text),
                _ReviewRow('Family Head', s._headCtrl.text),
                _ReviewRow('BPL/APL', s._bpl ?? '-'),
                _ReviewRow('Caste', s._caste ?? '-'),
                _ReviewRow('Insurance', s._insurance ?? '-'),
                _ReviewRow('Housing', s._housing ?? '-'),
                _ReviewRow('Water', s._water ?? '-'),
                _ReviewRow('Toilet', s._toilet ?? '-'),
                const Divider(height: 24),
                _ReviewRow('Family Members', '${s._members.length}'),
                _ReviewRow('Eligible Couples', '${s._couples.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => s.setState(() => s._step = 2),
              child: const Text('← Back'),
            ),
            ElevatedButton(
              onPressed: s._submitting ? null : s._submitSurvey,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('✅ சமர்ப்பிக்க / Submit Survey',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.ink3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.blue)),
          ),
        ],
      ),
    );
  }
}

// ── Draft Banner ──
class _DraftBanner extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onDiscard;
  const _DraftBanner({required this.onRestore, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFEDD5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          const Text('📂', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unsaved draft found',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF9A3412))),
                Text('Continue previous survey?',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9A3412))),
              ],
            ),
          ),
          TextButton(
            onPressed: onDiscard,
            child: const Text('Discard', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: onRestore,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9A3412),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Restore', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ── Helper field widgets ──
Widget _TxtField(String label, TextEditingController ctrl, String hint,
    {bool required = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label, required: required),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    ),
  );
}

Widget _DropField(String label, List<String> opts, String? value,
    ValueChanged<String?> onChanged, {String hint = 'தேர்வு செய்யவும்…'}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: (value != null && opts.contains(value)) ? value : null,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          decoration: const InputDecoration(),
          items: opts
              .map((o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) {
            onChanged(v);
          },
        ),
      ],
    ),
  );
}

Widget _ChipRow(String label, List<String> opts, String? value,
    ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FieldLabel(text: label),
      ChipGroup(options: opts, value: value, onChanged: (v) {
        onChanged(v);
      }),
    ],
  );
}
