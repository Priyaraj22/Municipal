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
  List<Complaint> _filtered = [];
  bool _loading = true;
  String _statusFilter = 'All';

  final List<String> _statusOptions = [
    'All',
    'Received',
    'Under Review',
    'In Progress',
    'Resolved',
    'Reopened',
    'Closed - Satisfied'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await ApiService.getMyComplaints(""); 
      setState(() {
        _complaints = r.where((c) => c.status != 'Archived').toList();
        _applyFilter();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_statusFilter == 'All') {
        _filtered = _complaints;
      } else {
        _filtered = _complaints.where((c) => c.status == _statusFilter).toList();
      }
    });
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text('Complaints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.blue)),
              const Spacer(),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: AppTheme.blue)),
            ],
          ),
        ),
        
        // Status Filter Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isExpanded: true,
                icon: const Icon(Icons.filter_list_rounded, color: AppTheme.blue),
                items: _statusOptions.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('Filter Status: $s', style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _statusFilter = v);
                    _applyFilter();
                  }
                },
              ),
            ),
          ),
        ),

        Expanded(
          child: _loading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.blue))
            : _filtered.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppTheme.blue.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    Text('No $_statusFilter complaints', style: const TextStyle(color: AppTheme.ink3)),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final c = _filtered[i];
                    return Card(
                      child: ExpansionTile(
                        title: Text('${c.issueType} - ${c.street}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('ID: ${c.id} · ${c.citizenMobile}', style: const TextStyle(fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(c.status, style: const TextStyle(color: AppTheme.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (c.description.isNotEmpty) ...[
                                  const Text('Citizen Description:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.ink3)),
                                  Text(c.description, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 12),
                                ],
                                if (c.feedback != null && c.feedback!.isNotEmpty) ...[
                                  const Text('Citizen Feedback:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.teal.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.withOpacity(0.2))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (c.rating != null)
                                          Row(children: List.generate(5, (index) => Icon(index < c.rating! ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                                        const SizedBox(height: 4),
                                        Text(c.feedback!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (c.status == 'Closed - Satisfied')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await ApiService.updateComplaintStatus(c.id!, 'Archived');
                                        showToast(context, 'Complaint removed from active list');
                                        _load();
                                      },
                                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                                      label: const Text('Remove from List'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.rose,
                                        minimumSize: const Size.fromHeight(40)
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () => _updateStatus(c.id!, c.status),
                                    icon: const Icon(Icons.edit_notifications_outlined, size: 16),
                                    label: const Text('Change Status'),
                                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
