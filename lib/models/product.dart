class Product {
  final String code;
  final String designation;
  final String barcode;

  Product({
    required this.code,
    required this.designation,
    required this.barcode,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      code: map['code'] as String,
      designation: map['designation'] as String,
      barcode: map['barcode'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'designation': designation,
      'barcode': barcode,
    };
  }
}
