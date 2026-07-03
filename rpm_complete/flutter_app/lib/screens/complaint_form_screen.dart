import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String surveyId;
  final String street;
  const ComplaintFormScreen({super.key, required this.surveyId, required this.street});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  String? _issueType;
  final _descCtrl = TextEditingController();
  bool _submitting = false;

  final List<String> _issues = [
    'Water Supply / குடிநீர்',
    'Street Light / தெரு விளக்கு',
    'Garbage Collection / குப்பை',
    'Drainage / சாக்கடை',
    'Road Condition / சாலை',
    'Stray Dogs / தெரு நாய்கள்',
    'Others / மற்றவை'
  ];

  Future<void> _submit() async {
    if (_issueType == null) {
      showToast(context, 'Please select issue type', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthProvider>();
      await ApiService.registerComplaint({
        'survey_id': widget.surveyId,
        'citizen_mobile': auth.citizenPhone,
        'issue_type': _issueType,
        'description': _descCtrl.text.trim(),
        'street': widget.street,
      });
      if (mounted) {
        showToast(context, '✅ Complaint registered successfully');
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
      appBar: AppBar(title: const Text('Register Complaint')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Report a Municipal Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Location: ${widget.street}', style: const TextStyle(color: AppTheme.ink3)),
                const Divider(height: 32),
                
                const FieldLabel(text: 'Issue Type / புகார் வகை *'),
                DropdownButtonFormField<String>(
                  value: _issueType,
                  hint: const Text('— Select Issue —'),
                  items: _issues.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                  onChanged: (v) => setState(() => _issueType = v),
                ),
                const SizedBox(height: 20),
                
                const FieldLabel(text: 'Description / விவரம்'),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Enter more details...'),
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                  child: const Text('Submit Complaint'),
                ),
              ],
            ),
          ),
          if (_submitting) const LoadingOverlay(message: 'Submitting...'),
        ],
      ),
    );
  }
}
