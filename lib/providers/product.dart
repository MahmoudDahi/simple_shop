import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavorite(bool favorite) {
    isFavorite = favorite;
    notifyListeners();
  }

  Future<void> toggleFavoriteState() async {
    var oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.https('flutter-shop-app-e93e2-default-rtdb.firebaseio.com',
        '/products/$id.json');

    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
         _setFavorite(oldStatus);
      }
    } catch (error) {
      _setFavorite(oldStatus);
    } finally {
      oldStatus = null;
    }
  }
}
