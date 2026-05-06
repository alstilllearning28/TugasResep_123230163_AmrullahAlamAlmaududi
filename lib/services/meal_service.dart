import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> getMealsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/filter.php?c=$category'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => Meal.fromJson(m)).toList();
    }
    throw Exception('Gagal memuat resep');
  }

  Future<List<Meal>> searchMeals(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.php?s=$query'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => Meal.fromJson(m)).toList();
    }
    throw Exception('Gagal mencari resep');
  }

  Future<Meal?> getMealById(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lookup.php?i=$id'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null || meals.isEmpty) return null;
      return Meal.fromJson(meals[0]);
    }
    throw Exception('Gagal memuat detail resep');
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categories.php'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categories = data['categories'] as List?;
      if (categories == null) return [];
      return categories.map((c) => c['strCategory'].toString()).toList();
    }
    throw Exception('Gagal memuat kategori');
  }
}
