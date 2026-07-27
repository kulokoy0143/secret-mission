import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'features/training/models/workout_set.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(WorkoutSetAdapter());
  }

  await Hive.openBox<WorkoutSet>('workout_sets');

  runApp(const SecretMissionApp());
}
