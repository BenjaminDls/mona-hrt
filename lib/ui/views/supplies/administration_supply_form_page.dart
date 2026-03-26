import 'package:flutter/material.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';
import 'package:mona/ui/constants/dimensions.dart';
import 'package:mona/ui/widgets/forms/dismiss_keyboard_single_child_scroll_view.dart';
import 'package:mona/ui/widgets/forms/form_text_field.dart';
import 'package:mona/ui/widgets/forms/model_form.dart';
import 'package:provider/provider.dart';

class AdministrationSupplyFormPage extends StatefulWidget {
  // null when creating, non null when editing
  final AdministrationSupply? item;

  AdministrationSupplyFormPage(this.item);

  @override
  State createState() {
    return _AdministrationSupplyFormPageState();
  }
}

class _AdministrationSupplyFormPageState extends State<AdministrationSupplyFormPage> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;

  String? get _nameError => AdministrationSupply.validateName(_nameController.text);
  String? get _amountError => AdministrationSupply.validateTotalAmount(_amountController.text);

  bool get _isFormValid => _nameError == null && _amountError == null;

  List<Widget> get _fields => [
    FormTextField(
      controller: _nameController,
      label: 'Name',
      onChanged: () => setState(() {}),
      inputType: TextInputType.text,
    ),
    FormTextField(
      controller: _amountController,
      label: 'Amount',
      onChanged: () => setState(() {}),
      inputType: TextInputType.numberWithOptions(decimal: true),
      regexFormatter: r'[0-9]',
    ),
  ];

  void _addItem() {
    final name = _nameController.text;
    final amount = int.parse(_amountController.text);
    final administrationSupplyProvider = Provider.of<AdministrationSupplyProvider>(context, listen: false);

    final item = AdministrationSupply(
        name: name,
        remainingQuantity: amount
    );

    administrationSupplyProvider.add(item);

    Navigator.pop(context);
  }

  void _deleteItem() {
    final administrationSupplyProvider = Provider.of<AdministrationSupplyProvider>(context, listen: false);
    if (widget.item != null) {
      administrationSupplyProvider.delete(widget.item!);
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _amountController = TextEditingController(text: widget.item?.remainingQuantity.toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item != null) {
      return ModelForm(
        title: 'Edit item',
        avatar: Icons.miscellaneous_services,
        submitButtonLabel: 'Save',
        isFormValid: _isFormValid,
        saveChanges: _addItem,
        onDelete: _deleteItem,
        fields: _fields
      );
    }
    else {
      return DismissKeyboardSingleChildScrollView(
        padding: pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form
            Column(
              children: _fields,
            ),
            // Bottom button
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: borderPadding,
                    left: borderPadding,
                    right: borderPadding,
                    bottom: borderPadding + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Row(
                    children: [
                      Visibility(
                        visible: widget.item!=null,
                        child: Expanded(
                          child: FilledButton.icon(
                            icon: Icon(Icons.delete),
                            onPressed: _deleteItem,
                            label: Text('Delete'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FilledButton.icon(
                          icon: Icon(Icons.add),
                          onPressed: _isFormValid ? _addItem : null,
                          label: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }
}