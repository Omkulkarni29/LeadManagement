import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../providers/leads_provider.dart';
import '../widgets/custom_widgets.dart';
import 'add_lead_screen.dart';

class LeadDetailsScreen extends StatefulWidget {
  final Lead lead;

  const LeadDetailsScreen({super.key, required this.lead});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  late LeadStatus _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.lead.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Details'),
        backgroundColor: Colors.blue.shade600,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editLead),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteLead,
          ),
        ],
      ),
      body: Consumer<LeadsNotifier>(
        builder: (context, leadsNotifier, _) {
          final updatedLead = leadsNotifier.getLeadById(widget.lead.id!);
          if (updatedLead == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Lead not found'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            updatedLead.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          StatusBadge(status: updatedLead.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Contact Details Section
                _buildSection(
                  title: 'Contact Information',
                  children: [
                    _buildInfoTile(
                      icon: Icons.phone,
                      label: 'Contact',
                      value: updatedLead.contact,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Notes Section
                if (updatedLead.notes != null && updatedLead.notes!.isNotEmpty)
                  _buildSection(
                    title: 'Notes',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          updatedLead.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Status Update Section
                _buildSection(
                  title: 'Update Status',
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<LeadStatus>(
                        value: _selectedStatus,
                        isExpanded: true,
                        underline: const SizedBox(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                        items:
                            LeadStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _isUpdating ? 'Updating...' : 'Update Status',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Additional Info Section
                _buildSection(
                  title: 'Additional Info',
                  children: [
                    _buildInfoTile(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatDate(updatedLead.createdAt),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoTile(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: _formatDate(updatedLead.updatedAt),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editLead() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddLeadScreen(initialLead: widget.lead),
      ),
    );
  }

  void _deleteLead() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lead?'),
            content: Text(
              'Are you sure you want to delete ${widget.lead.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<LeadsNotifier>().deleteLead(widget.lead.id!);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Lead deleted')));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _updateStatus() async {
    if (_selectedStatus == widget.lead.status) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes made')));
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final updatedLead = widget.lead.copyWith(status: _selectedStatus);
      await context.read<LeadsNotifier>().updateLead(updatedLead);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Status updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}
