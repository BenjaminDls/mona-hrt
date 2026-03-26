
import 'package:mona/util/validators.dart';

class AdministrationSupply {
  final int id;
  final String name;
  final int remainingQuantity;

  AdministrationSupply({
    int? id,
    required this.name,
    required this.remainingQuantity
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch;

  factory AdministrationSupply.fromMap(Map<String, Object?> map) {
    return AdministrationSupply(
      id: map['id'] as int?,
      name: map['name'] as String,
      remainingQuantity: map['remainingQuantity'] as int
    );
  }

  bool get isInStock => remainingQuantity > 0;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'remainingQuantity': remainingQuantity,
    };
  }

  AdministrationSupply copyWith({
    int? id,
    String? name,
    int? remainingQuantity
  }) {
    return AdministrationSupply(
      id: id ?? this.id,
      name: name ?? this.name,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity
    );
  }

  static String? validateTotalAmount(String? value) => requiredPositiveInt(value);

  static String? validateName(String? value) => requiredString(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AdministrationSupply && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "$name $remainingQuantity";
  }
}