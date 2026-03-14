class InventoryItem {
  final int? id;
  final int inventoryId;
  final String productCode;
  final String designation;
  final String barcode;
  final double quantity;
  final DateTime date;

  InventoryItem({
    this.id,
    required this.inventoryId,
    required this.productCode,
    required this.designation,
    required this.barcode,
    required this.quantity,
    required this.date,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      inventoryId: map['inventory_id'] as int,
      productCode: map['product_code'] as String,
      designation: map['designation'] as String,
      barcode: map['barcode'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'inventory_id': inventoryId,
      'product_code': productCode,
      'designation': designation,
      'barcode': barcode,
      'quantity': quantity,
      'date': date.toIso8601String(),
    };
  }
}
