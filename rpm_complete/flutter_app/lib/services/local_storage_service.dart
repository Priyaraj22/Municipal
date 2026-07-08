import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as xl;
import 'package:xml/xml.dart';
import '../models/survey_models.dart';

class LocalStorageService {
  static const String _fileName = 'local_surveys.json';

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<List<Survey>> getAllSurveys() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List list = json.decode(content);
      return list.map((s) => Survey.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveSurvey(Survey survey) async {
    final surveys = await getAllSurveys();
    
    // If updating existing (by matching some local ID or just checking properties)
    // For local mode, we'll assign a local ID if not present
    if (survey.id == null) {
       // Simple local ID generation
       survey.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    final index = surveys.indexWhere((s) => s.id == survey.id);
    if (index != -1) {
      surveys[index] = survey;
    } else {
      surveys.add(survey);
    }

    final file = await _getFile();
    await file.writeAsString(json.encode(surveys.map((s) => s.toJson()).toList()));
  }

  static Future<void> deleteSurvey(String id) async {
    final surveys = await getAllSurveys();
    surveys.removeWhere((s) => s.id == id);
    final file = await _getFile();
    await file.writeAsString(json.encode(surveys.map((s) => s.toJson()).toList()));
  }

  static Future<String> exportToExcel() async {
    final surveys = await getAllSurveys();
    var excel = xl.Excel.createExcel();
    xl.Sheet sheetObject = excel['Surveys'];

    // Headers
    sheetObject.appendRow([
      xl.TextCellValue('Survey ID'),
      xl.TextCellValue('Ward'),
      xl.TextCellValue('Door No'),
      xl.TextCellValue('Street'),
      xl.TextCellValue('Family Head'),
      xl.TextCellValue('Phone Number'),
      xl.TextCellValue('Ration Card'),
      xl.TextCellValue('ABHA'),
      xl.TextCellValue('PMJA'),
      xl.TextCellValue('PHR'),
      xl.TextCellValue('Smart Card'),
      xl.TextCellValue('BPL/APL'),
      xl.TextCellValue('Caste'),
      xl.TextCellValue('Status'),
      xl.TextCellValue('Date'),
    ]);

    for (var s in surveys) {
      sheetObject.appendRow([
        xl.TextCellValue(s.surveyId ?? s.id ?? ''),
        xl.TextCellValue(s.ward),
        xl.TextCellValue(s.door),
        xl.TextCellValue(s.street),
        xl.TextCellValue(s.head),
        xl.TextCellValue(s.phone),
        xl.TextCellValue(s.ration),
        xl.TextCellValue(s.abha),
        xl.TextCellValue(s.pmja),
        xl.TextCellValue(s.phr),
        xl.TextCellValue(s.smartcard),
        xl.TextCellValue(s.bpl),
        xl.TextCellValue(s.caste),
        xl.TextCellValue(s.status),
        xl.TextCellValue(s.date ?? ''),
      ]);
    }

    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Survey_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
    return filePath;
  }

  static Future<String> exportToXML() async {
    final surveys = await getAllSurveys();
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('RajapalayamSurveyData', nest: () {
      builder.element('ExportMetadata', nest: () {
        builder.element('ExportTimestamp', nest: DateTime.now().toIso8601String());
        builder.element('TotalSurveys', nest: surveys.length.toString());
      });

      builder.element('Surveys', nest: () {
        for (var s in surveys) {
          builder.element('Survey', nest: () {
            // Location & Identity
            builder.element('SurveyID', nest: s.surveyId ?? s.id);
            builder.element('Ward', nest: s.ward);
            builder.element('DoorNo', nest: s.door);
            builder.element('Street', nest: s.street);
            builder.element('FamilyRegisterNo', nest: s.famno);
            builder.element('FamilyHead', nest: s.head);
            builder.element('Phone', nest: s.phone);

            // Govt IDs
            builder.element('GovtIDs', nest: () {
              builder.element('RationCard', nest: s.ration);
              builder.element('ABHA', nest: s.abha);
              builder.element('PMJA', nest: s.pmja);
              builder.element('PHR', nest: s.phr);
              builder.element('SmartCard', nest: s.smartcard);
            });

            // Household Details
            builder.element('HouseholdDetails', nest: () {
              builder.element('BPL_APL', nest: s.bpl);
              builder.element('Caste', nest: s.caste);
              builder.element('HealthInsurance', nest: s.insurance);
              builder.element('HousingType', nest: s.housing);
              builder.element('WaterSource', nest: s.water);
              builder.element('ToiletFacility', nest: s.toilet);
            });

            // Collection Metadata
            builder.element('Metadata', nest: () {
              builder.element('Collector', nest: s.collector ?? '');
              builder.element('CollectorWard', nest: s.collectorWard ?? '');
              builder.element('SurveyDate', nest: s.date ?? '');
              builder.element('Status', nest: s.status);
            });

            // Family Members
            builder.element('FamilyMembers', nest: () {
              for (var m in s.members) {
                builder.element('Member', nest: () {
                  builder.element('MemberNo', nest: m.memno);
                  builder.element('Name', nest: m.name);
                  builder.element('Relationship', nest: m.rel);
                  builder.element('DOB', nest: m.dob);
                  builder.element('Age', nest: m.age);
                  builder.element('Gender', nest: m.gender);
                  builder.element('Aadhaar', nest: m.aadhar);
                  builder.element('Mobile', nest: m.mobile);
                  builder.element('BloodGroup', nest: m.blood);
                  builder.element('MaritalStatus', nest: m.marital);
                  builder.element('Education', nest: m.edu);
                  builder.element('Occupation', nest: m.occ);
                  builder.element('Income', nest: m.income);
                  builder.element('Religion', nest: m.religion);

                  if (m.newMemDate.isNotEmpty) {
                    builder.element('AdditionDetails', nest: () {
                      builder.element('Date', nest: m.newMemDate);
                      builder.element('Reason', nest: m.newMemReason);
                    });
                  }

                  builder.element('HealthDetails', nest: () {
                    builder.element('Disability', nest: m.disability);
                    builder.element('HasChronicDisease', nest: m.hasChronicDisease);
                    builder.element('ChronicNCD', nest: m.chronicNCD);
                    builder.element('ChronicCD', nest: m.chronicCD);
                    builder.element('TreatmentPlace', nest: m.treatmentPlace);
                    builder.element('Vaccination', nest: m.vaccination);
                  });

                  builder.element('WelfareSchemes', nest: m.schemes);

                  if (m.deathDate.isNotEmpty) {
                    builder.element('DeathDetails', nest: () {
                      builder.element('DeathDate', nest: m.deathDate);
                      builder.element('DeathReason', nest: m.deathReason);
                    });
                  }

                  builder.element('Remarks', nest: m.remarks);
                });
              }
            });

            // Eligible Couples
            builder.element('EligibleCouples', nest: () {
              for (var c in s.couples) {
                builder.element('Couple', nest: () {
                  builder.element('FRNo', nest: c.frno);
                  builder.element('ECNo', nest: c.ecno);
                  builder.element('RCHID', nest: c.rchid);
                  builder.element('HusbandName', nest: c.husbandName);
                  builder.element('WifeName', nest: c.wifeName);
                  builder.element('RegDate', nest: c.regDate);

                  builder.element('BankInfo', nest: () {
                    builder.element('AccountNo', nest: c.bankAc);
                    builder.element('Branch', nest: c.bankBranch);
                  });

                  builder.element('MarriageInfo', nest: () {
                    builder.element('HusbandAgeAtMarriage', nest: c.husbandAgeAtMarriage);
                    builder.element('WifeAgeAtMarriage', nest: c.wifeAgeAtMarriage);
                    builder.element('MotherCurrentAge', nest: c.motherCurrentAge);
                  });

                  builder.element('PregnancyHistory', nest: () {
                    builder.element('TotalPregnancies', nest: c.totalPregnancies);
                    builder.element('LivingSons', nest: c.livingSons);
                    builder.element('LivingDaughters', nest: c.livingDaughters);
                    builder.element('Abortions', nest: c.abortions);
                    builder.element('YoungestChildDOB', nest: c.youngestChildDOB);
                  });

                  builder.element('LastDelivery', nest: () {
                    builder.element('Date', nest: c.lastDeliveryDate);
                    builder.element('Place', nest: c.lastDeliveryPlace);
                    builder.element('Type', nest: c.deliveryType);
                    builder.element('PostHealth', nest: c.postDeliveryHealth);
                    builder.element('ChildBornThisYear', nest: c.childBornThisYear);
                  });

                  builder.element('FamilyPlanning', nest: () {
                    builder.element('Method', nest: c.contraceptiveMethod);
                    builder.element('StoppingOrSpacing', nest: c.stoppingOrSpacing);
                    builder.element('ReasonNoContra', nest: c.noContraReason);
                    builder.element('SterilisationDate', nest: c.sterilisationDate);
                    builder.element('SterilisationPlace', nest: c.sterilisationPlace);
                  });

                  builder.element('AntenatalCare', nest: () {
                    builder.element('PregnancyTest', nest: c.pregnancyTest);
                    builder.element('ANNumber', nest: c.anNumber);
                    builder.element('ANCDone', nest: c.ancDone);
                    builder.element('ANCDate', nest: c.ancDate);
                    builder.element('NextVisit', nest: c.nextVisit);
                    builder.element('PlannedDeliveryPlace', nest: c.plannedDeliveryPlace);
                  });

                  builder.element('CurrentHealth', nest: c.currentHealthStatus);
                  builder.element('Remarks', nest: c.remarks);
                });
              }
            });
          });
        }
      });
    });

    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Survey_Export_${DateTime.now().millisecondsSinceEpoch}.xml';
    final document = builder.buildDocument();
    await File(filePath).writeAsString(document.toXmlString(pretty: true));
    return filePath;
  }

  static Future<String> exportToJSON() async {
    final surveys = await getAllSurveys();
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Survey_Export_${DateTime.now().millisecondsSinceEpoch}.json';
    final content = json.encode(surveys.map((s) => s.toJson()).toList());
    await File(filePath).writeAsString(content);
    return filePath;
  }
}
