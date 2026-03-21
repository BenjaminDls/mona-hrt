import 'package:flutter/cupertino.dart';
import 'package:mona/data/model/administration_supply.dart';
import 'package:mona/data/providers/administration_supply_provider.dart';
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

  void _refresh() {
    setState(() {});
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
    return ModelForm(
      title: widget.item != null ? 'Edit item' : 'New item',
      submitButtonLabel: widget.item != null ? 'Update' : 'Add',
      isFormValid: _isFormValid,
      saveChanges: _addItem,
      fields: [
        FormTextField(
          controller: _nameController,
          label: 'Name',
          onChanged: _refresh,
          inputType: TextInputType.text,
        ),
        FormTextField(
          controller: _amountController,
          label: 'Amount',
          onChanged: _refresh,
          inputType: TextInputType.numberWithOptions(decimal: true),
          regexFormatter: r'[0-9]',
        ),
      ],
    );
  }
}