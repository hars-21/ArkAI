import 'package:flutter/material.dart';

class BrowserProvider extends ChangeNotifier {
  String _currentUrl = '';
  bool _isLoading = false;
  bool _isProductPage = false;

  String get currentUrl => _currentUrl;
  bool get isLoading => _isLoading;
  bool get isProductPage => _isProductPage;

  void setUrl(String url) {
    _currentUrl = url;
    _checkIfProductPage(url);
    notifyListeners();
  }

  void _checkIfProductPage(String url) {
    final lowerUrl = url.toLowerCase();

    // Amazon
    final isAmazonProduct =
        lowerUrl.contains('/dp/') || lowerUrl.contains('/gp/product/');

    // Flipkart
    final isFlipkartProduct =
        lowerUrl.contains('/p/') || lowerUrl.contains('pid=');

    // Myntra
    final isMyntraProduct =
        lowerUrl.contains('/buy') || lowerUrl.contains(RegExp(r'/\d+/buy'));

    _isProductPage = isAmazonProduct || isFlipkartProduct || isMyntraProduct;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProductPage(bool isProduct) {
    _isProductPage = isProduct;
    notifyListeners();
  }
}
