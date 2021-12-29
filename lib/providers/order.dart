import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Order with ChangeNotifier {
  final _uri = 'flutter-shop-app-e93e2-default-rtdb.firebaseio.com';
  final _ordersUri = '/orders.json';

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(_uri, _ordersUri);
    List<OrderItem> loadingOrders = [];

    try {
      final response = await http.get(url);
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      if (extractData == null) return;
      extractData.forEach((orderId, ord) {
        loadingOrders.add(
          OrderItem(
            id: orderId,
            amount: ord['amount'],
            dateTime: DateTime.tryParse(ord['dateTime']),
            products: (ord['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    title: item['title'],
                    quantity: item['quantity'],
                  ),
                )
                .toList(),
          ),
        );
      });
      _orders = loadingOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    } finally {
      loadingOrders = null;
    }
  }

  Future<void> addOrder(List<CartItem> cartItems, double totalPrice) async {
    final url = Uri.https(_uri, _ordersUri);
    final timestamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': totalPrice,
            'dateTime': timestamp.toIso8601String(),
            'products': cartItems
                .map((ct) => {
                      'id': ct.id,
                      'price': ct.price,
                      'title': ct.title,
                      'quantity': ct.quantity,
                    })
                .toList(),
          }));

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: totalPrice,
          dateTime: timestamp,
          products: cartItems,
        ),
      );
      notifyListeners();
    } catch (error) {}
  }
}
