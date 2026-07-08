import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as xl;
import 'package:xml/xml.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/survey_models.dart';

class LocalStorageService {
  static const String _fileName = 'local_surveys.json';
  static const String _folderName = 'Rajapalayam_Surveys';

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Attempts to find the most accessible public directory
  static Future<Directory> _getExportDirectory() async {
    Directory? baseDir;
    
    if (Platform.isAndroid) {
      // 1. Try common public Download path
      baseDir = Directory('/storage/emulated/0/Download');
      if (!await baseDir.exists()) {
        // 2. Try reaching it via external storage path navigation
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          // Go up from /storage/emulated/0/Android/data/package/files to /storage/emulated/0/
          String path = extDir.path;
          if (path.contains('/Android/data')) {
            path = path.split('/Android/data')[0];
            baseDir = Directory('$path/Download');
          }
        }
      }
    }

    // 3. Last resort fallback to app's own external folder (still visible in File Manager)
    if (baseDir == null || !await baseDir.exists()) {
      baseDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    }

    final exportDir = Directory('${baseDir.path}/$_folderName');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Requests permissions. On Android 11+, this triggers the "All Files Access" settings page.
  static Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;

    // Check if we already have it
    if (await Permission.manageExternalStorage.isGranted) return true;

    // Request it (this will open the system settings page on Android 11+)
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    // Fallback for older devices or if they just granted standard storage
    if (await Permission.storage.request().isGranted) return true;

    return false;
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
    
    if (survey.id == null) {
      // Find the highest numeric ID and increment it
      int maxId = 0;
      for (var s in surveys) {
        final sid = int.tryParse(s.id ?? '0') ?? 0;
        if (sid > maxId) maxId = sid;
      }
      survey.id = (maxId + 1).toString();
      surveys.add(survey);
    } else {
      // Overwrite existing record
      final index = surveys.indexWhere((s) => s.id == survey.id);
      if (index != -1) {
        surveys[index] = survey;
      } else {
        surveys.add(survey);
      }
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
    final ok = await _requestPermission();
    if (!ok) throw Exception('Storage permission required to create folder');

    final allSurveys = await getAllSurveys();
    final surveys = allSurveys.where((s) => s.status == 'Submitted').toList();
    
    var excel = xl.Excel.createExcel();
    xl.Sheet sheetObject = excel['Surveys'];

    sheetObject.appendRow([
      xl.TextCellValue('Survey ID'), xl.TextCellValue('Ward'), xl.TextCellValue('Door No'),
      xl.TextCellValue('Street'), xl.TextCellValue('Family Head'), xl.TextCellValue('Phone Number'),
      xl.TextCellValue('Ration Card'), xl.TextCellValue('ABHA'), xl.TextCellValue('PMJA'),
      xl.TextCellValue('PHR'), xl.TextCellValue('Smart Card'), xl.TextCellValue('BPL/APL'),
      xl.TextCellValue('Caste'), xl.TextCellValue('Status'), xl.TextCellValue('Date'),
      xl.TextCellValue('Surveyor'),
    ]);

    for (var s in surveys) {
      sheetObject.appendRow([
        xl.TextCellValue(s.surveyId ?? s.id ?? ''), xl.TextCellValue(s.ward), xl.TextCellValue(s.door),
        xl.TextCellValue(s.street), xl.TextCellValue(s.head), xl.TextCellValue(s.phone),
        xl.TextCellValue(s.ration), xl.TextCellValue(s.abha), xl.TextCellValue(s.pmja),
        xl.TextCellValue(s.phr), xl.TextCellValue(s.smartcard), xl.TextCellValue(s.bpl),
        xl.TextCellValue(s.caste), xl.TextCellValue(s.status), xl.TextCellValue(s.date ?? ''),
        xl.TextCellValue(s.collector ?? ''),
      ]);
    }

    final directory = await _getExportDirectory();
    final filePath = '${directory.path}/Survey_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);
    }
    return filePath;
  }

  static Future<String> exportToXML() async {
    final ok = await _requestPermission();
    if (!ok) throw Exception('Storage permission required');

    final allSurveys = await getAllSurveys();
    final surveys = allSurveys.where((s) => s.status == 'Submitted').toList();

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
          builder.element('Surveyor', nest: s.collector);
          builder.element('Date', nest: s.date);
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

    final directory = await _getExportDirectory();
    final filePath = '${directory.path}/Survey_${DateTime.now().millisecondsSinceEpoch}.xml';
    final document = builder.buildDocument();
    await File(filePath).writeAsString(document.toXmlString(pretty: true), flush: true);
    return filePath;
  }

  static Future<String> exportToJSON() async {
    final ok = await _requestPermission();
    if (!ok) throw Exception('Storage permission required');

    final allSurveys = await getAllSurveys();
    final surveys = allSurveys.where((s) => s.status == 'Submitted').toList();

    final directory = await _getExportDirectory();
    final filePath = '${directory.path}/Survey_${DateTime.now().millisecondsSinceEpoch}.json';
    final content = json.encode(surveys.map((s) => s.toJson()).toList());
    await File(filePath).writeAsString(content, flush: true);
    return filePath;
  }
}
