import 'package:flutter/material.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/services/repository.dart';

class AdministrationSupplyProvider extends ChangeNotifier {
  List<AdministrationSupply> _items = [];
  bool _isLoading = true;
  final Repository<AdministrationSupply> repository;

  static final defaultRepository = Repository<AdministrationSupply>(
    tableName: 'administration_supplies',
    toMap: (item) => item.toMap(),
    fromMap: (map) => AdministrationSupply.fromMap(map),
  );

  AdministrationSupplyProvider({Repository<AdministrationSupply>? repository})
      : repository = repository ?? defaultRepository {
    _init();
  }

  List<AdministrationSupply> get items => _items;

  bool get isLoading => _isLoading;

  List<AdministrationSupply> get orderedByName => [..._items]..sort(
      (a, b) => a.name.compareTo(b.name),
    );

  Future<void> _init() async {
    _items = await repository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _items = await repository.getAll();
    notifyListeners();
  }

  Future<void> deleteFromId(int id) async {
    await repository.delete(id);
    await fetchAll();
  }

  Future<void> delete(AdministrationSupply item) async {
    await repository.delete(item.id);
    await fetchAll();
  }

  Future<void> add(AdministrationSupply item) async {
    await repository.insert(item);
    await fetchAll();
  }

  Future<void> update(AdministrationSupply item) async {
    await repository.update(item, item.id);
    await fetchAll();
  }
}
