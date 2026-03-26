import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import 'package:mona/ui/constants/dimensions.dart';
import 'package:mona/ui/views/supplies/administration_supply_card.dart';
import 'package:mona/ui/views/supplies/medication_supply_card.dart';
import 'package:mona/ui/widgets/main_page_wrapper.dart';
import 'package:provider/provider.dart';

class PharmacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              text: "Medication",
              icon: Icon(Symbols.pill),
            ),
            Tab(
              text: "Miscellaneous",
              icon: Icon(Symbols.healing),
            )
          ],
        ),
        body: TabBarView(
            children: [
              _buildMedicationSuppliesList(),
              _buildMiscellaneousSuppliesList()
            ]
        ),
      ),
    );
  }

  Widget _buildMedicationSuppliesList(){
    return Consumer<MedicationSupplyProvider>(
      builder: (context, supplyItemProvider, child) {
        return MainPageWrapper(
          isLoading: supplyItemProvider.isLoading,
          isEmpty: supplyItemProvider.items.isEmpty,
          emptyChildWidget: Text('No supplies. Add an item to get started!'),
          child: MasonryGridView.builder(
            padding: pagePadding,
            gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300
            ),
            itemCount: supplyItemProvider.items.length,
            itemBuilder: (context, index) {
              MedicationSupply item = supplyItemProvider.items[index];
              return MedicationSupplyCard(item: item);
            },
          ),
        );
      }
    );
  }

  Widget _buildMiscellaneousSuppliesList(){
    return Consumer<AdministrationSupplyProvider>(
        builder: (context, supplyItemProvider, child) {
          return MainPageWrapper(
            isLoading: supplyItemProvider.isLoading,
            isEmpty: supplyItemProvider.items.isEmpty,
            emptyChildWidget: Text('No supplies. Add an item to get started!'),
            child: MasonryGridView.builder(
              padding: pagePadding,
              gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300
              ),
              itemCount: supplyItemProvider.items.length,
              itemBuilder: (context, index) {
                AdministrationSupply item = supplyItemProvider.items[index];
                return AdministrationSupplyCard(item: item);
              },
            ),
          );
        }
    );
  }
}
