enum LeadStatus {
  newLead,
  contacted,
  converted,
  lost;

  String get displayName {
    switch (this) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.converted:
        return 'Converted';
      case LeadStatus.lost:
        return 'Lost';
    }
  }

  static LeadStatus fromString(String status) {
    return LeadStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => LeadStatus.newLead,
    );
  }
}

class Lead {
  final int? id;
  final String name;
  final String contact;
  final String? notes;
  final LeadStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead({
    this.id,
    required this.name,
    required this.contact,
    this.notes,
    this.status = LeadStatus.newLead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Lead copyWith({
    int? id,
    String? name,
    String? contact,
    String? notes,
    LeadStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'] as int?,
      name: map['name'] as String,
      contact: map['contact'] as String,
      notes: map['notes'] as String?,
      status: LeadStatus.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() =>
      'Lead(id: $id, name: $name, contact: $contact, status: ${status.displayName})';
}
