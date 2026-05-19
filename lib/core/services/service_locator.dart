import 'package:get_it/get_it.dart';
import 'storage_service.dart';
import 'tts_service.dart';
import 'export_service.dart';

final getIt = GetIt.instance;

/// Sets up dependency injection for core services.
/// Ensures all background drivers are registered cleanly on application startup.
Future<void> setupServiceLocator() async {
  // 1. Initialize and register the local Hive DB persistence manager
  final storageService = StorageService();
  await storageService.initialize();
  getIt.registerSingleton<StorageService>(storageService);

  // 2. Register local Text-to-Speech synthesis coordinator
  getIt.registerSingleton<TtsService>(TtsService());

  // 3. Register PDF/CSV compilation and export system coordinator
  getIt.registerSingleton<ExportService>(ExportService());
}
