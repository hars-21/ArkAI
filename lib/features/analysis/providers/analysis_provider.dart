import 'package:flutter/material.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/services/analysis_service.dart';

class AnalysisProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();

  bool _isLoading = false;
  AnalysisModel? _analysisData;

  bool get isLoading => _isLoading;
  AnalysisModel? get analysisData => _analysisData;

  Future<void> analyzeProduct(String url) async {
    _isLoading = true;
    _analysisData = null;
    notifyListeners();

    _analysisData = await _analysisService.analyzeProduct(url);

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _analysisData = null;
    notifyListeners();
  }
}
