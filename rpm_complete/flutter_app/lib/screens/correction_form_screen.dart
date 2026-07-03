import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class CorrectionFormScreen extends StatefulWidget {
  final String surveyId;
  final String currentVal;
  final String fieldName;

  const CorrectionFormScreen({
    super.key,
    required this.surveyId,
    required this.currentVal,
    required this.fieldName,
  });

  @override
  State<CorrectionFormScreen> createState() => _CorrectionFormScreenState();
}

class _CorrectionFormScreenState extends State<CorrectionFormScreen> {
  final _newValCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _newValCtrl.text = widget.currentVal;
  }

  Future<void> _submit() async {
    if (_newValCtrl.text.trim() == widget.currentVal) {
      showToast(context, 'No changes made', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ApiService.requestCorrection({
        'survey_id': widget.surveyId,
        'field_name': widget.fieldName,
        'old_value': widget.currentVal,
        'new_value': _newValCtrl.text.trim(),
      });
      if (mounted) {
        showToast(context, '✅ Correction request sent to Surveyor');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Correction')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Updating: ${widget.fieldName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Text('Current Value: ${widget.currentVal}', style: const TextStyle(color: AppTheme.ink3)),
            const Divider(height: 32),
            FieldLabel(text: 'Corrected Value / புதிய விவரம் *'),
            TextField(
              controller: _newValCtrl,
              decoration: const InputDecoration(hintText: 'Enter the correct details...'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}
