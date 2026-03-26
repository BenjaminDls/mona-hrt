import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mona/ui/views/supplies/administration_supply_form_page.dart';
import 'package:mona/ui/views/supplies/medication_supply_form_page.dart';

class PharmacyFormPage extends StatefulWidget {
  @override
  State createState() {
    return _PharmacyFormPageState();
  }
}

class _PharmacyFormPageState extends State<PharmacyFormPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _tabController.index==1 ? Text('Add medication supplies') : Text('Add miscellaneous supplies'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
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
        ),
        body: TabBarView(
          children: [
            MedicationSupplyFormPage(null),
            AdministrationSupplyFormPage(null)
          ]
        ),
      ),
    );
  }
}