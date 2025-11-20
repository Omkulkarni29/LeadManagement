import 'package:flutter/material.dart';
import '../models/lead.dart';

class StatusBadge extends StatelessWidget {
  final LeadStatus status;

  const StatusBadge({super.key, required this.status});

  Color _getBackgroundColor() {
    switch (status) {
      case LeadStatus.newLead:
        return Colors.blue.shade100;
      case LeadStatus.contacted:
        return Colors.orange.shade100;
      case LeadStatus.converted:
        return Colors.green.shade100;
      case LeadStatus.lost:
        return Colors.red.shade100;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case LeadStatus.newLead:
        return Colors.blue.shade800;
      case LeadStatus.contacted:
        return Colors.orange.shade800;
      case LeadStatus.converted:
        return Colors.green.shade800;
      case LeadStatus.lost:
        return Colors.red.shade800;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case LeadStatus.newLead:
        return Icons.fiber_new;
      case LeadStatus.contacted:
        return Icons.phone_in_talk;
      case LeadStatus.converted:
        return Icons.check_circle;
      case LeadStatus.lost:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 16, color: _getTextColor()),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: TextStyle(
              color: _getTextColor(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          lead.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(lead.contact, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            StatusBadge(status: lead.status),
          ],
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'delete' && onDelete != null) {
              onDelete!();
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
