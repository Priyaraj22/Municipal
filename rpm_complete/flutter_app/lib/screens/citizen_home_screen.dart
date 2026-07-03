import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../models/survey_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'complaint_form_screen.dart';
import 'correction_form_screen.dart';
import 'login_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  Survey? _myFamily;
  List<Complaint> _myComplaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final surveys = await ApiService.getSurveys(); 
      final complaints = await ApiService.getMyComplaints(auth.citizenPhone ?? '');

      setState(() {
        if (surveys.isNotEmpty) _myFamily = surveys[0];
        _myComplaints = complaints;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to load data: $e', isError: true);
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipal Citizen Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_myFamily != null) ...[
                _buildFamilyCard(),
                const SizedBox(height: 16),
                _buildMembersList(),
                const SizedBox(height: 16),
                _buildCouplesList(),
              ],
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 20),
              _buildComplaintsList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyCard() {
    return SectionCard(
      icon: const SectionIcon(emoji: '🏠', color: Color(0xFFEBF2FF)),
      title: 'Family & Location Details',
      subtitle: 'Survey ID: ${_myFamily!.surveyId}',
      body: Column(
        children: [
          _infoRow('Head Name', _myFamily!.head, canCorrect: true),
          _infoRow('Ward', _myFamily!.ward),
          _infoRow('Door No', _myFamily!.door, canCorrect: true),
          _infoRow('Street', _myFamily!.street, canCorrect: true),
          _infoRow('Family No (FR)', _myFamily!.famno, canCorrect: true),
          _infoRow('Ration Card', _myFamily!.ration, canCorrect: true),
          _infoRow('ABHA ID', _myFamily!.abha, canCorrect: true),
          _infoRow('PMJA No', _myFamily!.pmja, canCorrect: true),
          _infoRow('PHR No', _myFamily!.phr, canCorrect: true),
          _infoRow('Smart Card', _myFamily!.smartcard, canCorrect: true),
          _infoRow('BPL/APL', _myFamily!.bpl, canCorrect: true),
          _infoRow('Caste', _myFamily!.caste, canCorrect: true),
          _infoRow('Insurance', _myFamily!.insurance, canCorrect: true),
          _infoRow('Housing', _myFamily!.housing, canCorrect: true),
          _infoRow('Water Source', _myFamily!.water, canCorrect: true),
          _infoRow('Toilet', _myFamily!.toilet, canCorrect: true),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Family Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ..._myFamily!.members.map((m) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.person, color: AppTheme.blue)),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${m.rel} · Age: ${m.age}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('Full Name', m.name, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Member No', m.memno, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Relationship', m.rel, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('DOB', m.dob, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Age', m.age, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Gender', m.gender, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Aadhaar', m.aadhar, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Mobile', m.mobile, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Blood Group', m.blood, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Marital Status', m.marital, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Education', m.edu, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Occupation', m.occ, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Income', m.income, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Religion', m.religion, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Disability', m.disability, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Chronic Disease', m.hasChronicDisease, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('NCD Details', m.chronicNCD, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('CD Details', m.chronicCD, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Treatment Place', m.treatmentPlace, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Schemes', m.schemes, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Vaccination', m.vaccination, canCorrect: true, contextStr: 'Member: ${m.name}'),
                    _infoRow('Remarks', m.remarks, canCorrect: true, contextStr: 'Member: ${m.name}'),
                  ],
                ),
              )
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCouplesList() {
    if (_myFamily!.couples.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text('Eligible Couples', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ..._myFamily!.couples.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFEBF2FF), child: Icon(Icons.favorite, color: Colors.pink)),
            title: Text('${c.husbandName} & ${c.wifeName}'),
            subtitle: Text('Reg: ${c.regDate}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('Husband Name', c.husbandName, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('Wife Name', c.wifeName, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('Living Sons', c.livingSons, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('Living Daughters', c.livingDaughters, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('Pregnancies', c.totalPregnancies, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('Contraception', c.contraceptiveMethod, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                    _infoRow('ANC Done', c.ancDone, canCorrect: true, contextStr: 'Couple: ${c.wifeName}'),
                  ],
                ),
              )
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionCard('Register Complaint', Icons.report_problem_rounded, Colors.orange, _openComplaintForm),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard('Help & Support', Icons.help_outline_rounded, AppTheme.blue, () {
             showToast(context, 'Helpline: 04563-123456');
          }),
        ),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Municipal Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (_myComplaints.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No complaints registered yet.', style: TextStyle(color: AppTheme.ink3)),
          ))
        else
          ..._myComplaints.map((c) => Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.assignment_turned_in_outlined),
                  title: Text(c.issueType),
                  subtitle: Text(c.createdAt?.split('T')[0] ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(c.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c.status,
                      style: TextStyle(color: _getStatusColor(c.status), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (c.status == 'Resolved')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _handleSatisfied(c),
                          icon: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.green),
                          label: const Text('I am Satisfied', style: TextStyle(color: Colors.green, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _handleReopen(c),
                          icon: const Icon(Icons.replay_rounded, size: 16, color: Colors.red),
                          label: const Text('Not Satisfied / Reopen', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )),
      ],
    );
  }

  Future<void> _handleSatisfied(Complaint c) async {
    final feedbackCtrl = TextEditingController();
    int rating = 5;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Feedback / கருத்து'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How satisfied are you with the resolution?', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  onPressed: () => setDialogState(() => rating = index + 1),
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                )),
              ),
              TextField(
                controller: feedbackCtrl,
                decoration: const InputDecoration(hintText: 'Share your feedback (optional)...'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ApiService.submitComplaintFeedback(c.id!, 'Closed - Satisfied', 
                  feedback: feedbackCtrl.text.trim(), rating: rating);
                showToast(context, 'Thank you for your feedback! ❤️');
                _loadData();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReopen(Complaint c) async {
    final reasonCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen Complaint'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: 'Why are you not satisfied?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (reasonCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              await ApiService.submitComplaintFeedback(c.id!, 'Reopened', feedback: reasonCtrl.text.trim());
              showToast(context, 'Complaint reopened for urgent attention.');
              _loadData();
            },
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Satisfied')) return Colors.teal;
    switch (status) {
      case 'Resolved': return Colors.green;
      case 'In Progress': return Colors.blue;
      case 'Closed': return Colors.grey;
      case 'Reopened': return Colors.red;
      default: return Colors.orange;
    }
  }

  Widget _infoRow(String label, String value, {bool canCorrect = false, String? contextStr}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.ink3))),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        if (canCorrect)
          IconButton(
            icon: const Icon(Icons.edit_note, size: 18, color: AppTheme.blueLight),
            onPressed: () => _openCorrectionForm(contextStr != null ? '$contextStr -> $label' : label, value),
            visualDensity: VisualDensity.compact,
          )
      ]),
    );
  }

  void _openCorrectionForm(String field, String current) {
    if (_myFamily == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CorrectionFormScreen(
          surveyId: _myFamily!.id!,
          fieldName: field,
          currentVal: current,
        ),
      ),
    );
  }

  void _openComplaintForm() async {
    if (_myFamily == null) return;
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintFormScreen(
          surveyId: _myFamily!.id!, 
          street: _myFamily!.street,
        ),
      ),
    );
    if (res == true) _loadData();
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose),
              child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}
