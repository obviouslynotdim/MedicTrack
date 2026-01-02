class Medicine {
  final String name;
  final String time;
  bool taken;

  Medicine({
    required this.name,
    required this.time,
    this.taken = false,
  });
}
