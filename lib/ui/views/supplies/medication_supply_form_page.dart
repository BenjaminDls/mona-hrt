
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mona/data/model/administration_route.dart';
import 'package:mona/data/model/ester.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/data/model/molecule.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import 'package:mona/services/preferences_service.dart';
import 'package:mona/ui/constants/dimensions.dart';
import 'package:mona/ui/widgets/dialogs.dart';
import 'package:mona/ui/widgets/forms/dismiss_keyboard_single_child_scroll_view.dart';
import 'package:mona/ui/widgets/forms/form_dropdown_field.dart';
import 'package:mona/ui/widgets/forms/form_spacer.dart';
import 'package:mona/ui/widgets/forms/form_text_field.dart';
import 'package:mona/ui/widgets/forms/model_form.dart';
import 'package:mona/util/decimal_helpers.dart';
import 'package:provider/provider.dart';

class MedicationSupplyFormPage extends StatefulWidget {
  // null when creating, non null when editing
  final MedicationSupply? item;

  MedicationSupplyFormPage(this.item);

  @override
  State createState() {
    return _MedicationSupplyFormPageState();
  }
}

class _MedicationSupplyFormPageState extends State<MedicationSupplyFormPage> {

  late TextEditingController _totalAmountController;
  late TextEditingController _usedAmountController;
  late TextEditingController _concentrationController;
  late TextEditingController _nameController;
  Molecule? _molecule;
  AdministrationRoute? _administrationRoute;
  Ester? _ester;
  late PreferencesService _preferencesService;
  late MedicationSupplyProvider _medicationSupplyProvider;

  String? get _nameError => MedicationSupply.validateName(_nameController.text);

  String? get _totalAmountError =>
      MedicationSupply.validateTotalAmount(_totalAmountController.text);

  String? get _usedAmountError {
    final validator =
    MedicationSupply.usedAmountValidator(_totalAmountController.text);
    return validator(_usedAmountController.text);
  }

  String? get _concentrationError =>
      MedicationSupply.validateConcentration(_concentrationController.text);

  String? get _moleculeError => MedicationSupply.validateMolecule(_molecule);
  String? get _administrationRouteError =>
      MedicationSupply.validateAdministrationRoute(_administrationRoute);
  String? get _esterError {
    final validator =
    MedicationSupply.esterValidator(_molecule, _administrationRoute);
    return validator(_ester);
  }

  bool get _isFormValid =>
      _nameError == null &&
          _totalAmountError == null &&
          (widget.item==null || _usedAmountError == null) &&
          _concentrationError == null &&
          _moleculeError == null &&
          _administrationRouteError == null &&
          _esterError == null;

  bool get _useEsterField =>
      _molecule == KnownMolecules.estradiol &&
          _administrationRoute == AdministrationRoute.injection;


  List<Widget> get _fields => [
    FormTextField(
      controller: _nameController,
      label: 'Name',
      onChanged: _refresh,
      inputType: TextInputType.text,
      errorText: _nameError,
    ),
    FormSpacer(),
    FormDropdownField<Molecule>(
      value: _molecule,
      items: _preferencesService.moleculeDropdownItems,
      onChanged: _onMoleculeChanged,
      label: 'Molecule',
    ),
    FormDropdownField<AdministrationRoute>(
      value: _administrationRoute,
      items: AdministrationRoute.menuItems,
      onChanged: _onAdministrationRouteChanged,
      label: 'Administration route',
    ),
    Visibility(
      visible: _useEsterField,
      child: FormDropdownField<Ester>(
        value: _ester,
        items: Ester.menuItems,
        onChanged: _onEsterChanged,
        label: 'Ester',
      )
    ),
    FormSpacer(),
    FormTextField(
      controller: _totalAmountController,
      label: 'Total amount',
      onChanged: _refresh,
      inputType: TextInputType.numberWithOptions(decimal: true),
      suffixText: _administrationRoute?.unit,
      errorText: _totalAmountError,
      regexFormatter: r'[0-9.,]',
    ),
    Visibility(
      visible: widget.item != null,
      child: FormTextField(
        controller: _usedAmountController,
        label: 'Used amount',
        onChanged: _refresh,
        inputType: TextInputType.numberWithOptions(decimal: true),
        suffixText: _administrationRoute?.unit,
        errorText: _usedAmountError,
        regexFormatter: r'[0-9.,]',
      )
    ),
    FormTextField(
      controller: _concentrationController,
      label: 'Concentration',
      onChanged: _refresh,
      inputType: TextInputType.numberWithOptions(decimal: true),
      suffixText: _suffixText(),
      errorText: _concentrationError,
      regexFormatter: r'[0-9.,]',
    )
  ];

  String _suffixText() {
    var moleculeUnit = _molecule?.unit;
    var administrationUnit = _administrationRoute?.unit;
    if (moleculeUnit != null && administrationUnit != null) {
      return '$moleculeUnit/$administrationUnit';
    }
    else {
      return '';
    }
  }

  void _onMoleculeChanged(Molecule? molecule) {
    if (molecule != null) {
      setState(() {
        _molecule = molecule;

        if (!_useEsterField) {
          _ester = null;
        }
      });
    }
  }

  void _onAdministrationRouteChanged(AdministrationRoute? administrationRoute) {
    if (administrationRoute != null) {
      setState(() {
        _administrationRoute = administrationRoute;

        if (!_useEsterField) {
          _ester = null;
        }
      });
    }
  }

  void _onEsterChanged(Ester? ester) {
    if (ester != null) {
      setState(() {
        _ester = ester;
      });
    }
  }

  void _refresh() => setState(() {});

  Future<void> _confirmDelete() async {
    if (widget.item == null) {
      return;
    }

    final confirmed = await Dialogs.confirmDialog(
        context: context, title: "Delete this item?");

    if (confirmed == true) {
      if (!mounted) return;
      _medicationSupplyProvider.deleteItem(widget.item!);
      Navigator.of(context).pop();
    }
  }

  void _save() {
    if (widget.item != null) {
      _editItem();
    }
    else{
      _addItem();
    }
  }

  void _addItem() async {
    if (!_isFormValid) return;
    if (!mounted) return;

    final totalAmount = parseDecimal(_totalAmountController.text);
    final concentration = parseDecimal(_concentrationController.text);
    final totalDose = concentration * totalAmount;
    final name = _nameController.text;
    final medicationSupplyProvider =
    Provider.of<MedicationSupplyProvider>(context, listen: false);

    final item = MedicationSupply(
      name: name,
      totalDose: totalDose,
      concentration: concentration,
      molecule: _molecule!,
      administrationRoute: _administrationRoute!,
      ester: _ester,
    );
    medicationSupplyProvider.add(item);

    Navigator.pop(context);
  }

  void _editItem() {
    var item = widget.item;
    if (!_isFormValid || !mounted || item == null) {
      return;
    }

    final concentration = parseDecimal(_concentrationController.text);
    final totalDose = concentration * parseDecimal(_totalAmountController.text);
    final usedDose = concentration * parseDecimal(_usedAmountController.text);

    final updatedItem = item.copyWith(
      name: _nameController.text,
      totalDose: totalDose,
      concentration: concentration,
      usedDose: usedDose,
      molecule: _molecule,
      administrationRoute: _administrationRoute,
      ester: _ester,
      clearEster: !_useEsterField,
    );
    _medicationSupplyProvider.updateItem(updatedItem);

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    _medicationSupplyProvider =
        Provider.of<MedicationSupplyProvider>(context, listen: false);
    _preferencesService =
        Provider.of<PreferencesService>(context, listen: false);


    var item = widget.item;
    if (item != null) {
      final totalAmountText =
      item.getAmount(item.totalDose).toString();
      _totalAmountController = TextEditingController(text: totalAmountText);
      final usedAmountText =
      item.getAmount(item.usedDose).toString();
      _usedAmountController = TextEditingController(text: usedAmountText);
      var concentrationText = item.concentration.toString();
      _concentrationController =
          TextEditingController(text: concentrationText);
      _nameController = TextEditingController(text: item.name);
      _molecule = item.molecule;
      _administrationRoute = item.administrationRoute;
      _ester = item.ester;
    }
    else {
      _usedAmountController = TextEditingController();
      _concentrationController = TextEditingController();
      _nameController = TextEditingController();
      _totalAmountController = TextEditingController();
      _molecule = null;
      _administrationRoute = null;
      _ester = null;
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    _usedAmountController.dispose();
    _concentrationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item != null) {
      return ModelForm(
          title: 'Edit item',
          avatar: widget.item?.administrationRoute.icon,
          submitButtonLabel: 'Save',
          isFormValid: _isFormValid,
          saveChanges: _save,
          onDelete: _confirmDelete,
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
                        visible: widget.item != null,
                        child: Expanded(
                          child: FilledButton.icon(
                            icon: Icon(Icons.delete),
                            onPressed: _confirmDelete,
                            label: Text('Delete'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FilledButton.icon(
                          icon: Icon(Icons.add),
                          onPressed: _addItem,
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