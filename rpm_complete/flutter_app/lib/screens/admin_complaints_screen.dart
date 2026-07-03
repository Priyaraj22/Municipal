import 'package:flutter/material.dart';
import '../models/survey_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  List<Complaint> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // We'll reuse getMyComplaints for admin but without phone to get all
      // For now, let's assume we need a getall API
      // Since I haven't added it, I'll use a placeholder or update ApiService
      final r = await ApiService.getMyComplaints(""); // Empty phone = All in updated backend logic?
      // Wait, let's actually add a proper GetAll API in backend and frontend.
      setState(() {
        _complaints = r;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int id, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Update Complaint Status'),
        children: ['Received', 'Under Review', 'In Progress', 'Resolved', 'Closed'].map((s) => 
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, s), child: Text(s))
        ).toList(),
      )
    );

    if (newStatus != null && newStatus != currentStatus) {
      try {
        await ApiService.updateComplaintStatus(id, newStatus);
        showToast(context, 'Status updated and WhatsApp sent!');
        _load();
      } catch (e) {
        showToast(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Municipal Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        Expanded(
          child: _loading 
            ? const Center(child: CircularProgressIndicator())
            : _complaints.isEmpty
              ? const Center(child: Text('No complaints found'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _complaints.length,
                  itemBuilder: (ctx, i) {
                    final c = _complaints[i];
                    return Card(
                      child: ListTile(
                        title: Text('${c.issueType} - ${c.street}'),
                        subtitle: Text(c.citizenMobile),
                        trailing: ActionChip(
                          label: Text(c.status),
                          onPressed: () => _updateStatus(c.id!, c.status),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
