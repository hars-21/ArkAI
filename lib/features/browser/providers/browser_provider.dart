import 'package:flutter/material.dart';

class BrowserProvider extends ChangeNotifier {
  String _currentUrl = '';
  bool _isLoading = false;
  bool _isProductPage = false;
  String _currentWebsite = '';

  String get currentUrl => _currentUrl;
  bool get isLoading => _isLoading;
  bool get isProductPage => _isProductPage;
  String get currentWebsite => _currentWebsite;

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

    // Nykaa
    final isNykaaProduct =
        lowerUrl.contains('/p/') || lowerUrl.contains('-product-');

    _isProductPage = isAmazonProduct || isFlipkartProduct || isNykaaProduct;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProductPage(bool isProduct) {
    _isProductPage = isProduct;
    notifyListeners();
  }

  void setWebsite(String website) {
    _currentWebsite = website;
    notifyListeners();
  }
}
