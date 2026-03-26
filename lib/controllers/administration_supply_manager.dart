import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';

class AdministrationSupplyManager {
  final AdministrationSupplyProvider _medicationSupplyProvider;

  AdministrationSupplyManager(this._medicationSupplyProvider);

  /// Uses a portion of the amount of the [AdministrationSupply] and updates the database.
  Future<void> use(AdministrationSupply item, int amount) async {
    if (amount == 0) {
      return;
    }

    // avoid going into negative values
    if (item.remainingQuantity < amount) {
      amount = item.remainingQuantity;
    }

    await _medicationSupplyProvider.update(item.copyWith(
      remainingQuantity: amount,
    ));
  }
}
