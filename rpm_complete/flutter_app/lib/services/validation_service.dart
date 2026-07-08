import '../models/survey_models.dart';

class SmartValidationResult {
  final List<String> errors;
  final List<String> warnings;
  SmartValidationResult({required this.errors, required this.warnings});

  bool get isValid => errors.isEmpty;
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
}

class ValidationService {
  // --- Common Regex ---
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _numericRegex = RegExp(r'^[0-9]+$');
  static final RegExp _alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');

  // --- Survey Fields ---

  static String? validateSurveyId(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Auto-generated usually
    if (!RegExp(r'^RPM-[0-9]{6}$').hasMatch(value.trim())) {
      return 'Format: RPM-000001';
    }
    return null;
  }

  static String? validateWard(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ward is required';
    if (v.length > 100) return 'Maximum 100 characters';
    return null;
  }

  static String? validateWardId(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final n = int.tryParse(value.trim());
    if (n == null || n < 1 || n > 42) return 'Allowed: 1–42';
    return null;
  }

  static String? validateDoor(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Door No. is required';
    if (v.length > 20) return 'Maximum 20 characters';
    if (v.isNotEmpty && !_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateStreet(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Street name is required';
    if (v.length > 150) return 'Maximum 150 characters';
    return null;
  }

  static String? validateFamNo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 30) return 'Maximum 30 characters';
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateHead(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Family Head name is required';
    if (v.length < 2) return 'Minimum 2 characters';
    if (v.length > 100) return 'Maximum 100 characters';
    if (!_nameRegex.hasMatch(v)) return 'Only alphabets and spaces allowed';
    return null;
  }

  static String? validateRation(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 30) return 'Maximum 30 characters';
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateAbha(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_numericRegex.hasMatch(v) || v.length != 14) {
      return 'ABHA ID must contain exactly 14 digits.';
    }
    return null;
  }

  static String? validatePmja(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 30) return 'Maximum 30 characters';
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validatePhr(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 30) return 'Maximum 30 characters';
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateSmartcard(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (v.length > 30) return 'Maximum 30 characters';
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateCollector(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_nameRegex.hasMatch(v)) return 'Only alphabets and spaces';
    return null;
  }

  // --- Family Member Fields ---

  static String? validateMemNo(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateMemName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Name is required';
    if (!_nameRegex.hasMatch(v)) return 'Only alphabets and spaces';
    return null;
  }

  static String? validateDob(String? value) {
    if (value == null || value.isEmpty) return 'Date of Birth is required';
    return _validatePastDate(value);
  }

  static String? _validatePastDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) return 'Cannot be future date';
    } catch (_) {
      return 'Invalid date format';
    }
    return null;
  }

  static String? validateDeathDate(String? value) {
    return _validatePastDate(value);
  }

  static String? validateAge(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Age is required';
    final n = int.tryParse(v);
    if (n == null || n < 0 || n > 120) return 'Range: 0–120';
    return null;
  }

  static String? validateAadhar(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final clean = v.replaceAll(' ', '');
    if (!_numericRegex.hasMatch(clean) || clean.length != 12) {
      return 'Exactly 12 digits required';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Mobile number is required';
    if (!_numericRegex.hasMatch(v)) return 'Digits only';
    if (v.length > 10) return 'Phone number should not exceed 10 digits.';
    if (v.length < 10) return 'Phone number must contain exactly 10 digits.';
    return null;
  }

  static String? validateIncome(String? value) {
    final v = value?.trim() ?? '';
    if (v.isNotEmpty && !_numericRegex.hasMatch(v)) return 'Numeric only';
    return null;
  }

  static String? validateRemarks(String? value) {
    final v = value?.trim() ?? '';
    if (v.length > 500) return 'Maximum 500 characters';
    return null;
  }

  // --- Eligible Couple Fields ---

  static String? validateAlphanumeric(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_alphanumericRegex.hasMatch(v)) return 'Letters and numbers only';
    return null;
  }

  static String? validateBankAc(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_numericRegex.hasMatch(v)) return 'Numeric only';
    if (v.length < 9 || v.length > 18) return '9–18 digits';
    return null;
  }

  static String? validateHusbandAgeMarriage(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < 18 || n > 100) return 'Range 18–100';
    return null;
  }

  static String? validateWifeAgeMarriage(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < 18 || n > 100) return 'Range 18–100';
    return null;
  }

  static String? validateMotherCurrentAge(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < 15 || n > 100) return 'Range 15–100';
    return null;
  }

  // --- Complaint Fields ---
  static String? validateIssueType(String? value) {
    if (value == null || value.isEmpty) return 'Issue type is required';
    return null;
  }

  // --- Correction Request Fields ---
  static String? validateFieldName(String? value) {
    if (value == null || value.isEmpty) return 'Field name is required';
    return null;
  }

  static SmartValidationResult validate(Survey survey) {
    final List<String> errors = [];
    final List<String> warnings = [];

    // Use the individual validators for full survey validation
    String? err;
    if ((err = validateWard(survey.ward)) != null) errors.add('Ward: $err');
    if ((err = validateHead(survey.head)) != null) errors.add('Family Head: $err');
    if ((err = validateDoor(survey.door)) != null) errors.add('Door: $err');
    if ((err = validateStreet(survey.street)) != null) errors.add('Street: $err');
    if ((err = validateMobile(survey.phone)) != null) errors.add('Phone: $err');
    if ((err = validateAbha(survey.abha)) != null) errors.add('ABHA: $err');

    // Members Validation
    final Set<String> aadhaarSet = {};
    for (var m in survey.members) {
      if ((err = validateMemName(m.name)) != null) errors.add('Member ${m.name}: Name $err');
      if ((err = validateAadhar(m.aadhar)) != null) errors.add('Member ${m.name}: Aadhaar $err');
      if ((err = validateMobile(m.mobile)) != null) errors.add('Member ${m.name}: Mobile $err');
      if ((err = validateAge(m.age)) != null) errors.add('Member ${m.name}: Age $err');
      if ((err = validateDob(m.dob)) != null) errors.add('Member ${m.name}: DOB $err');

      if (m.aadhar.isNotEmpty) {
        final cleanAadhaar = m.aadhar.replaceAll(' ', '');
        if (aadhaarSet.contains(cleanAadhaar)) {
          warnings.add('⚠ This Aadhaar number (${m.aadhar}) already exists in another member of this survey.');
        }
        aadhaarSet.add(cleanAadhaar);
      }

      if (m.dob.isNotEmpty && m.age.isNotEmpty) {
        try {
          DateTime birth = DateTime.parse(m.dob);
          DateTime today = DateTime.now();
          int calcAge = today.year - birth.year;
          if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) calcAge--;
          
          int enteredAge = int.tryParse(m.age) ?? 0;
          if ((calcAge - enteredAge).abs() > 1) {
            warnings.add('⚠ ${m.name}: Age ($enteredAge) does not match the Date of Birth. Please verify.');
          }
        } catch (_) {}
      }
    }

    return SmartValidationResult(errors: errors, warnings: warnings);
  }
}
