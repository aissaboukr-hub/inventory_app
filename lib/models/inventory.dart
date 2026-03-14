class Inventory {
  final int? id;
  final String name;
  final DateTime date;

  Inventory({
    this.id,
    required this.name,
    required this.date,
  });

  factory Inventory.fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'] as int?,
      name: map['name'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'date': date.toIso8601String(),
    };
  }
}
