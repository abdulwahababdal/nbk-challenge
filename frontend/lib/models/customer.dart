class Customer {
  final int customerNumber;
  final String customerName;
  final DateTime dateOfBirth;
  final String gender;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.customerNumber,
    required this.customerName,
    required this.dateOfBirth,
    required this.gender,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerNumber: json['customerNumber'] as int,
      customerName: json['customerName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerNumber': customerNumber,
      'customerName': customerName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
    };
  }

  Customer copyWith({
    int? customerNumber,
    String? customerName,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return Customer(
      customerNumber: customerNumber ?? this.customerNumber,
      customerName: customerName ?? this.customerName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
