import 'package:hive/hive.dart';
import '../models/meal.dart';

class FavoriteService {
  static const String _boxName = 'favorites';

  Box<Meal> get _box => Hive.box<Meal>(_boxName);

  static Future<void> init() async {
    await Hive.openBox<Meal>(_boxName);
  }

  List<Meal> getFavorites() {
    return _box.values.toList();
  }

  bool isFavorite(String idMeal) {
    return _box.containsKey(idMeal);
  }

  Future<void> addFavorite(Meal meal) async {
    await _box.put(meal.idMeal, meal);
  }

  Future<void> removeFavorite(String idMeal) async {
    await _box.delete(idMeal);
  }

  Future<void> toggleFavorite(Meal meal) async {
    if (isFavorite(meal.idMeal)) {
      await removeFavorite(meal.idMeal);
    } else {
      await addFavorite(meal);
    }
  }
}
