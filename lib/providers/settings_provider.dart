import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsModel>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  static const String _hapticsKey = 'settings_haptics';
  static const String _dailyGoalKey = 'settings_daily_goal';

  SharedPreferences? _preferences;

  // Sequential settings writes.
  Future<void> _pendingSave = Future.value();

  @override
  Future<SettingsModel> build() async {
    _preferences = await SharedPreferences.getInstance();

    return SettingsModel(
      hapticsEnabled: _preferences!.getBool(_hapticsKey) ?? true,
      dailyGoal: _preferences!.getInt(_dailyGoalKey) ?? 5,
    );
  }

  // ======================================================
  // UPDATE HAPTICS
  // ======================================================

  Future<void> setHapticsEnabled(bool enabled) async {
    final current = state.value ?? const SettingsModel();

    if (current.hapticsEnabled == enabled) return;

    final updated = current.copyWith(hapticsEnabled: enabled);

    await _saveSettings(
      previous: current,
      updated: updated,
      save: (prefs) {
        return prefs.setBool(_hapticsKey, enabled);
      },
    );
  }

  // ======================================================
  // UPDATE DAILY GOAL
  // ======================================================

  Future<void> setDailyGoal(int goal) async {
    final safeGoal = goal.clamp(1, 20).toInt();

    final current = state.value ?? const SettingsModel();

    if (current.dailyGoal == safeGoal) return;

    final updated = current.copyWith(dailyGoal: safeGoal);

    await _saveSettings(
      previous: current,
      updated: updated,
      save: (prefs) {
        return prefs.setInt(_dailyGoalKey, safeGoal);
      },
    );
  }

  // ======================================================
  // SAVE SETTINGS
  // ======================================================

  Future<void> _saveSettings({
    required SettingsModel previous,
    required SettingsModel updated,
    required Future<bool> Function(SharedPreferences prefs) save,
  }) async {
    // Immediately update UI.
    state = AsyncData(updated);

    final operation = _pendingSave.catchError((_) {}).then((_) async {
      final prefs = _preferences ?? await SharedPreferences.getInstance();

      _preferences = prefs;

      final saved = await save(prefs);

      if (!saved) {
        throw Exception('Settings could not be saved.');
      }
    });

    _pendingSave = operation;

    try {
      await operation;
    } catch (error, stackTrace) {
      // Restore only if this is still the latest update.
      if (identical(state.value, updated)) {
        state = AsyncData(previous);
      }

      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
