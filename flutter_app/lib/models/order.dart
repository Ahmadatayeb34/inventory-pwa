class Order {
  final int id;
  final String number;
  final String company;
  final String type;
  final String date; // ISO format date string
  final String notes;
  String status; // 'pending' or 'completed'

  Order({
    required this.id,
    required this.number,
    required this.company,
    required this.type,
    required this.date,
    this.notes = '',
    this.status = 'pending',
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      number: json['number'] as String,
      company: json['company'] as String,
      type: json['type'] as String,
      date: json['date'] as String,
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'company': company,
      'type': type,
      'date': date,
      'notes': notes,
      'status': status,
    };
  }

  Order copyWith({
    int? id,
    String? number,
    String? company,
    String? type,
    String? date,
    String? notes,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      number: number ?? this.number,
      company: company ?? this.company,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}
