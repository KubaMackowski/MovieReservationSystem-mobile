import 'dart:developer'; // Narzędzie do logowania w konsoli i profilerze
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class ApiClient {
  late final Dio _dio;

  String get _baseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
      if (Platform.isIOS) return 'http://localhost:8080/api';
    }
    return 'https://twoja-produkcyjna-domena.com/api';
  }

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      contentType: 'application/json',
    ));
  }

  Future<Response> login(String email, String password) async {
    try {
      log('Wysyłam zapytanie do: $_baseUrl/auth/login', name: 'API_REQUEST');

      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      log('Odpowiedź sukces: ${response.data}', name: 'API_RESPONSE');
      log('Typ odpowiedzi (sukces): ${response.data.runtimeType}', name: 'API_RESPONSE_TYPE');

      return response;

    } on DioException catch (e) {
      // LOGI DLA BŁĘDÓW (np. złe hasło)
      log('Błąd DioException: ${e.message}', name: 'API_ERROR');
      log('Status code: ${e.response?.statusCode}', name: 'API_ERROR_STATUS');
      log('Data z błędu: ${e.response?.data}', name: 'API_ERROR_DATA');
      log('Typ danych z błędu: ${e.response?.data.runtimeType}', name: 'API_ERROR_TYPE');

      String errorMessage = 'Błąd połączenia z serwerem';

      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;

        try {
          // BARDZO BEZPIECZNE PARSOWANIE
          if (data is String) {
            errorMessage = data;
            log('Odczytano błąd jako String', name: 'API_PARSER');
          } else if (data is Map) {
            errorMessage = data['message']?.toString() ?? 'Nieznany błąd (brak klucza message)';
            log('Odczytano błąd jako Map (JSON)', name: 'API_PARSER');
          } else if (data is List) {
            errorMessage = data.join(', ');
            log('Odczytano błąd jako List', name: 'API_PARSER');
          }
        } catch (parseError) {
          log('KRYTYCZNY błąd podczas parsowania: $parseError', name: 'API_PARSE_ERROR');
          errorMessage = 'Nie udało się odczytać odpowiedzi serwera';
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      log('Nieoczekiwany błąd: $e', name: 'API_FATAL');
      throw Exception('Nieoczekiwany błąd aplikacji');
    }
  }

  // 1. Pobieranie Gatunków
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _dio.get('/genres'); // Omijam /api/, bo jest już w _baseUrl
      final List<dynamic> data = response.data;
      return data.map((json) => Genre.fromJson(json)).toList();
    } catch (e) {
      log('Błąd pobierania gatunków: $e', name: 'API_GET_GENRES');
      return [];
    }
  }

  // 2. Pobieranie Filmów
  Future<List<Movie>> getMovies() async {
    try {
      final response = await _dio.get('/movies');
      final List<dynamic> data = response.data;
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      log('Błąd pobierania filmów: $e', name: 'API_GET_MOVIES');
      return [];
    }
  }

  // 3. Pojedynczy film
  Future<Movie?> getMovieById(int id) async {
    try {
      final response = await _dio.get('/movies/$id');
      return Movie.fromJson(response.data);
    } catch (e) {
      log('Błąd pobierania filmu $id: $e', name: 'API_GET_MOVIE');
      return null;
    }
  }
}