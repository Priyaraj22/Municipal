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
    builder.processing('xml', 'version="1.0"');
    builder.element('Surveys', nest: () {
      for (var s in surveys) {
        builder.element('Survey', nest: () {
          builder.element('ID', nest: s.surveyId ?? s.id);
          builder.element('Ward', nest: s.ward);
          builder.element('Head', nest: s.head);
          builder.element('Phone', nest: s.phone);
          builder.element('Address', nest: '${s.door}, ${s.street}');
          builder.element('Status', nest: s.status);
          
          builder.element('Members', nest: () {
            for (var m in s.members) {
              builder.element('Member', nest: () {
                builder.element('Name', nest: m.name);
                builder.element('Age', nest: m.age);
                builder.element('Relation', nest: m.rel);
              });
            }
          });
        });
      }
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
