import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get showFavorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  // void showFavoritesOnly() {
  //   _showFavorites = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorites = false;
  //   notifyListeners();
  // }
  String token;
  String userId;
  Products();

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  void update(String tok, String uid, Products product) {
    token = tok;
    _items = product == null ? [] : product._items;
    userId = uid;
    notifyListeners();
  }

  Future<void> addNewProducts(Product product) {
    final url = Uri.parse(
        'https://flutter-project-f57eb-default-rtdb.firebaseio.com/products.json?auth=$token');

    return http
        .post(
      url,
      body: json.encode(
        {
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        },
      ),
    )
        .then(
      (response) {
        Product editedValue = Product(
          description: product.description,
          title: product.title,
          imageUrl: product.imageUrl,
          price: product.price,
          id: json.decode(response.body)['name'],
        );
        _items.insert(0, editedValue);

        notifyListeners();
      },
    ).catchError((error) {
      print(error);
    });
  }

  Future<void> editProducts(String id, Product product) async {
    var productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-project-f57eb-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
      await http.patch(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );
    }
    _items[productIndex] = product;
    notifyListeners();
  }

  void deleteProducts(String id) async {
    final url = Uri.parse(
        'https://flutter-project-f57eb-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final productIndex = _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(productIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  Future<void> fetchAndGetResults([bool filterByUser = false]) async {
    final filterByString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://flutter-project-f57eb-default-rtdb.firebaseio.com/products.json?auth=$token&$filterByString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }

      final favUrl = Uri.parse(
          'https://flutter-project-f57eb-default-rtdb.firebaseio.com/userfavorites/$userId.json?auth=$token');

      final favResponse = await http.get(favUrl);
      final favData = json.decode(favResponse.body);
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
              isFavorite: favData == null ? false : favData[prodId] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
