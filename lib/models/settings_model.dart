class SettingsModel {
  final bool hapticsEnabled;
  final int dailyGoal;

  const SettingsModel({this.hapticsEnabled = true, this.dailyGoal = 5});

  SettingsModel copyWith({bool? hapticsEnabled, int? dailyGoal}) {
    return SettingsModel(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {'hapticsEnabled': hapticsEnabled, 'dailyGoal': dailyGoal};
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 5,
    );
  }
}
