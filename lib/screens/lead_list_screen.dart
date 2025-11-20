import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../providers/leads_provider.dart';
import '../widgets/custom_widgets.dart';
import 'add_lead_screen.dart';
import 'lead_details_screen.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadsNotifier>(
      builder: (context, leadsNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lead Management'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  leadsNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => leadsNotifier.toggleTheme(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => leadsNotifier.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search leads by name or contact',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                leadsNotifier.clearSearch();
                              },
                            ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                ),
              ),
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      StatusFilterChip(
                        label: 'All',
                        isSelected: leadsNotifier.filterStatus == null,
                        onTap: () => leadsNotifier.setFilter(null),
                      ),
                      const SizedBox(width: 8),
                      StatusFilterChip(
                        label: 'New',
                        isSelected:
                            leadsNotifier.filterStatus == LeadStatus.newLead,
                        onTap:
                            () => leadsNotifier.setFilter(LeadStatus.newLead),
                      ),
                      const SizedBox(width: 8),
                      StatusFilterChip(
                        label: 'Contacted',
                        isSelected:
                            leadsNotifier.filterStatus == LeadStatus.contacted,
                        onTap:
                            () => leadsNotifier.setFilter(LeadStatus.contacted),
                      ),
                      const SizedBox(width: 8),
                      StatusFilterChip(
                        label: 'Converted',
                        isSelected:
                            leadsNotifier.filterStatus == LeadStatus.converted,
                        onTap:
                            () => leadsNotifier.setFilter(LeadStatus.converted),
                      ),
                      const SizedBox(width: 8),
                      StatusFilterChip(
                        label: 'Lost',
                        isSelected:
                            leadsNotifier.filterStatus == LeadStatus.lost,
                        onTap: () => leadsNotifier.setFilter(LeadStatus.lost),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Lead Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Showing ${leadsNotifier.leads.length} of ${leadsNotifier.leadCount} leads',
                ),
              ),
              const SizedBox(height: 8),
              // Lead List
              Expanded(
                child:
                    leadsNotifier.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : leadsNotifier.error != null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(leadsNotifier.error ?? 'An error occurred'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => leadsNotifier.loadLeads(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                        : leadsNotifier.leads.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                leadsNotifier.searchQuery.isEmpty
                                    ? Icons.inbox_outlined
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                leadsNotifier.searchQuery.isEmpty
                                    ? 'No leads yet'
                                    : 'No leads found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _navigateToAddLead(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Lead'),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: leadsNotifier.leads.length,
                          itemBuilder: (context, index) {
                            final lead = leadsNotifier.leads[index];
                            return AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.5, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: ModalRoute.of(context)!.animation!,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                child: LeadCard(
                                  lead: lead,
                                  onTap:
                                      () => _navigateToDetails(context, lead),
                                  onDelete:
                                      () => _showDeleteDialog(
                                        context,
                                        lead,
                                        leadsNotifier,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToAddLead(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Lead'),
          ),
        );
      },
    );
  }

  void _navigateToAddLead(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddLeadScreen()));
  }

  void _navigateToDetails(BuildContext context, Lead lead) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LeadDetailsScreen(lead: lead)),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Lead lead,
    LeadsNotifier leadsNotifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Lead?'),
            content: Text('Are you sure you want to delete ${lead.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  leadsNotifier.deleteLead(lead.id!);
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
}
