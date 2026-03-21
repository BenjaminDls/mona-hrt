import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:mona/controllers/medication_intake_manager.dart';
import 'package:mona/data/model/administration_route.dart';
import 'package:mona/data/model/medication_intake.dart';
import 'package:mona/data/model/medication_schedule.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/data/providers/medication_intake_provider.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import 'package:mona/ui/widgets/forms/form_date_field.dart';
import 'package:mona/ui/widgets/forms/form_dropdown_field.dart';
import 'package:mona/ui/widgets/forms/form_spacer.dart';
import 'package:mona/ui/widgets/forms/form_text_field.dart';
import 'package:mona/ui/widgets/forms/model_form.dart';
import 'package:mona/util/validators.dart';
import 'package:provider/provider.dart';

class TakeMedicationPage extends StatefulWidget {
  final MedicationSchedule schedule;
  final DateTime scheduledDate;

  TakeMedicationPage(this.schedule, this.scheduledDate);

  @override
  State<TakeMedicationPage> createState() => _TakeMedicationPageState();
}

class _TakeMedicationPageState extends State<TakeMedicationPage> {
  late DateTime _takenDate;
  late TextEditingController _takenDoseController;
  late Decimal _takenDose;
  InjectionSide? _selectedSide;
  bool _hasInitializedSide = false;
  MedicationSupply? _selectedMedicationSupply;
  bool _hasInitializedMedicationSupply = false;
  late TextEditingController _deadSpaceController;
  Decimal? _deadSpace;

  String? get _takenDoseError =>
      MedicationIntake.validateDose(_takenDoseController.text);

  String? get _deadSpaceError => positiveDecimal(_takenDoseController.text);

  bool get _isFormValid => _takenDoseError == null && _deadSpaceError == null;

  bool get _isInjection =>
      widget.schedule.administrationRoute == AdministrationRoute.injection;

  void _takeIntake(MedicationIntakeProvider medicationIntakeProvider,
      MedicationSupplyProvider medicationSupplyProvider) {
    if (!_isFormValid) return;
    if (!mounted) return;

    MedicationIntakeManager(medicationIntakeProvider, medicationSupplyProvider)
        .takeMedication(
      dose: _takenDose,
      scheduledDate: widget.scheduledDate,
      takenDate: _takenDate,
      medicationSupply: _selectedMedicationSupply,
      schedule: widget.schedule,
      side: _selectedSide,
      deadSpace: _deadSpace,
    );

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

// TODO implement tryParseDecimal
  void _onDeadSpaceChanged() {
    final deadSpace = Decimal.tryParse(
      _deadSpaceController.text.replaceAll(',', '.'),
    );
    if (deadSpace != null) {
      setState(() {
        _deadSpace = deadSpace;
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
    _takenDate = DateTime.now();
    _takenDose = widget.schedule.dose;
    _takenDoseController =
        TextEditingController(text: widget.schedule.dose.toString());
    _deadSpaceController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _takenDoseController.dispose();
    _deadSpaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MedicationIntakeProvider, MedicationSupplyProvider>(
      builder: (context, medicationIntakeProvider, medicationSupplyProvider, child) {
        final bool isLoading =
            medicationIntakeProvider.isLoading || medicationSupplyProvider.isLoading;

        if (!isLoading && !_hasInitializedSide && _isInjection) {
          _selectedSide = MedicationIntakeManager(
            medicationIntakeProvider,
            medicationSupplyProvider,
          ).getNextSide();
          _hasInitializedSide = true;
        }

        if (!isLoading && !_hasInitializedMedicationSupply) {
          _selectedMedicationSupply = medicationSupplyProvider.getMostUsedItemForMedication(
            widget.schedule.molecule,
            widget.schedule.administrationRoute,
            widget.schedule.ester,
          );
          _hasInitializedMedicationSupply = true;
        }

        final medicationSupplyOptions = medicationSupplyProvider.getItemsForMedication(
          widget.schedule.molecule,
          widget.schedule.administrationRoute,
          widget.schedule.ester,
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
          title: 'Take ${widget.schedule.name}',
          avatar: widget.schedule.administrationRoute.icon,
          submitButtonLabel: 'Take intake',
          isFormValid: _isFormValid,
          saveChanges: (!isLoading && _isFormValid)
              ? () => _takeIntake(medicationIntakeProvider, medicationSupplyProvider)
              : () {},
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
              inputType: TextInputType.numberWithOptions(decimal: true),
              suffixText: widget.schedule.molecule.unit,
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
                            ' $_takenDose ${widget.schedule.molecule.unit} = ${_selectedMedicationSupply!.getAmount(_takenDose)} ${_selectedMedicationSupply!.administrationRoute.unit}',
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
            if (_isInjection) ...[
              FormDropdownField<InjectionSide>(
                value: _selectedSide,
                items: InjectionSideDropdown.menuItems,
                onChanged: _onInjectionSideChanged,
                label: 'Injection side',
              ),
              FormTextField(
                controller: _deadSpaceController,
                label: 'Needle dead space',
                onChanged: _onDeadSpaceChanged,
                inputType: TextInputType.numberWithOptions(decimal: true),
                suffixText: 'μL',
                errorText: _deadSpaceError,
                regexFormatter: r'[0-9.,]',
              ),
            ],
          ],
        );
      },
    );
  }
}
