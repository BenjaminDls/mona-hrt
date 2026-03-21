import 'package:decimal/decimal.dart';
import '../data/model/administration_supply.dart';
import '../data/model/supply_item.dart';
import '../data/providers/administration_supply_provider.dart';
import '../data/providers/supply_item_provider.dart';

class AdministrationSupplyManager {
  final AdministrationSupplyProvider _supplyItemProvider;

  AdministrationSupplyManager(this._supplyItemProvider);

  /// Uses a portion of the amount of the [AdministrationSupply] and updates the database.
  Future<void> use(AdministrationSupply item, int amount) async {
    if (amount == 0) {
      return;
    }

    // avoid going into negative values
    if (item.remainingQuantity < amount) {
      amount = item.remainingQuantity;
    }

    await _supplyItemProvider.update(item.copyWith(
      remainingQuantity: amount,
    ));
  }
}
