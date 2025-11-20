import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../providers/leads_provider.dart';

class AddLeadScreen extends StatefulWidget {
  final Lead? initialLead;

  const AddLeadScreen({super.key, this.initialLead});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _notesController;
  late LeadStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialLead?.name ?? '',
    );
    _contactController = TextEditingController(
      text: widget.initialLead?.contact ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialLead?.notes ?? '',
    );
    _selectedStatus = widget.initialLead?.status ?? LeadStatus.newLead;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialLead == null ? 'Add New Lead' : 'Edit Lead'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Lead Name',
              hint: 'Enter full name',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _contactController,
              label: 'Contact Details',
              hint: 'Phone or Email',
              icon: Icons.contact_mail,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              hint: 'Add any additional notes',
              icon: Icons.note,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _buildStatusDropdown(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveLead,
        icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
        label: Text(_isLoading ? 'Saving...' : 'Save Lead'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _saveLead() async {
    if (_nameController.text.isEmpty || _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final leadsNotifier = context.read<LeadsNotifier>();

      if (widget.initialLead == null) {
        // Add new lead
        final newLead = Lead(
          name: _nameController.text,
          contact: _contactController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          status: _selectedStatus,
        );
        await leadsNotifier.addLead(newLead);
      } else {
        // Update existing lead
        final updatedLead = widget.initialLead!.copyWith(
          name: _nameController.text,
          contact: _contactController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          status: _selectedStatus,
        );
        await leadsNotifier.updateLead(updatedLead);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialLead == null ? 'Lead added' : 'Lead updated',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
