// screens/member_form.dart
// Add/Edit individual family member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/survey_models.dart';
import '../services/validation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class MemberFormScreen extends StatefulWidget {
  final FamilyMember? existing;
  const MemberFormScreen({super.key, this.existing});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _aadharCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _deathDateCtrl = TextEditingController();
  final _deathReasonCtrl = TextEditingController();
  final _eduOtherCtrl = TextEditingController();
  final _occOtherCtrl = TextEditingController();
  final _relOtherCtrl = TextEditingController();
  final _religionOtherCtrl = TextEditingController();
  final _disabilityOtherCtrl = TextEditingController();
  final _ncdOtherCtrl = TextEditingController();
  final _cdOtherCtrl = TextEditingController();
  final _treatmentOtherCtrl = TextEditingController();

  String? _memno;
  String? _gender;
  String? _relationship;
  String? _blood;
  String? _marital;
  String? _edu;
  String? _occ;
  String? _religion;
  String? _income;
  String? _disability;
  String? _hasDisability;
  String? _hasChronicDisease;
  String? _chronicNCD;
  String? _chronicCD;
  String? _treatmentPlace;
  String? _vaccination;
  List<String> _selectedSchemes = [];

  final Map<String, String?> _errors = {};

  void _validateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'name': _errors['name'] = ValidationService.validateMemName(value); break;
        case 'dob': _errors['dob'] = ValidationService.validateDob(value); break;
        case 'age': _errors['age'] = ValidationService.validateAge(value); break;
        case 'aadhar': _errors['aadhar'] = ValidationService.validateAadhar(value); break;
        case 'mobile': _errors['mobile'] = ValidationService.validateMobile(value); break;
        case 'income': _errors['income'] = ValidationService.validateIncome(value); break;
        case 'deathDate': _errors['deathDate'] = ValidationService.validateDeathDate(value); break;
        case 'remarks': _errors['remarks'] = ValidationService.validateRemarks(value); break;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _nameCtrl.addListener(() => _validateField('name', _nameCtrl.text));
    _dobCtrl.addListener(() => _validateField('dob', _dobCtrl.text));
    _ageCtrl.addListener(() => _validateField('age', _ageCtrl.text));
    _aadharCtrl.addListener(() => _validateField('aadhar', _aadharCtrl.text));
    _mobileCtrl.addListener(() => _validateField('mobile', _mobileCtrl.text));
    _deathDateCtrl.addListener(() => _validateField('deathDate', _deathDateCtrl.text));
    _remarksCtrl.addListener(() => _validateField('remarks', _remarksCtrl.text));

    if (widget.existing != null) {
      final m = widget.existing!;
      _nameCtrl.text = m.name;
      _memno = m.memno.isEmpty ? null : m.memno;
      _dobCtrl.text = m.dob;
      _ageCtrl.text = m.age;
      _calculateAge(m.dob);

      _relationship = m.rel.isEmpty ? null : m.rel;
      final relOptions = [
        'Head of Family', 'Wife', 'Husband', 'Son', 'Daughter', 'Father', 'Mother',
        'Father-in-law', 'Mother-in-law', 'Brother', 'Sister', 'Grandfather',
        'Grandmother', 'Son-in-law', 'Daughter-in-law', 'Grandson', 'Granddaughter'
      ];
      if (_relationship != null && !relOptions.contains(_relationship)) {
        _relOtherCtrl.text = _relationship!;
        _relationship = 'Others';
      }

      _aadharCtrl.text = m.aadhar;
      _mobileCtrl.text = m.mobile;
      _remarksCtrl.text = m.remarks;
      _deathDateCtrl.text = m.deathDate;
      _deathReasonCtrl.text = m.deathReason;
      _treatmentPlace = m.treatmentPlace.isEmpty ? null : m.treatmentPlace;
      if (_treatmentPlace != null && !['None', 'Government Hospital', 'PHC (Primary Health Centre)', 'Private Hospital', 'Sub-Centre', 'Not under treatment'].contains(_treatmentPlace)) {
        _treatmentOtherCtrl.text = _treatmentPlace!;
        _treatmentPlace = 'Others';
      }

      _selectedSchemes = m.schemes.isEmpty ? [] : m.schemes.split(', ');
      _gender = m.gender.isEmpty ? null : m.gender;
      _income = m.income.isEmpty ? null : m.income;
      _blood = m.blood.isEmpty ? null : m.blood;
      _marital = m.marital.isEmpty ? null : m.marital;
      
      _edu = m.edu.isEmpty ? null : m.edu;
      if (_edu != null && !['No Formal Education', 'Pre-School / Anganwadi', 'Primary (1–5)', 'Upper Primary (6–8)', 'Secondary (9–10)', 'Higher Secondary (11–12)', 'Diploma / ITI', 'Undergraduate', 'Postgraduate', 'Professional (MBBS/BE etc.)'].contains(_edu)) {
        _eduOtherCtrl.text = _edu!;
        _edu = 'Others';
      }

      _occ = m.occ.isEmpty ? null : m.occ;
      if (_occ != null && !['Agriculture', 'Business', 'Daily Wages', 'Government Employee', 'Private Employee', 'Unemployed', 'Student', 'Homemaker'].contains(_occ)) {
        _occOtherCtrl.text = _occ!;
        _occ = 'Others';
      }

      _religion = m.religion.isEmpty ? null : m.religion;
      if (_religion != null && !['Hindu', 'Muslim', 'Christian'].contains(_religion)) {
        _religionOtherCtrl.text = _religion!;
        _religion = 'Others';
      }

      _disability = m.disability.isEmpty ? null : m.disability;
      if (_disability != null && _disability != 'None' && !['Hearing Impairment', 'Vision Loss', 'Autism', 'Physical Disability', 'Functional Impairment', 'Multiple Disabilities'].contains(_disability)) {
        _disabilityOtherCtrl.text = _disability!;
        _disability = 'Others';
      }

      _chronicNCD = m.chronicNCD.isEmpty ? null : m.chronicNCD;
      if (_chronicNCD != null && !['High Blood Pressure / Hypertension', 'Diabetes', 'Heart Disease', 'Respiratory Disease', 'Breast Cancer', 'Oral Cancer', 'Kidney Disorders', 'Chronic Mental Health Disorders'].contains(_chronicNCD)) {
        _ncdOtherCtrl.text = _chronicNCD!;
        _chronicNCD = 'Others';
      }

      _chronicCD = m.chronicCD.isEmpty ? null : m.chronicCD;
      if (_chronicCD != null && !['TB', 'Malaria', 'Dengue', 'HIV/AIDS', 'Hepatitis'].contains(_chronicCD)) {
        _cdOtherCtrl.text = _chronicCD!;
        _chronicCD = 'Others';
      }

      _hasDisability = (m.disability.isNotEmpty && m.disability != 'None') ? 'Yes' : 'No';
      _hasChronicDisease = m.hasChronicDisease.isEmpty ? null : m.hasChronicDisease;
      _vaccination = m.vaccination.isEmpty ? null : m.vaccination;
    }
  }

  void _calculateAge(String dob) {
    if (dob.isEmpty) return;
    try {
      DateTime birthDate = DateTime.parse(dob);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      _ageCtrl.text = age.toString();
    } catch (_) {}
  }

  Future<void> _pickDate(TextEditingController ctrl, {ValueChanged<String>? onDateSelected}) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      final dateStr = d.toIso8601String().split('T')[0];
      setState(() {
        ctrl.text = dateStr;
        if (onDateSelected != null) onDateSelected(dateStr);
      });
    }
  }

  void _save() {
    _validateField('name', _nameCtrl.text);
    _validateField('dob', _dobCtrl.text);
    _validateField('age', _ageCtrl.text);
    _validateField('aadhar', _aadharCtrl.text);
    _validateField('mobile', _mobileCtrl.text);

    if (_errors['name'] != null || _errors['dob'] != null || _errors['age'] != null || _errors['aadhar'] != null || _errors['mobile'] != null) {
      showToast(context, 'Please fix the errors before saving', isError: true);
      return;
    }

    final relVal = (_relationship == 'Others') ? _relOtherCtrl.text.trim() : (_relationship ?? '');
    final eduVal = (_edu == 'Others') ? _eduOtherCtrl.text.trim() : (_edu ?? '');
    final occVal = (_occ == 'Others') ? _occOtherCtrl.text.trim() : (_occ ?? '');
    final religionVal = (_religion == 'Others') ? _religionOtherCtrl.text.trim() : (_religion ?? '');
    final disVal = (_disability == 'Others') ? _disabilityOtherCtrl.text.trim() : (_disability ?? '');
    final ncdVal = (_chronicNCD == 'Others') ? _ncdOtherCtrl.text.trim() : (_chronicNCD ?? '');
    final cdVal = (_chronicCD == 'Others') ? _cdOtherCtrl.text.trim() : (_chronicCD ?? '');
    final treatVal = (_treatmentPlace == 'Others') ? _treatmentOtherCtrl.text.trim() : (_treatmentPlace ?? '');

    Navigator.pop(
      context,
      FamilyMember(
        name: _nameCtrl.text.trim(),
        memno: _memno ?? '',
        rel: relVal,
        dob: _dobCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        gender: _gender ?? '',
        aadhar: _aadharCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        blood: _blood ?? '',
        marital: _marital ?? '',
        edu: eduVal,
        occ: occVal,
        income: _income ?? '',
        religion: religionVal,
        deathDate: _deathDateCtrl.text.trim(),
        deathReason: _deathReasonCtrl.text.trim(),
        disability: disVal,
        hasChronicDisease: _hasChronicDisease ?? '',
        chronicNCD: ncdVal,
        chronicCD: cdVal,
        treatmentPlace: treatVal,
        schemes: _selectedSchemes.join(', '),
        vaccination: _vaccination ?? '',
        remarks: _remarksCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Add Family Member' : 'Edit Member'),
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
            _sectionHeader('👤 Basic Information'),
            _txt('Name *', _nameCtrl, 'Full name', errorText: _errors['name']),
            _drop('Member No.', List.generate(20, (i) => (i + 1).toString()), _memno, (v) => setState(() => _memno = v), hint: '— Select —'),
            _drop('Relationship', [
              'Head of Family', 'Wife', 'Husband', 'Son', 'Daughter', 'Father', 'Mother',
              'Father-in-law', 'Mother-in-law', 'Brother', 'Sister', 'Grandfather',
              'Grandmother', 'Son-in-law', 'Daughter-in-law', 'Grandson', 'Granddaughter', 'Others'
            ], _relationship, (v) => setState(() => _relationship = v), hint: '— Select —'),
            if (_relationship == 'Others') _txt('Specify Relationship', _relOtherCtrl, 'Specify'),

            _txt('Date of Birth', _dobCtrl, 'YYYY-MM-DD', isDate: true, onDateSelected: (v) => _calculateAge(v), errorText: _errors['dob']),
            _txt('Age', _ageCtrl, 'Age in years', keyboardType: TextInputType.number, errorText: _errors['age']),
            _chip('Gender', ['Male', 'Female', 'Other'], _gender, (v) => setState(() => _gender = v)),
            _txt('Aadhar No.', _aadharCtrl, '12-digit number', keyboardType: TextInputType.number, errorText: _errors['aadhar'], maxLength: 12),
            _txt('Mobile No.', _mobileCtrl, '10-digit number', keyboardType: TextInputType.phone, errorText: _errors['mobile'], maxLength: 10),
            _chip('Blood Group', ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
                _blood, (v) => setState(() => _blood = v)),
            _chip('Marital Status', ['Unmarried', 'Married', 'Widowed', 'Divorced', 'Separated'],
                _marital, (v) => setState(() => _marital = v)),

            const SizedBox(height: 16),
            _sectionHeader('🎓 Education & Occupation'),
            _drop('Education', [
              'No Formal Education', 'Pre-School / Anganwadi', 'Primary (1–5)', 'Upper Primary (6–8)', 'Secondary (9–10)', 'Higher Secondary (11–12)', 'Diploma / ITI', 'Undergraduate', 'Postgraduate', 'Professional (MBBS/BE etc.)', 'Others'
            ], _edu, (v) => setState(() => _edu = v), hint: '— Select —'),
            if (_edu == 'Others') _txt('Specify Education', _eduOtherCtrl, 'Specify'),

            _drop('Occupation', [
              'Agriculture', 'Business', 'Daily Wages', 'Government Employee', 'Private Employee', 'Unemployed', 'Student', 'Homemaker', 'Others'
            ], _occ, (v) => setState(() => _occ = v), hint: '— Select —'),
            if (_occ == 'Others') _txt('Specify Occupation', _occOtherCtrl, 'Specify'),

            _drop('Annual Income (₹)', [
              'Below ₹25,000', '₹25,001 – ₹50,000', '₹50,001 – ₹1,00,000', '₹1,00,001 – ₹2,00,000', '₹2,00,001 – ₹5,00,000', 'Above ₹5,00,000', 'Not Applicable'
            ], _income, (v) => setState(() => _income = v), hint: '— Select —'),

            _drop('Religion', ['Hindu', 'Muslim', 'Christian', 'Others'], _religion, (v) => setState(() => _religion = v), hint: '— Select —'),
            if (_religion == 'Others') _txt('Specify Religion', _religionOtherCtrl, 'Specify'),

            const SizedBox(height: 16),
            _sectionHeader('🏥 Health Details'),
            _chip('Disability?', ['No', 'Yes'], _hasDisability,
                (v) => setState(() {
                  _hasDisability = v;
                  if (v == 'No') _disability = 'None';
                })),
            if (_hasDisability == 'Yes') ...[
              _drop('Disability Category', [
                'Hearing Impairment', 'Vision Loss', 'Autism', 'Physical Disability', 'Functional Impairment', 'Multiple Disabilities', 'Others'
              ], _disability, (v) => setState(() => _disability = v), hint: '— Select —'),
              if (_disability == 'Others') _txt('Specify Disability', _disabilityOtherCtrl, 'Specify'),
            ],
            const SizedBox(height: 12),
            _chip('Chronic Disease?', ['No', 'Yes'], _hasChronicDisease,
                (v) => setState(() => _hasChronicDisease = v)),
            if (_hasChronicDisease == 'Yes') ...[
              _drop('NCD (Non-Communicable)', [
                'None', 'High Blood Pressure / Hypertension', 'Diabetes', 'Heart Disease', 'Respiratory Disease', 'Breast Cancer', 'Oral Cancer', 'Kidney Disorders', 'Chronic Mental Health Disorders', 'Others'
              ], _chronicNCD, (v) => setState(() => _chronicNCD = v), hint: '— Select —'),
              if (_chronicNCD == 'Others') _txt('Specify NCD', _ncdOtherCtrl, 'Specify'),

              _drop('CD (Communicable)', [
                'None', 'TB', 'Malaria', 'Dengue', 'HIV/AIDS', 'Hepatitis', 'Others'
              ], _chronicCD, (v) => setState(() => _chronicCD = v), hint: '— Select —'),
              if (_chronicCD == 'Others') _txt('Specify CD', _cdOtherCtrl, 'Specify'),

              _drop('Treatment Place', [
                'None', 'Government Hospital', 'PHC (Primary Health Centre)', 'Private Hospital', 'Sub-Centre', 'Not under treatment', 'Others'
              ], _treatmentPlace, (v) => setState(() => _treatmentPlace = v), hint: '— Select —'),
              if (_treatmentPlace == 'Others') _txt('Specify Treatment Place', _treatmentOtherCtrl, 'Specify'),
            ],
            const SizedBox(height: 12),
            _multiChip('Insurance & Welfare Schemes', [
              'None', 'PMJAY', 'CM Health Insurance', 'ESI', 'Private Insurance', 'Old Age Pension', 'Widow Pension', 'Disability Pension', 'MGNREGS', 'Scholarship', 'Others'
            ], _selectedSchemes, (v) => setState(() => _selectedSchemes = v)),
            const SizedBox(height: 12),
            _chip('Vaccination Status', ['Complete', 'Partial', 'Not Done', 'Unknown'],
                _vaccination, (v) => setState(() => _vaccination = v)),

            const SizedBox(height: 16),
            _sectionHeader('📝 Remarks'),
            _txt('Death Date (if applicable)', _deathDateCtrl, 'YYYY-MM-DD', isDate: true, errorText: _errors['deathDate']),
            _txt('Death Reason', _deathReasonCtrl, 'Cause of death'),
            _txt('Remarks', _remarksCtrl, 'Additional notes', errorText: _errors['remarks']),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text('✅ Save Member / சேமி'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.teal)),
  );

  Widget _txt(String label, TextEditingController ctrl, String hint,
      {TextInputType? keyboardType, bool isDate = false, ValueChanged<String>? onDateSelected, int? maxLength, String? errorText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(text: label),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            readOnly: isDate,
            maxLength: maxLength,
            onTap: isDate ? () => _pickDate(ctrl, onDateSelected: onDateSelected) : null,
            decoration: InputDecoration(
              hintText: hint,
              counterText: "",
              errorText: errorText,
              suffixIcon: isDate ? const Icon(Icons.calendar_today, size: 18) : null,
              enabledBorder: errorText != null ? const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.rose, width: 1)) : null,
              focusedBorder: errorText != null ? const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.rose, width: 2)) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, List<String> opts, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(text: label),
          ChipGroup(options: opts, value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _drop(String label, List<String> opts, String? value, ValueChanged<String?> onChanged, {String hint = 'Select…'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(text: label),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: (value != null && opts.contains(value)) ? value : null,
            hint: Text(hint, style: const TextStyle(fontSize: 13)),
            decoration: const InputDecoration(),
            items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _multiChip(String label, List<String> opts, List<String> values, ValueChanged<List<String>> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: label),
        MultiChipGroup(options: opts, values: values, onChanged: onChanged),
      ],
    );
  }
}

// ── Compact member card in survey step 1 ──
class MemberCard extends StatelessWidget {
  final int index;
  final FamilyMember member;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MemberCard({
    super.key,
    required this.index,
    required this.member,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEBF2FF),
          child: Text('${index + 1}',
              style: const TextStyle(color: AppTheme.blue, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        title: Text(member.name.isEmpty ? 'Unnamed' : member.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [if (member.rel.isNotEmpty) member.rel, if (member.age.isNotEmpty) 'Age: ${member.age}'].join(' · '),
          style: const TextStyle(fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.blue),
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.rose),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
