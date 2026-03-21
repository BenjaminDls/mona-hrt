import 'package:flutter/material.dart';
import 'package:mona/data/model/administration_route.dart';
import 'package:mona/data/model/ester.dart';
import 'package:mona/data/model/molecule.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/services/repository.dart';

class MedicationSupplyProvider extends ChangeNotifier {
  List<MedicationSupply> _items = [];
  bool _isLoading = true;
  final Repository<MedicationSupply> repository;

  static final defaultRepository = Repository<MedicationSupply>(
    tableName: 'medication_supplies',
    toMap: (item) => item.toMap(),
    fromMap: (map) => MedicationSupply.fromMap(map),
  );

  List<MedicationSupply> get items => _items;

  bool get isLoading => _isLoading;

  List<MedicationSupply> get orderedByRemainingDose => [..._items]..sort(
      (a, b) => a.getRatio().compareTo(b.getRatio()),
    );

  MedicationSupplyProvider({Repository<MedicationSupply>? repository})
      : repository = repository ?? defaultRepository {
    _init();
  }

  Future<void> _init() async {
    _items = await repository.getAll();
    _isLoading = false;
    print("count ${_items.length}");
    notifyListeners();
  }

  Future<void> fetchItems() async {
    _items = await repository.getAll();
    notifyListeners();
  }

  MedicationSupply? getMostUsedItemForMedication(Molecule molecule,
      AdministrationRoute administrationRoute, Ester? ester) {
    if (_items.isEmpty) return null;

    final filtered = orderedByRemainingDose.where(
      (item) =>
          item.molecule == molecule &&
          item.administrationRoute == administrationRoute &&
          item.ester == ester,
    );

    return filtered.isEmpty ? null : filtered.first;
  }

  List<MedicationSupply> getItemsForMedication(Molecule molecule,
      AdministrationRoute administrationRoute, Ester? ester) {
    if (_items.isEmpty) return [];

    return orderedByRemainingDose
        .where(
          (item) =>
              item.molecule == molecule &&
              item.administrationRoute == administrationRoute &&
              item.ester == ester,
        )
        .toList();
  }

  Future<void> deleteItemFromId(int id) async {
    await repository.delete(id);
    await fetchItems();
  }

  Future<void> deleteItem(MedicationSupply item) async {
    await repository.delete(item.id);
    await fetchItems();
  }

  Future<void> add(MedicationSupply medicationSupply) async {
    await repository.insert(medicationSupply);
    await fetchItems();
  }

  Future<void> updateItem(MedicationSupply item) async {
    await repository.update(item, item.id);
    await fetchItems();
  }
}
