final String tableProducts = 'Products';


class ProductFields {

  static final List<String> values = [
    // Add all fields
    id, code, productName, productPrice, note, createdTime
  ];
  static final String id = '_id';
  static final String code = '_code';
  static final String productName = '_productName';
  static final String productPrice = '_productPrice';
  static final String note = '_note';
  static final String createdTime = '_createdTime';
}

class Product {
  final int? id;
  final String code;
  final String productName;
  final int productPrice;
  final String? note;
  final DateTime createdTime;

  const Product({
    this.id,
    required this.code,
    required this.productName,
    required this.productPrice,
    this.note,
    required this.createdTime,
  });

  Product copy({
    int? id,
    String? code,
    String? productName,
    int? productPrice,
    String? note,
    DateTime? createdTime,
  }) =>
      Product(
          id: id ?? this.id,
          code: code ?? this.code,
          productName: productName ?? this.productName,
          productPrice: productPrice ?? this.productPrice,
          note: note ?? this.note,
          createdTime: createdTime ?? this.createdTime
      );

  Map<String, Object?> toJson() =>
      {
        ProductFields.id: id,
        ProductFields.code: code,
        ProductFields.productName: productName,
        ProductFields.productPrice: productPrice,
        ProductFields.note: note,
        ProductFields.createdTime: createdTime.toIso8601String(),
      };

  static Product fromJson(Map<String, Object?> json) => Product(
    id: json[ProductFields.id] as int?,
    code: json[ProductFields.code] as String,
    productName: json[ProductFields.productName] as String,
    productPrice: json[ProductFields.productPrice] as int,
    note: json[ProductFields.note] as String,
    createdTime: DateTime.parse(json[ProductFields.createdTime] as String),
  );
}