import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import 'package:mona/ui/views/supplies/administration_supply_card.dart';
import 'package:mona/ui/views/supplies/medication_supply_card.dart';
import 'package:mona/ui/widgets/main_page_wrapper.dart';
import 'package:provider/provider.dart';

class PharmacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationSupplyProvider, AdministrationSupplyProvider>(
      builder: (context, medicationSupplyProvider, administrationSupplyProvider, child) {
        List<Widget> children = [];
        children.addAll(medicationSupplyProvider.items.map((item)=>MedicationSupplyCard(item: item)).toList());
        children.addAll(administrationSupplyProvider.items.map((item)=>AdministrationSupplyCard(item: item)).toList());
        return MainPageWrapper(
          isLoading: medicationSupplyProvider.isLoading || administrationSupplyProvider.isLoading,
          isEmpty: medicationSupplyProvider.items.isEmpty && administrationSupplyProvider.items.isEmpty,
          emptyChildWidget: Text('No supplies. Add an item to get started!'),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Visibility(
                  visible: medicationSupplyProvider.items.isNotEmpty,
                    child: Text("Medication supplies"),
                  )
              ),

              SliverMasonryGrid.count(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  final item = medicationSupplyProvider.items[index];
                  return MedicationSupplyCard(item: item);
                },
                childCount: medicationSupplyProvider.items.length,
              ),

              SliverToBoxAdapter(
                child: Visibility(
                visible: administrationSupplyProvider.items.isNotEmpty,
                  child: Text("Other supplies"),
                )
              ),

              SliverMasonryGrid.count(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  final item = administrationSupplyProvider.items[index];
                  return AdministrationSupplyCard(item: item);
                },
                childCount: administrationSupplyProvider.items.length,
              ),
            ],
            )
        );
      },
    );
  }
}
