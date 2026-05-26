class Seat {
  final int id;
  final int row;
  final int number;
  final bool isOccupied;

  Seat({
    required this.id,
    required this.row,
    required this.number,
    required this.isOccupied,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] ?? 0,
      row: json['row'] ?? 0,
      number: json['number'] ?? 0,
      isOccupied: json['isOccupied'] ?? false,
    );
  }
}