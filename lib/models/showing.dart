import 'room.dart';

class Showing {
  final int id;
  final DateTime date;
  final DateTime endDate;
  final int movieId;
  final String movieTitle;
  final int roomId;
  final int roomNumber;
  final double price;
  final Room? room; // <--- DODANE POLE SALI

  Showing({
    required this.id,
    required this.date,
    required this.endDate,
    required this.movieId,
    required this.movieTitle,
    required this.roomId,
    required this.roomNumber,
    required this.price,
    this.room, // <--- DODANE
  });

  factory Showing.fromJson(Map<String, dynamic> json) {
    return Showing(
      id: json['id'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_Date'] ?? '') ?? DateTime.now(),
      movieId: json['movie_Id'] ?? 0,
      movieTitle: json['movieTitle'] ?? '',
      roomId: json['room_Id'] ?? 0,
      roomNumber: json['roomNumber'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      // <--- MAPOWANIE SALI I MIEJSC
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
    );
  }
}