class Movie {
  final int id;
  final String title;
  final String description;
  final String status;
  final String releaseDate; // Poprawiłem literówkę w nazwie zmiennej darta
  final int duration;
  final String director;
  final String production;
  final String cast;
  final List<String> genres;
  final String posterPath;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.releaseDate,
    required this.duration,
    required this.director,
    required this.production,
    required this.cast,
    required this.genres,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      releaseDate: json['relase_Date'] ?? '',
      duration: json['duration'] ?? 0,
      director: json['director'] ?? '',
      production: json['production'] ?? '',
      cast: json['cast'] ?? '',
      genres: json['genres'] != null ? List<String>.from(json['genres']) : [],
      posterPath: json['posterPath'] ?? '',
    );
  }
}