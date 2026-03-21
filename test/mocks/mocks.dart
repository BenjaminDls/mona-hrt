import 'package:mockito/annotations.dart';
import 'package:mona/controllers/medication_supply_manager.dart';
import 'package:mona/data/providers/medication_intake_provider.dart';
import 'package:mona/data/providers/medication_schedule_provider.dart';
import 'package:mona/data/providers/medication_supply_provider.dart';

@GenerateMocks([MedicationSupplyProvider])
@GenerateMocks([MedicationIntakeProvider])
@GenerateMocks([MedicationScheduleProvider])
@GenerateMocks([MedicationSupplyManager])
void main() {}
