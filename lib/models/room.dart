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
    List<Seat> parsedSeats = [];

    // Backend z C# czasem zwraca listę miejsc pod kluczem 'seatObjects',
    // a czasem (jak widać w pobieraniu filmu) pod kluczem 'seats'.
    if (json['seats'] is List) {
      parsedSeats = (json['seats'] as List).map((i) => Seat.fromJson(i)).toList();
    } else if (json['seatObjects'] is List) {
      parsedSeats = (json['seatObjects'] as List).map((i) => Seat.fromJson(i)).toList();
    }

    return Room(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      // Jeśli 'seats' okazało się listą, chronimy aplikację przed crashem
      seats: json['seats'] is int ? json['seats'] : parsedSeats.length,
      generatedSeatsCount: json['generatedSeatsCount'] is int ? json['generatedSeatsCount'] : 0,
      seatObjects: parsedSeats, // Zawsze mamy pewność, że to prawidłowa lista
    );
  }
}