import 'package:decimal/decimal.dart';
import 'package:mona/controllers/medication_supply_manager.dart';
import 'package:mona/data/model/medication_schedule.dart';
import 'package:mona/data/model/medication_supply.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';
import '../data/model/medication_intake.dart';
import '../data/providers/medication_intake_provider.dart';

class MedicationIntakeManager {
  final MedicationIntakeProvider _medicationIntakeProvider;
  final MedicationSupplyProvider _medicationSupplyProvider;

  MedicationIntakeManager(
      this._medicationIntakeProvider, this._medicationSupplyProvider);

  Future<void> takeMedication({
    required Decimal dose,
    required DateTime scheduledDate,
    required DateTime takenDate,
    MedicationSupply? medicationSupply,
    required MedicationSchedule schedule,
    InjectionSide? side,
    Decimal? deadSpace, //in μL
  }) async {
    await _medicationIntakeProvider.add(MedicationIntake(
      dose: dose,
      scheduledDateTime: scheduledDate,
      takenDateTime: takenDate,
      side: side,
      scheduleId: schedule.id,
      molecule: schedule.molecule,
      administrationRoute: schedule.administrationRoute,
      ester: schedule.ester,
    ));

    if (medicationSupply != null) {
      if (deadSpace != null && deadSpace > Decimal.zero) {
        final deadSpaceMl = deadSpace * Decimal.parse('0.001');
        dose += medicationSupply.getDose(deadSpaceMl);
      }

      await MedicationSupplyManager(_medicationSupplyProvider).useDose(medicationSupply, dose);
    }
  }

  InjectionSide getNextSide() {
    final lastIntake = _medicationIntakeProvider.getLastTakenIntake();
    if (lastIntake == null || lastIntake.side == null) {
      return InjectionSide.left;
    }
    return lastIntake.side == InjectionSide.left
        ? InjectionSide.right
        : InjectionSide.left;
  }
}
