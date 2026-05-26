class Reservation {
  final int id;
  final DateTime createdAt; // Zamiast String, od razu formatujemy do DateTime
  final String userId;
  final String userEmail;
  final int showingId;
  final String movieTitle;
  final DateTime showingDate;
  final int seatId;
  final int seatRow;
  final int seatNumber;

  Reservation({
    required this.id,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    required this.showingId,
    required this.movieTitle,
    required this.showingDate,
    required this.seatId,
    required this.seatRow,
    required this.seatNumber,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_At'] ?? '') ?? DateTime.now(),
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      showingId: json['showingId'] ?? 0,
      movieTitle: json['movieTitle'] ?? '',
      showingDate: DateTime.tryParse(json['showingDate'] ?? '') ?? DateTime.now(),
      seatId: json['seatId'] ?? 0,
      seatRow: json['seatRow'] ?? 0,
      seatNumber: json['seatNumber'] ?? 0,
    );
  }
}