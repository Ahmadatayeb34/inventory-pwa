import 'batch.dart';

class InventoryItem {
  final String code;
  final String name;
  int sysQty; // System quantity
  int actualQty; // Actual quantity
  List<Batch> batches;
  String roastery;
  String notes;

  InventoryItem({
    required this.code,
    required this.name,
    this.sysQty = 0,
    this.actualQty = 0,
    List<Batch>? batches,
    this.roastery = '',
    this.notes = '',
  }) : batches = batches ?? [];

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      code: json['code'] as String,
      name: json['name'] as String,
      sysQty: json['sysQty'] as int? ?? 0,
      actualQty: json['actualQty'] as int? ?? 0,
      batches: (json['batches'] as List<dynamic>?)
              ?.map((b) => Batch.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      roastery: json['roastery'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'sysQty': sysQty,
      'actualQty': actualQty,
      'batches': batches.map((b) => b.toJson()).toList(),
      'roastery': roastery,
      'notes': notes,
    };
  }

  int get difference => actualQty - sysQty;

  InventoryItem copyWith({
    String? code,
    String? name,
    int? sysQty,
    int? actualQty,
    List<Batch>? batches,
    String? roastery,
    String? notes,
  }) {
    return InventoryItem(
      code: code ?? this.code,
      name: name ?? this.name,
      sysQty: sysQty ?? this.sysQty,
      actualQty: actualQty ?? this.actualQty,
      batches: batches ?? this.batches,
      roastery: roastery ?? this.roastery,
      notes: notes ?? this.notes,
    );
  }
}
