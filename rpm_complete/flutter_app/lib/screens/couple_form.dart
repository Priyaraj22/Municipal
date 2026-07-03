// screens/couple_form.dart
// Eligible couple register — all 34 fields matching the DB schema

import 'package:flutter/material.dart';
import '../models/survey_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CoupleFormScreen extends StatefulWidget {
  final EligibleCouple? existing;
  const CoupleFormScreen({super.key, this.existing});

  @override
  State<CoupleFormScreen> createState() => _CoupleFormScreenState();
}

class _CoupleFormScreenState extends State<CoupleFormScreen> {
  // Identification
  final _frnoCtrl          = TextEditingController();
  final _ecnoCtrl          = TextEditingController();
  final _rchidCtrl         = TextEditingController();

  // Names & registration
  final _husbandNameCtrl   = TextEditingController();
  final _wifeNameCtrl      = TextEditingController();
  final _regDateCtrl       = TextEditingController();

  // Bank
  final _bankAcCtrl        = TextEditingController();
  final _bankBranchCtrl    = TextEditingController();

  // Ages & children
  final _husbandAgeMarCtrl = TextEditingController();
  final _wifeAgeMarCtrl    = TextEditingController();
  final _motherAgeCtrl     = TextEditingController();
  final _totalPregCtrl     = TextEditingController();
  final _livingSonsCtrl    = TextEditingController();
  final _livingDaughCtrl   = TextEditingController();
  final _abortionsCtrl     = TextEditingController();
  final _youngestDobCtrl   = TextEditingController();
  final _lastDelDateCtrl   = TextEditingController();

  // Delivery
  final _lastDelPlaceCtrl  = TextEditingController();
  final _postDelHealthCtrl = TextEditingController();
  final _sterilDateCtrl    = TextEditingController();
  final _sterilPlaceCtrl   = TextEditingController();

  // ANC / pregnancy
  final _pregnTestCtrl     = TextEditingController();
  final _anNoCtrl          = TextEditingController();
  final _ancDateCtrl       = TextEditingController();
  final _nextVisitCtrl     = TextEditingController();
  final _planDelPlaceCtrl  = TextEditingController();
  final _healthStatusCtrl  = TextEditingController();
  final _remarksCtrl       = TextEditingController();

  // Dropdowns / chips
  String? _childBornThisYear;
  String? _deliveryType;
  String? _contraMethod;
  String? _stoppingOrSpacing;
  String? _noContraReason;
  String? _ancDone;

  static const _yesNo     = ['Yes', 'No'];
  static const _delTypes  = ['Normal', 'C-Section', 'Home Delivery', 'N/A'];
  static const _fpMethods = [
    'None', 'Sterilization (Female)', 'Sterilization (Male)',
    'IUCD', 'Oral Pills', 'Condom', 'Injectable', 'LAM', 'Others'
  ];
  static const _stopSpc   = ['Stopping', 'Spacing', 'N/A'];
  static const _noContraR = ['Wants Child', 'Pregnant', 'Infertile', 'Religious', 'Side Effects', 'Others'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final c = widget.existing!;
      _frnoCtrl.text          = c.frno;
      _ecnoCtrl.text          = c.ecno;
      _rchidCtrl.text         = c.rchid;
      _husbandNameCtrl.text   = c.husbandName;
      _wifeNameCtrl.text      = c.wifeName;
      _regDateCtrl.text       = c.regDate;
      _bankAcCtrl.text        = c.bankAc;
      _bankBranchCtrl.text    = c.bankBranch;
      _husbandAgeMarCtrl.text = c.husbandAgeAtMarriage;
      _wifeAgeMarCtrl.text    = c.wifeAgeAtMarriage;
      _motherAgeCtrl.text     = c.motherCurrentAge;
      _totalPregCtrl.text     = c.totalPregnancies;
      _livingSonsCtrl.text    = c.livingSons;
      _livingDaughCtrl.text   = c.livingDaughters;
      _abortionsCtrl.text     = c.abortions;
      _youngestDobCtrl.text   = c.youngestChildDOB;
      _lastDelDateCtrl.text   = c.lastDeliveryDate;
      _lastDelPlaceCtrl.text  = c.lastDeliveryPlace;
      _postDelHealthCtrl.text = c.postDeliveryHealth;
      _sterilDateCtrl.text    = c.sterilisationDate;
      _sterilPlaceCtrl.text   = c.sterilisationPlace;
      _pregnTestCtrl.text     = c.pregnancyTest;
      _anNoCtrl.text          = c.anNumber;
      _ancDateCtrl.text       = c.ancDate;
      _nextVisitCtrl.text     = c.nextVisit;
      _planDelPlaceCtrl.text  = c.plannedDeliveryPlace;
      _healthStatusCtrl.text  = c.currentHealthStatus;
      _remarksCtrl.text       = c.remarks;

      _childBornThisYear = c.childBornThisYear.isEmpty ? null : c.childBornThisYear;
      _deliveryType      = c.deliveryType.isEmpty ? null : c.deliveryType;
      _contraMethod      = c.contraceptiveMethod.isEmpty ? null : c.contraceptiveMethod;
      _stoppingOrSpacing = c.stoppingOrSpacing.isEmpty ? null : c.stoppingOrSpacing;
      _noContraReason    = c.noContraReason.isEmpty ? null : c.noContraReason;
      _ancDone           = c.ancDone.isEmpty ? null : c.ancDone;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _frnoCtrl, _ecnoCtrl, _rchidCtrl, _husbandNameCtrl, _wifeNameCtrl,
      _regDateCtrl, _bankAcCtrl, _bankBranchCtrl, _husbandAgeMarCtrl,
      _wifeAgeMarCtrl, _motherAgeCtrl, _totalPregCtrl, _livingSonsCtrl,
      _livingDaughCtrl, _abortionsCtrl, _youngestDobCtrl, _lastDelDateCtrl,
      _lastDelPlaceCtrl, _postDelHealthCtrl, _sterilDateCtrl, _sterilPlaceCtrl,
      _pregnTestCtrl, _anNoCtrl, _ancDateCtrl, _nextVisitCtrl,
      _planDelPlaceCtrl, _healthStatusCtrl, _remarksCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _save() {
    if (_husbandNameCtrl.text.trim().isEmpty && _wifeNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Husband or Wife name is required'),
        backgroundColor: AppTheme.rose,
      ));
      return;
    }
    Navigator.pop(context, EligibleCouple(
      frno:                 _frnoCtrl.text.trim(),
      ecno:                 _ecnoCtrl.text.trim(),
      rchid:                _rchidCtrl.text.trim(),
      husbandName:          _husbandNameCtrl.text.trim(),
      wifeName:             _wifeNameCtrl.text.trim(),
      regDate:              _regDateCtrl.text.trim(),
      bankAc:               _bankAcCtrl.text.trim(),
      bankBranch:           _bankBranchCtrl.text.trim(),
      husbandAgeAtMarriage: _husbandAgeMarCtrl.text.trim(),
      wifeAgeAtMarriage:    _wifeAgeMarCtrl.text.trim(),
      motherCurrentAge:     _motherAgeCtrl.text.trim(),
      totalPregnancies:     _totalPregCtrl.text.trim(),
      livingSons:           _livingSonsCtrl.text.trim(),
      livingDaughters:      _livingDaughCtrl.text.trim(),
      abortions:            _abortionsCtrl.text.trim(),
      youngestChildDOB:     _youngestDobCtrl.text.trim(),
      lastDeliveryDate:     _lastDelDateCtrl.text.trim(),
      childBornThisYear:    _childBornThisYear ?? '',
      lastDeliveryPlace:    _lastDelPlaceCtrl.text.trim(),
      deliveryType:         _deliveryType ?? '',
      postDeliveryHealth:   _postDelHealthCtrl.text.trim(),
      contraceptiveMethod:  _contraMethod ?? '',
      stoppingOrSpacing:    _stoppingOrSpacing ?? '',
      noContraReason:       _noContraReason ?? '',
      sterilisationDate:    _sterilDateCtrl.text.trim(),
      sterilisationPlace:   _sterilPlaceCtrl.text.trim(),
      pregnancyTest:        _pregnTestCtrl.text.trim(),
      anNumber:             _anNoCtrl.text.trim(),
      ancDone:              _ancDone ?? '',
      ancDate:              _ancDateCtrl.text.trim(),
      nextVisit:            _nextVisitCtrl.text.trim(),
      plannedDeliveryPlace: _planDelPlaceCtrl.text.trim(),
      currentHealthStatus:  _healthStatusCtrl.text.trim(),
      remarks:              _remarksCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? '💑 Add Eligible Couple' : 'Edit Couple'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Identification ──────────────────────────────────
            _sec('🪪 Identification / அடையாளம்'),
            _txt('FR No.', _frnoCtrl, 'Family register number'),
            _txt('EC No.', _ecnoCtrl, 'Eligible couple number'),
            _txt('RCH ID', _rchidCtrl, 'RCH ID (wife)'),

            // ── Section 2: Couple Details ──────────────────────────────────
            _sec('💑 Couple Details / தம்பதியர் விவரம்'),
            _txt('Husband Name / கணவர் பெயர்', _husbandNameCtrl, 'Full name'),
            _txt('Wife Name / மனைவி பெயர்', _wifeNameCtrl, 'Full name'),
            _date('Registration Date', _regDateCtrl),

            // ── Section 3: Bank Details ────────────────────────────────────
            _sec('🏦 Bank Details / வங்கி விவரம்'),
            _txt('Bank Account No.', _bankAcCtrl, 'Account number'),
            _txt('Bank Branch', _bankBranchCtrl, 'Branch name'),

            // ── Section 4: Marriage & Pregnancies ─────────────────────────
            _sec('👶 Marriage & Children / திருமணம் & குழந்தைகள்'),
            _num('Husband Age at Marriage', _husbandAgeMarCtrl),
            _num('Wife Age at Marriage', _wifeAgeMarCtrl),
            _num("Mother's Current Age", _motherAgeCtrl),
            _num('Total Pregnancies', _totalPregCtrl),
            _num('Living Sons', _livingSonsCtrl),
            _num('Living Daughters', _livingDaughCtrl),
            _num('Abortions', _abortionsCtrl),
            _date('Youngest Child DOB', _youngestDobCtrl),
            _date('Last Delivery Date', _lastDelDateCtrl),
            _chip('Child Born This Year?', _yesNo, _childBornThisYear,
                (v) => setState(() => _childBornThisYear = v)),

            // ── Section 5: Delivery ────────────────────────────────────────
            _sec('🏥 Delivery Details / பிரசவ விவரம்'),
            _txt('Last Delivery Place', _lastDelPlaceCtrl, 'Hospital / Home'),
            _chip('Delivery Type', _delTypes, _deliveryType,
                (v) => setState(() => _deliveryType = v)),
            _txt('Post-Delivery Health', _postDelHealthCtrl, 'Health status after delivery'),

            // ── Section 6: Family Planning ─────────────────────────────────
            _sec('🛡️ Family Planning / குடும்ப நலத்திட்டம்'),
            _drop('Contraceptive Method', _fpMethods, _contraMethod,
                (v) => setState(() => _contraMethod = v)),
            _chip('Stopping / Spacing', _stopSpc, _stoppingOrSpacing,
                (v) => setState(() => _stoppingOrSpacing = v)),
            _drop('Reason for No Contraception', _noContraR, _noContraReason,
                (v) => setState(() => _noContraReason = v)),
            _date('Sterilisation Date', _sterilDateCtrl),
            _txt('Sterilisation Place', _sterilPlaceCtrl, 'Hospital name'),

            // ── Section 7: ANC / Antenatal ─────────────────────────────────
            _sec('🤰 Antenatal Care (ANC)'),
            _txt('Pregnancy Test Result', _pregnTestCtrl, 'Positive / Negative / N/A'),
            _txt('AN Number', _anNoCtrl, 'Antenatal number'),
            _chip('ANC Done?', _yesNo, _ancDone,
                (v) => setState(() => _ancDone = v)),
            _date('ANC Date', _ancDateCtrl),
            _date('Next Visit Date', _nextVisitCtrl),
            _txt('Planned Delivery Place', _planDelPlaceCtrl, 'Hospital / PHC'),
            _txt('Current Health Status', _healthStatusCtrl, 'Good / Fair / Poor'),

            // ── Section 8: Remarks ────────────────────────────────────────
            _sec('📝 Remarks'),
            _txt('Remarks / குறிப்புகள்', _remarksCtrl, 'Additional notes'),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('✅ Save Couple / தம்பதியர் சேமிக்க'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sec(String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 10),
    child: Text(text, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.teal)),
  );

  Widget _txt(String label, TextEditingController ctrl, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(text: label),
      TextField(controller: ctrl, decoration: InputDecoration(hintText: hint)),
    ]),
  );

  Widget _num(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(text: label),
      TextField(controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Number')),
    ]),
  );

  Widget _date(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FieldLabel(text: label),
      TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2100),
          );
          if (d != null) ctrl.text = d.toIso8601String().split('T')[0];
        },
        decoration: const InputDecoration(
          hintText: 'YYYY-MM-DD',
          suffixIcon: Icon(Icons.calendar_today, size: 18),
        ),
      ),
    ]),
  );

  Widget _chip(String label, List<String> opts, String? value, ValueChanged<String?> onChanged) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FieldLabel(text: label),
        ChipGroup(options: opts, value: value, onChanged: onChanged),
      ]),
    );

  Widget _drop(String label, List<String> opts, String? value, ValueChanged<String?> onChanged) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FieldLabel(text: label),
        DropdownButtonFormField<String>(
          value: value,
          hint: const Text('Select…', style: TextStyle(fontSize: 13)),
          decoration: const InputDecoration(),
          items: opts.map((o) => DropdownMenuItem(
            value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ]),
    );
}

// ── Compact card used inside survey wizard ─────────────────────────────────────
class CoupleCard extends StatelessWidget {
  final int index;
  final EligibleCouple couple;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CoupleCard({
    super.key,
    required this.index,
    required this.couple,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final names = [couple.husbandName, couple.wifeName]
        .where((n) => n.isNotEmpty)
        .join(' & ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFAF5FF),
          child: Text('💑', style: TextStyle(fontSize: 18)),
        ),
        title: Text(names.isEmpty ? 'Couple ${index + 1}' : names,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: couple.contraceptiveMethod.isNotEmpty
            ? Text('FP: ${couple.contraceptiveMethod}',
                style: const TextStyle(fontSize: 12))
            : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: AppTheme.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: AppTheme.rose),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}
