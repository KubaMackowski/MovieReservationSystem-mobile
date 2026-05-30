import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../data/api_client.dart';
import 'login_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final _apiClient = ApiClient();
  final _storage = const FlutterSecureStorage();

  Movie? _movie;
  bool _isLoading = true;
  bool _isBooking = false;

  // Stany rezerwacji
  DateTime? _selectedDate;
  Showing? _selectedShowing;
  Seat? _selectedSeat;
  String? _userId;

  // Kolory
  final Color _bgColor = const Color(0xFF1E1E2C);
  final Color _cardColor = const Color(0xFF2A2A3D);
  final Color _primaryColor = Colors.deepPurpleAccent;
  final Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProfile = await _apiClient.getMe();

    if (userProfile != null) {
      _userId = userProfile.id;
    }
    final movieData = await _apiClient.getMovieById(widget.movieId);

    if (mounted) {
      setState(() {
        _movie = movieData;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBooking() async {
    if (_selectedShowing == null || _selectedSeat == null) return;

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zaloguj się, aby złożyć rezerwację')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    setState(() => _isBooking = true);

    try {
      await _apiClient.createReservation(
        _selectedShowing!.id,
        _selectedSeat!.id,
        _userId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Złożono rezerwację pomyślnie!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Powrót do ekranu głównego po udanej rezerwacji
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  // Helper do formatowania daty (np. z "2026-05-31" na unikalne daty w UI)
  List<DateTime> _getUniqueDates() {
    if (_movie == null || _movie!.showings.isEmpty) return [];
    final dates = _movie!.showings.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().toList();
    dates.sort();
    return dates;
  }

  List<Showing> _getShowingsForSelectedDate() {
    if (_movie == null || _selectedDate == null) return [];
    final filtered = _movie!.showings.where((s) {
      return s.date.year == _selectedDate!.year &&
          s.date.month == _selectedDate!.month &&
          s.date.day == _selectedDate!.day;
    }).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgColor,
        body: const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent)),
      );
    }

    if (_movie == null) {
      return Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: Text('Błąd ładowania filmu', style: TextStyle(color: Colors.red, fontSize: 18))),
      );
    }

    final uniqueDates = _getUniqueDates();
    final filteredShowings = _getShowingsForSelectedDate();

    return Scaffold(
      backgroundColor: _bgColor,
      // Przypięty pasek na dole z podsumowaniem
      bottomNavigationBar: _buildBottomBookingBar(),
      body: CustomScrollView(
        slivers: [
          // Zastępuje klasyczny AppBar zdjęciem z efektem Parallax
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: _bgColor,
            iconTheme: IconThemeData(color: _textColor),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _movie!.posterPath,
                    fit: BoxFit.cover,
                  ),
                  // Gradient płynnie łączący zdjęcie z tłem aplikacji
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, _bgColor],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Główna treść
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TYTUŁ I GATUNKI
                  Text(
                    _movie!.title,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _textColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ..._movie!.genres.map((g) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(g, style: TextStyle(color: _primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          backgroundColor: _primaryColor.withOpacity(0.2),
                          side: BorderSide.none,
                        ),
                      )),
                      Chip(
                        label: Text('${_movie!.duration} min', style: TextStyle(color: Colors.black, fontSize: 12)),
                        backgroundColor: Colors.white12,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // OPIS
                  Text(
                    _movie!.description,
                    style: TextStyle(fontSize: 16, color: _textColor.withOpacity(0.8), height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // SEKCJA 1: DATY
                  _buildSectionTitle(Icons.today, 'Wybierz datę'),
                  if (uniqueDates.isEmpty)
                    Text('Brak dostępnych seansów', style: TextStyle(color: _textColor.withOpacity(0.5))),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: uniqueDates.map((date) {
                      final isSelected = _selectedDate == date;
                      return _buildSelectionButton(
                        text: '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                            _selectedShowing = null;
                            _selectedSeat = null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // SEKCJA 2: GODZINY
                  if (_selectedDate != null) ...[
                    _buildSectionTitle(Icons.schedule, 'Wybierz godzinę'),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: filteredShowings.map((showing) {
                        final isSelected = _selectedShowing?.id == showing.id;
                        final timeString = '${showing.date.hour.toString().padLeft(2, '0')}:${showing.date.minute.toString().padLeft(2, '0')}';
                        return _buildSelectionButton(
                          text: timeString,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedShowing = showing;
                              _selectedSeat = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // SEKCJA 3: SIEDZENIA
                  if (_selectedShowing != null) ...[
                    _buildSectionTitle(Icons.event_seat, 'Wybierz miejsce'),
                    _buildSeatsGrid(),
                    const SizedBox(height: 80), // Margines na dolny pasek rezerwacji
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETY POMOCNICZE ---

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
        ],
      ),
    );
  }

  Widget _buildSelectionButton({required String text, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.2) : _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _primaryColor : Colors.transparent),
          boxShadow: isSelected ? [] : const [
            BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 4),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? _primaryColor : _textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatsGrid() {
    // W prawdziwej aplikacji użyjesz _selectedShowing!.room.seatObjects
    // Tu dla bezpieczeństwa mockujemy pustą listę jeśli brakuje pokoju
    final seats = _selectedShowing!.room?.seatObjects ?? <Seat>[];
    if (seats.isEmpty) {
      return Center(child: Text('Brak danych o miejscach', style: TextStyle(color: Colors.red.shade400)));
    }

    // Grupowanie miejsc po rzędach
    final rowsMap = <int, List<Seat>>{};
    for (var seat in seats) {
      rowsMap.putIfAbsent(seat.row, () => []).add(seat);
    }
    final sortedRows = rowsMap.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // EKRAN
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: _primaryColor,
              boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.5), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 8),
          Text('EKRAN', style: TextStyle(fontSize: 10, color: _textColor.withOpacity(0.4), letterSpacing: 2)),
          const SizedBox(height: 32),

          // SIEDZENIA (Można scrollować na boki, gdy sala jest bardzo szeroka)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: sortedRows.map((rowNum) {
                final rowSeats = rowsMap[rowNum]!..sort((a, b) => a.number.compareTo(b.number));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(rowNum.toString(), style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 12)),
                      ),
                      ...rowSeats.map((seat) {
                        final isOccupied = seat.isOccupied;
                        final isSelected = _selectedSeat?.id == seat.id;

                        Color btnColor = _cardColor;
                        Color borderColor = Colors.transparent;
                        Color seatTextColor = _textColor.withOpacity(0.7);

                        if (isOccupied) {
                          btnColor = Colors.red.withOpacity(0.2);
                          seatTextColor = Colors.red.withOpacity(0.5);
                        } else if (isSelected) {
                          btnColor = _primaryColor;
                          seatTextColor = Colors.white;
                        }

                        return GestureDetector(
                          onTap: isOccupied
                              ? null
                              : () => setState(() => _selectedSeat = seat),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: btnColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderColor),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              seat.number.toString(),
                              style: TextStyle(fontSize: 12, color: seatTextColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Pasek podsumowania zablokowany na dole ekranu
  Widget _buildBottomBookingBar() {
    if (_selectedShowing == null) return const SizedBox.shrink();

    final price = _selectedShowing!.price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _bgColor,
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cena całkowita', style: TextStyle(color: _textColor.withOpacity(0.6), fontSize: 12)),
                Text(
                  _selectedSeat != null ? '${price.toStringAsFixed(2)} PLN' : '0.00 PLN',
                  style: TextStyle(color: _primaryColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _selectedSeat == null ? Colors.grey : _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedSeat == null || _isBooking ? null : _handleBooking,
              child: _isBooking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Zarezerwuj', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}