class Batch {
  final int id;
  final String date; // ISO format date string
  final int qty;
  final int duration; // Duration in months

  Batch({
    required this.id,
    required this.date,
    required this.qty,
    this.duration = 12,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      date: json['date'] as String,
      qty: json['qty'] as int,
      duration: json['duration'] as int? ?? 12,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'qty': qty,
      'duration': duration,
    };
  }

  Batch copyWith({
    int? id,
    String? date,
    int? qty,
    int? duration,
  }) {
    return Batch(
      id: id ?? this.id,
      date: date ?? this.date,
      qty: qty ?? this.qty,
      duration: duration ?? this.duration,
    );
  }
}
