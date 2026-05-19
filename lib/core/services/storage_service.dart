import 'package:hive_flutter/hive_flutter.dart';
import '../../features/calculator/data/models/history_item_model.dart';

/// Elite local database coordinator using Hive for super-fast offline caching.
/// Operates 100% locally and requires no server costs or paid database clouds.
class StorageService {
  static const String _historyBoxName = "voxcalc_history";
  static const String _settingsBoxName = "voxcalc_settings";

  /// Initializes the local database on the physical device
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register the HistoryItem adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryItemModelAdapter());
    }

    // Open persistent boxes
    await Hive.openBox<HistoryItemModel>(_historyBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // ==========================================
  // Calculation History Methods
  // ==========================================

  /// Returns all stored history logs, sorted by timestamp descending
  List<HistoryItemModel> getHistory() {
    final box = Hive.box<HistoryItemModel>(_historyBoxName);
    final list = box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Adds a calculation result log into the history cache
  Future<void> saveHistory(HistoryItemModel item) async {
    final box = Hive.box<HistoryItemModel>(_historyBoxName);
    await box.put(item.id, item);
  }

  /// Deletes an individual history card log from storage
  Future<void> deleteHistory(String id) async {
    final box = Hive.box<HistoryItemModel>(_historyBoxName);
    await box.delete(id);
  }

  /// Clears the entire database of history logs
  Future<void> clearHistory() async {
    final box = Hive.box<HistoryItemModel>(_historyBoxName);
    await box.clear();
  }

  // ==========================================
  // Stateful Hydration & Preference Configs
  // ==========================================

  /// Saves a general system configuration key-value
  Future<void> saveConfig(String key, dynamic value) async {
    final box = Hive.box(_settingsBoxName);
    await box.put(key, value);
  }

  /// Loads a configuration key, providing a default if uninitialized
  dynamic getConfig(String key, {dynamic defaultValue}) {
    final box = Hive.box(_settingsBoxName);
    return box.get(key, defaultValue: defaultValue);
  }

  /// Clears all preferences in the settings drawer box
  Future<void> clearPreferences() async {
    final box = Hive.box(_settingsBoxName);
    await box.clear();
  }
}
