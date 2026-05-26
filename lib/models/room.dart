import 'seat.dart';

class Room {
  final int id;
  final int number;
  final int seats;
  final int generatedSeatsCount;
  final List<Seat> seatObjects;

  Room({
    required this.id,
    required this.number,
    required this.seats,
    required this.generatedSeatsCount,
    required this.seatObjects,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      seats: json['seats'] ?? 0,
      generatedSeatsCount: json['generatedSeatsCount'] ?? 0,
      seatObjects: json['seatObjects'] != null
          ? (json['seatObjects'] as List).map((i) => Seat.fromJson(i)).toList()
          : [],
    );
  }
}