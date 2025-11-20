import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/lead.dart';
import '../services/database_service.dart';

class LeadsNotifier extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Lead> _leads = [];
  LeadStatus? _filterStatus;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _isDarkMode = false;

  LeadsNotifier() {
    loadLeads();
  }

  // Getters
  List<Lead> get leads {
    var filtered =
        _filterStatus == null
            ? _leads
            : _leads.where((lead) => lead.status == _filterStatus).toList();

    if (_searchQuery.isEmpty) {
      return filtered;
    }

    return filtered
        .where(
          (lead) =>
              lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              lead.contact.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  LeadStatus? get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;
  int get leadCount => _leads.length;

  // Load all leads
  Future<void> loadLeads() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leads = await _databaseService.getAllLeads();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leads: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new lead
  Future<void> addLead(Lead lead) async {
    try {
      final newLead = await _databaseService.insertLead(lead);
      _leads.add(newLead);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add lead: $e';
      notifyListeners();
    }
  }

  // Update lead
  Future<void> updateLead(Lead lead) async {
    try {
      await _databaseService.updateLead(lead);
      final index = _leads.indexWhere((l) => l.id == lead.id);
      if (index != -1) {
        _leads[index] = lead;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update lead: $e';
      notifyListeners();
    }
  }

  // Delete lead
  Future<void> deleteLead(int id) async {
    try {
      await _databaseService.deleteLead(id);
      _leads.removeWhere((lead) => lead.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete lead: $e';
      notifyListeners();
    }
  }

  // Set filter
  void setFilter(LeadStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Get lead by ID
  Lead? getLeadById(int id) {
    try {
      return _leads.firstWhere((lead) => lead.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search leads
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Export leads to JSON
  String exportLeadsAsJson() {
    final List<Map<String, dynamic>> leadsJson =
        _leads
            .map(
              (lead) => {
                'id': lead.id,
                'name': lead.name,
                'contact': lead.contact,
                'notes': lead.notes,
                'status': lead.status.displayName,
                'createdAt': lead.createdAt.toIso8601String(),
                'updatedAt': lead.updatedAt.toIso8601String(),
              },
            )
            .toList();

    return jsonEncode({
      'leads': leadsJson,
      'totalLeads': leadsJson.length,
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }
}
