import 'package:flutter/material.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/ui/views/supplies/administration_supply_form_page.dart';

class AdministrationSupplyCard extends StatelessWidget {
  final AdministrationSupply item;

  const AdministrationSupplyCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (context) => AdministrationSupplyFormPage(item),
          ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary,
                  child: Center(
                    child: Icon(
                      Icons.healing_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${item.remainingQuantity} remaining',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
