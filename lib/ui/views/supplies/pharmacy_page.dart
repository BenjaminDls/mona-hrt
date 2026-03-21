import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/data/model/supply_item.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';
import 'package:mona/data/providers/supply_item_provider.dart';
import 'package:mona/ui/constants/dimensions.dart';
import 'package:mona/ui/views/supplies/administration_supply_card.dart';
import 'package:mona/ui/views/supplies/supply_item_card.dart';
import 'package:mona/ui/widgets/main_page_wrapper.dart';
import 'package:provider/provider.dart';

class PharmacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SupplyItemProvider, AdministrationSupplyProvider>(
      builder: (context, supplyItemProvider, administrationSupplyProvider, child) {
        List<Widget> children = [];
        children.addAll(supplyItemProvider.items.map((item)=>SupplyItemCard(item: item)).toList());
        children.addAll(administrationSupplyProvider.items.map((item)=>AdministrationSupplyCard(item: item)).toList());
        return MainPageWrapper(
          isLoading: supplyItemProvider.isLoading || administrationSupplyProvider.isLoading,
          isEmpty: supplyItemProvider.items.isEmpty && administrationSupplyProvider.items.isEmpty,
          emptyChildWidget: Text('No supplies. Add an item to get started!'),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Visibility(
                  visible: supplyItemProvider.items.isNotEmpty,
                    child: Text("Medication supplies"),
                  )
              ),

              SliverMasonryGrid.count(
                crossAxisCount: 2,
                itemBuilder: (context, index) {
                  final item = supplyItemProvider.items[index];
                  return SupplyItemCard(item: item);
                },
                childCount: supplyItemProvider.items.length,
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
