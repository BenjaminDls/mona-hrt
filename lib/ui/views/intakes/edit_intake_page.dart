import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:mona/controllers/medication_supply_manager.dart';
import 'package:mona/data/model/administration_route.dart';
import 'package:mona/data/model/medication_intake.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/data/providers/medication_intake_provider.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import 'package:mona/ui/views/intakes/intakes_page.dart';
import 'package:mona/ui/widgets/forms/form_date_field.dart';
import 'package:mona/ui/widgets/forms/form_dropdown_field.dart';
import 'package:mona/ui/widgets/forms/form_spacer.dart';
import 'package:mona/ui/widgets/forms/form_text_field.dart';
import 'package:mona/ui/widgets/forms/model_form.dart';
import 'package:provider/provider.dart';

class EditIntakePage extends StatefulWidget {
  final MedicationIntake intake;

  EditIntakePage(this.intake);

  @override
  State<EditIntakePage> createState() => _EditIntakePageState();
}

class _EditIntakePageState extends State<EditIntakePage> {
  late DateTime _takenDate;
  late TextEditingController _takenDoseController;
  late Decimal _takenDose;
  InjectionSide? _selectedSide;
  bool _hasInitializedSide = false;
  MedicationSupply? _selectedMedicationSupply;
  bool _hasInitializedMedicationSupply = false;

  String? get _takenDoseError =>
      MedicationIntake.validateDose(_takenDoseController.text);

  bool get _isFormValid => _takenDoseError == null;

  bool get _isInjection =>
      widget.intake.administrationRoute == AdministrationRoute.injection;

  void _editIntake(
      MedicationIntakeProvider medicationIntakeProvider,
      MedicationSupplyProvider medicationSupplyProvider,
      MedicationIntake intake,
      MedicationSupply? medicationSupply) async {
    if (!_isFormValid) return;
    if (!mounted) return;

    // TODO create method in manager for this
    if (medicationSupply != null) {
      Decimal doseDifference = intake.dose - _takenDose;
      MedicationSupplyManager(medicationSupplyProvider)
          .useDose(medicationSupply, -doseDifference);
    }

    MedicationIntake updatedIntake = intake.copyWith(
        takenDateTime: _takenDate, dose: _takenDose, side: _selectedSide);

    medicationIntakeProvider.updateIntake(updatedIntake);
    Navigator.of(context).pop();
  }

  void _deleteIntake(
    MedicationIntakeProvider medicationIntakeProvider,
    MedicationSupplyProvider medicationSupplyProvider,
    MedicationIntake intake,
    MedicationSupply? medicationSupply,
  ) async {
    if (!mounted) return;

    // TODO create method in manager for this
    if (medicationSupply != null) {
      MedicationSupplyManager(medicationSupplyProvider).useDose(medicationSupply, -intake.dose);
    }

    medicationIntakeProvider.deleteIntake(intake);
    Navigator.of(context).pop();
  }

  void _onInjectionSideChanged(InjectionSide? side) {
    if (side != null) {
      setState(() {
        _selectedSide = side;
      });
    }
  }

  void _onTakenDateChanged(DateTime date) {
    setState(() {
      _takenDate = date;
    });
  }

  void _onTakenDoseChanged() {
    final dose = Decimal.tryParse(
      _takenDoseController.text.replaceAll(',', '.'),
    );
    if (dose != null) {
      setState(() {
        _takenDose = dose;
      });
    }
  }

  void _onMedicationSupplyChanged(MedicationSupply? item) {
    setState(() {
      _selectedMedicationSupply = item;
    });
  }

  @override
  void initState() {
    super.initState();
    _takenDate = widget.intake.takenDateTime ?? DateTime.now();
    _takenDose = widget.intake.dose;
    _takenDoseController =
        TextEditingController(text: widget.intake.dose.toString());
  }

  @override
  void dispose() {
    _takenDoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationIntakeProvider, MedicationSupplyProvider>(
      builder: (context, medicationIntakeProvider, medicationSupplyProvider, child) {
        final bool isLoading =
            medicationIntakeProvider.isLoading || medicationSupplyProvider.isLoading;

        if (!isLoading && !_hasInitializedSide && _isInjection) {
          _selectedSide = widget.intake.side;
          _hasInitializedSide = true;
        }

        if (!isLoading && !_hasInitializedMedicationSupply) {
          _selectedMedicationSupply = medicationSupplyProvider.getMostUsedItemForMedication(
            widget.intake.molecule,
            widget.intake.administrationRoute,
            widget.intake.ester,
          );
          _hasInitializedMedicationSupply = true;
        }

        final medicationSupplyOptions = medicationSupplyProvider.getItemsForMedication(
          widget.intake.molecule,
          widget.intake.administrationRoute,
          widget.intake.ester,
        );

        final medicationSupplyDropdownItems = [
          const DropdownMenuItem<MedicationSupply?>(
            value: null,
            child: Text('None'),
          ),
          ...medicationSupplyOptions.map(
            (item) => DropdownMenuItem<MedicationSupply?>(
              value: item,
              child: Text(item.name),
            ),
          ),
        ];

        return ModelForm(
          title: 'Edit intake',
          avatar: widget.intake.administrationRoute.icon,
          submitButtonLabel: 'Save',
          isFormValid: _isFormValid,
          saveChanges: (!isLoading && _isFormValid)
              ? () => _editIntake(medicationIntakeProvider, medicationSupplyProvider,
                  widget.intake, _selectedMedicationSupply)
              : () {},
          onDelete: () async {
            final confirmed = await IntakesPage.confirmDeleteIntake(context);
            if (confirmed == false) return;
            _deleteIntake(medicationIntakeProvider, medicationSupplyProvider,
                widget.intake, _selectedMedicationSupply);
          },
          fields: [
            FormDateField(
              label: 'Date',
              date: _takenDate,
              onChanged: _onTakenDateChanged,
            ),
            FormSpacer(),
            FormTextField(
              controller: _takenDoseController,
              label: 'Amount',
              onChanged: _onTakenDoseChanged,
              inputType: TextInputType.number,
              suffixText: widget.intake.molecule.unit,
              errorText: _takenDoseError,
              regexFormatter: r'[0-9.,]',
            ),
            if (_selectedMedicationSupply != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const WidgetSpan(
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' $_takenDose ${widget.intake.molecule.unit} = ${_selectedMedicationSupply!.getAmount(_takenDose)} ${_selectedMedicationSupply!.administrationRoute.unit}',
                      ),
                    ],
                  ),
                ),
              ),
            FormDropdownField<MedicationSupply?>(
              value: _selectedMedicationSupply,
              items: medicationSupplyDropdownItems,
              onChanged: _onMedicationSupplyChanged,
              label: 'Supply item',
            ),
            if (_isInjection)
              FormDropdownField<InjectionSide>(
                value: _selectedSide,
                items: InjectionSideDropdown.menuItems,
                onChanged: _onInjectionSideChanged,
                label: 'Injection side',
              ),
          ],
        );
      },
    );
  }
}
