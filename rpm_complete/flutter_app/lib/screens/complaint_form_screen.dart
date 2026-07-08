import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../services/validation_service.dart';
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
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
  final Map<String, String?> _errors = {};

  void _validateField(String field, String value) {
    setState(() {
      switch (field) {
        case 'issueType': _errors['issueType'] = ValidationService.validateIssueType(value); break;
        case 'description': _errors['description'] = ValidationService.validateRemarks(value); break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => _validateField('description', _descCtrl.text));
  }

  final List<String> _issues = [
    'Water Supply / குடிநீர்',
    'Street Light / தெரு விளக்கு',
    'Garbage Collection / குப்பை',
    'Drainage / சாக்கடை',
    'Road Condition / சாலை',
    'Stray Dogs / தெரு நாய்கள்',
    'Others / மற்றவை'
  ];

  Future<void> _pickImage() async {
    if (_photos.length >= 5) {
      showToast(context, 'Maximum 5 photos allowed', isError: true);
      return;
    }
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress for faster upload
      maxWidth: 1000,
    );
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  Future<void> _submit() async {
    _validateField('issueType', _issueType ?? '');
    _validateField('description', _descCtrl.text);

    if (_errors.values.any((e) => e != null)) {
      showToast(context, 'Please fix the errors', isError: true);
      return;
    }
    if (_photos.length < 2) {
      showToast(context, 'Please upload at least 2 photos as evidence', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthProvider>();
      
      // Convert photos to base64
      List<String> base64Photos = [];
      for (var f in _photos) {
        final bytes = await f.readAsBytes();
        base64Photos.add(base64Encode(bytes));
      }

      await ApiService.registerComplaint({
        'survey_id': widget.surveyId,
        'citizen_mobile': auth.citizenPhone,
        'issue_type': _issueType,
        'description': _descCtrl.text.trim(),
        'street': widget.street,
        'evidence_photos': base64Photos,
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
                  decoration: InputDecoration(errorText: _errors['issueType']),
                  items: _issues.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                  onChanged: (v) {
                    setState(() => _issueType = v);
                    _validateField('issueType', v ?? '');
                  },
                ),
                const SizedBox(height: 20),
                
                const FieldLabel(text: 'Description / விவரம்'),
                TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter more details...',
                    errorText: _errors['description'],
                    enabledBorder: _errors['description'] != null ? const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.rose, width: 1)) : null,
                    focusedBorder: _errors['description'] != null ? const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.rose, width: 2)) : null,
                  ),
                ),
                const SizedBox(height: 24),

                const FieldLabel(text: 'Evidence Photos (Min 2 required) *'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._photos.asMap().entries.map((e) => Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: FileImage(e.value), fit: BoxFit.cover),
                              border: Border.all(color: AppTheme.border),
                            ),
                          ),
                          Positioned(
                            top: 0, right: 12,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(e.key)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )),
                      if (_photos.length < 5)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.blue.withOpacity(0.3), style: BorderStyle.values[1]),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.blue),
                          ),
                        ),
                    ],
                  ),
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
