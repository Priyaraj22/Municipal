import '../models/survey_models.dart';

class SmartValidationResult {
  final List<String> errors;
  final List<String> warnings;
  SmartValidationResult({required this.errors, required this.warnings});

  bool get isValid => errors.isEmpty;
  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
}

class ValidationService {
  static SmartValidationResult validate(Survey survey) {
    final List<String> errors = [];
    final List<String> warnings = [];

    // 1. Basic Mandatory Fields
    if (survey.ward.isEmpty) errors.add('❌ Please select a ward.');
    if (survey.head.isEmpty) errors.add('❌ Family Head Name cannot be empty.');
    if (survey.door.isEmpty) errors.add('❌ Door No. is required.');
    if (survey.street.isEmpty) errors.add('❌ Street Name is required.');

    // 2. Members Validation
    final Set<String> aadhaarSet = {};
    for (var m in survey.members) {
      // Aadhaar number not 12 digits
      if (m.aadhar.isNotEmpty) {
        final cleanAadhaar = m.aadhar.replaceAll(' ', '');
        if (cleanAadhaar.length != 12) {
          errors.add('❌ Member ${m.name}: Please enter a valid 12-digit Aadhaar number.');
        }
        // Duplicate Aadhaar in the same survey
        if (aadhaarSet.contains(cleanAadhaar)) {
          warnings.add('⚠ This Aadhaar number (${m.aadhar}) already exists in another member of this survey.');
        }
        aadhaarSet.add(cleanAadhaar);
      }

      // Mobile number not starting with 6–9
      if (m.mobile.isNotEmpty) {
        if (m.mobile.length != 10) {
          errors.add('❌ Member ${m.name}: Mobile number must contain exactly 10 digits.');
        } else if (!RegExp(r'^[6-9]').hasMatch(m.mobile)) {
          errors.add('❌ Member ${m.name}: Mobile number must start with 6, 7, 8, or 9.');
        }
      }

      if (m.dob.isNotEmpty && m.age.isNotEmpty) {
        try {
          DateTime birth = DateTime.parse(m.dob);
          DateTime today = DateTime.now();
          int calcAge = today.year - birth.year;
          if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) calcAge--;
          
          int enteredAge = int.tryParse(m.age) ?? 0;
          
          // Age and DOB don't match
          if ((calcAge - enteredAge).abs() > 1) {
            warnings.add('⚠ ${m.name}: Age ($enteredAge) does not match the Date of Birth. Please verify.');
          }

          // Future DOB
          if (birth.isAfter(today)) {
            errors.add('❌ ${m.name}: Future Date of Birth is not allowed.');
          }

          // Child below 5 years -> Educational qualification check
          if (enteredAge < 5 && m.edu.isNotEmpty) {
            final validEdus = [
              'No Formal Education', 
              'Pre-School / Anganwadi', 
              'Not Applicable',
              'Primary (1–5)' // Allowed but warning if LKG/UKG not chosen
            ];
            if (!validEdus.any((e) => m.edu.contains(e))) {
              warnings.add('⚠ ${m.name}: Educational qualification seems incorrect for the entered age (under 5).');
            }
          }

          // Age 3 and Married -> Warning
          if (enteredAge < 10 && m.marital == 'Married') {
            warnings.add('⚠ ${m.name}: Age is $enteredAge but status is Married. Please verify.');
          }
        } catch (_) {}
      }

      // Male marked as Pregnant -> Show error (In Eligible Couple logic)

      // Death date before birth date
      if (m.deathDate.isNotEmpty && m.dob.isNotEmpty) {
        try {
          if (DateTime.parse(m.deathDate).isBefore(DateTime.parse(m.dob))) {
            errors.add('❌ ${m.name}: Death date cannot be before birth date.');
          }
        } catch (_) {}
      }
    }

    // 3. Eligible Couples logic
    for (var c in survey.couples) {
      final husband = survey.members.where((m) => m.name == c.husbandName).firstOrNull;
      final wife = survey.members.where((m) => m.name == c.wifeName).firstOrNull;

      if (husband != null && husband.gender == 'Female') {
        warnings.add('⚠ Husband (${husband.name}) is marked as Female. Please verify.');
      }
      if (wife != null && wife.gender == 'Male') {
        warnings.add('⚠ Wife (${wife.name}) is marked as Male. Please verify.');
      }
      
      // Eligible Couple with unmarried status
      if (husband != null && husband.marital == 'Unmarried') {
        warnings.add('⚠ ${husband.name} is in an Eligible Couple record but marked as Unmarried.');
      }
      if (wife != null && wife.marital == 'Unmarried') {
        warnings.add('⚠ ${wife.name} is in an Eligible Couple record but marked as Unmarried.');
      }
    }

    return SmartValidationResult(errors: errors, warnings: warnings);
  }
}
