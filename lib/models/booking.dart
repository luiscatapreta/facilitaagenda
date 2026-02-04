class Booking {
  final String id;
  final String clientName;
  final double value;
  bool hasDeposit; // editável
  String notes;    // 👈 AGORA editável
  final DateTime date;

  Booking({
    required this.id,
    required this.clientName,
    required this.value,
    required this.hasDeposit,
    required this.notes,
    required this.date,
  });
}