import 'package:decimal/decimal.dart';
import '../data/model/medication_supply.dart';
import '../data/providers/medication_supply_provider.dart';

class MedicationSupplyManager {
  final MedicationSupplyProvider _medicationSupplyProvider;

  MedicationSupplyManager(this._medicationSupplyProvider);

  /// Uses a portion of the amount of the [MedicationSupply] and updates the database.
  Future<void> useDose(MedicationSupply item, Decimal doseToUse) async {
    if (doseToUse == Decimal.zero) {
      return;
    }

    if (item.usedDose + doseToUse > item.totalDose) {
      doseToUse = item.totalDose - item.usedDose;
    }

    if(item.usedDose + doseToUse < Decimal.fromInt(0)) {
      doseToUse = -item.usedDose;
    }

    await _medicationSupplyProvider.updateItem(item.copyWith(
      usedDose: item.usedDose + doseToUse,
    ));
  }
}
