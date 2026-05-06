import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final String mealId;

  const DetailPage({super.key, required this.mealId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _mealService = MealService();
  final _favoriteService = FavoriteService();
  Meal? _meal;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final meal = await _mealService.getMealById(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
        _isFavorite =
            meal != null ? _favoriteService.isFavorite(meal.idMeal) : false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat detail resep';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_meal == null) return;
    await _favoriteService.toggleFavorite(_meal!);
    setState(() {
      _isFavorite = _favoriteService.isFavorite(_meal!.idMeal);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? '${_meal!.strMeal} ditambahkan ke favorit'
              : '${_meal!.strMeal} dihapus dari favorit',
        ),
        backgroundColor: _isFavorite ? Colors.green : const Color(0xFF666666),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMeal,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800)),
                        child: const Text('Coba Lagi',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _meal == null
                  ? const Center(child: Text('Resep tidak ditemukan'))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          backgroundColor: const Color(0xFFFF9800),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: CachedNetworkImage(
                              imageUrl: _meal!.strMealThumb,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFFFF9800)),
                                ),
                              ),
                              errorWidget: (ctx, url, err) => Container(
                                color: const Color(0xFFEEEEEE),
                                child: const Icon(Icons.broken_image,
                                    size: 80, color: Color(0xFFCCCCCC)),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama resep
                                Text(
                                  _meal!.strMeal,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Tags kategori & area
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (_meal!.strCategory != null)
                                      _buildTag(
                                        Icons.category_outlined,
                                        _meal!.strCategory!,
                                      ),
                                    if (_meal!.strArea != null)
                                      _buildTag(
                                        Icons.public,
                                        _meal!.strArea!,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Tombol favorit
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleFavorite,
                                    icon: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      _isFavorite
                                          ? 'Hapus dari Favorit'
                                          : 'Tambah ke Favorit',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFavorite
                                          ? const Color(0xFFE53935)
                                          : const Color(0xFFFF9800),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Bahan-bahan
                                const Text(
                                  'Bahan-bahan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...List.generate(_meal!.ingredients.length,
                                    (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                              top: 6, right: 10),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFFF9800),
                                          ),
                                        ),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF444444),
                                              ),
                                              children: [
                                                if (_meal!
                                                    .measures[i].isNotEmpty)
                                                  TextSpan(
                                                    text:
                                                        '${_meal!.measures[i]} ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF333333),
                                                    ),
                                                  ),
                                                TextSpan(
                                                    text:
                                                        _meal!.ingredients[i]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 28),
                                // Cara memasak
                                const Text(
                                  'Cara Memasak',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_meal!.strInstructions != null)
                                  ..._buildInstructions(
                                      _meal!.strInstructions!),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF9800)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888800),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInstructions(String instructions) {
    final steps = instructions
        .split(RegExp(r'\r?\n\r?\n|\r\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (steps.length <= 1) {
      // Split by \n
      final lines =
          instructions.split('\n').where((s) => s.trim().isNotEmpty).toList();
      return lines.asMap().entries.map((e) {
        return _buildStepItem(e.key + 1, e.value.trim());
      }).toList();
    }

    return steps.asMap().entries.map((e) {
      return _buildStepItem(e.key + 1, e.value.trim());
    }).toList();
  }

  Widget _buildStepItem(int step, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF9800),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
