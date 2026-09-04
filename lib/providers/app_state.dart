import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/blur_detector.dart';
import '../services/localization.dart';
import '../services/model_runner.dart';

class ScanRecord {
  final String imagePath;
  final BlurAnalysisResult analysis;
  final ModelInferenceResult modelResult;
  final DateTime timestamp;

  ScanRecord({
    required this.imagePath,
    required this.analysis,
    required this.modelResult,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AppState extends ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  String _currentLanguage = AppLanguage.english;
  String get currentLanguage => _currentLanguage;

  String? _currentImagePath;
  String? get currentImagePath => _currentImagePath;

  BlurAnalysisResult? _currentAnalysis;
  BlurAnalysisResult? get currentAnalysis => _currentAnalysis;

  ModelInferenceResult? _currentModelResult;
  ModelInferenceResult? get currentModelResult => _currentModelResult;

  final List<ScanRecord> _scanHistory = [];
  List<ScanRecord> get scanHistory => List.unmodifiable(_scanHistory);

  AppState() {
    _initModelStatus();
  }

  Future<void> _initModelStatus() async {
    await ModelRunner.isModelAvailable();
    notifyListeners();
  }

  void setLanguage(String lang) {
    if (_currentLanguage != lang) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  void setTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<BlurAnalysisResult> analyzeFile(String path) async {
    _currentImagePath = path;
    final file = File(path);

    if (!file.existsSync()) {
      final fallback = BlurDetector.analyzeImage(Uint8List(0));
      _currentAnalysis = fallback;
      _currentModelResult = await ModelRunner.runInference(Uint8List(0));
      notifyListeners();
      return fallback;
    }

    final bytes = await file.readAsBytes();
    final blurResult = BlurDetector.analyzeImage(bytes);
    final modelResult = await ModelRunner.runInference(bytes);

    _currentAnalysis = blurResult;
    _currentModelResult = modelResult;

    _scanHistory.insert(
      0,
      ScanRecord(
        imagePath: path,
        analysis: blurResult,
        modelResult: modelResult,
      ),
    );

    notifyListeners();
    return blurResult;
  }

  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
  }
}
