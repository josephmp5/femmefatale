import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings {
  final bool darkMode;

  Settings({required this.darkMode});

  Settings copyWith({bool? darkMode}) {
    return Settings(darkMode: darkMode ?? this.darkMode);
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings(darkMode: false));

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
