import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movie_reservation_system_mobile/widgets/footer.dart';
import 'package:movie_reservation_system_mobile/widgets/navbar.dart';
import '../models/models.dart';
import '../data/api_client.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedGenre = 'Wszystkie';
  bool _isLoggedIn = false;
  bool _isLoading = true;

  List<Genre> _genres = [];
  List<Movie> _movies = [];

  final _storage = const FlutterSecureStorage();
  final _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Sprawdzamy token w pamięci urządzenia
    final token = await _storage.read(key: 'jwt_token');

    // 2. Pobieramy filmy i gatunki z API równolegle (odpowiednik Promise.all)
    final results = await Future.wait([
      _apiClient.getMovies(),
      _apiClient.getGenres(),
    ]);

    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;

        // 3. Rzutujemy wyniki i zapisujemy w stanie
        _movies = results[0] as List<Movie>;
        _genres = results[1] as List<Genre>;

        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // 1. Usuwamy token z bezpiecznego schowka
    await _storage.delete(key: 'jwt_token');

    // 2. Aktualizujemy stan UI
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
      });

      // 3. Pokazujemy potwierdzenie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wylogowano pomyślnie!'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtracja filmów z wybranego gatunku
    final filteredMovies = _selectedGenre == 'Wszystkie'
        ? _movies
        : _movies.where((m) => m.genres.contains(_selectedGenre)).toList();

    const bgColor = Color(0xFF1E1E2C);
    const primaryColor = Colors.deepPurpleAccent;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      // NAVBAR wydzielony do osobnego pliku
      appBar: Navbar(
        isLoggedIn: _isLoggedIn,
        onLogoutPressed: _handleLogout,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
        onRefresh: _loadInitialData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Najnowsze premiery',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // PASEK KATEGORII
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildCategoryButton('Wszystkie', _selectedGenre == 'Wszystkie', primaryColor),
                    ..._genres.map((g) => _buildCategoryButton(g.name, _selectedGenre == g.name, primaryColor)),
                  ],
                ),
              ),

              // SIATKA FILMÓW
              if (filteredMovies.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      'Nie znaleziono filmów w tej kategorii.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true, // Kluczowe, by GridView działał wewnątrz SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    return _buildMovieCard(filteredMovies[index], bgColor);
                  },
                ),

              const SizedBox(height: 40),

              // FOOTER wydzielony do osobnego pliku
              const Footer(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- KOMPONENTY POMOCNICZE WIDOKU ---

  Widget _buildCategoryButton(String title, bool isActive, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedGenre = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.2) : const Color(0xFF2A2A3D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? primaryColor : Colors.transparent,
              width: 1,
            ),
            boxShadow: isActive ? [] : const [
              BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? primaryColor : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie, Color bgColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
        );
        },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF2A2A3D),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 8),
                  BoxShadow(color: Colors.white10, offset: Offset(-2, -2), blurRadius: 6),
                ],
                image: movie.posterPath.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(movie.posterPath),
                  fit: BoxFit.cover,
                )
                    : null, // Fallback, jeśli backend zwróci puste pole plakatu
              ),
              // Zastępcza ikona, gdy nie ma plakatu
              child: movie.posterPath.isEmpty
                  ? const Icon(Icons.movie, size: 50, color: Colors.white24)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            movie.genres.join(' / '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 2),
          Text(
            '${movie.duration} min',
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}