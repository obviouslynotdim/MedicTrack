enum RepeatPattern {
  none,
  daily,
  weekly,
  monthly;

  static RepeatPattern fromString(String value) {
    return RepeatPattern.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RepeatPattern.none,
    );
  }
}
