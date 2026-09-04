import 'dart:io';
import 'dart:typed_data';
import 'blur_detector.dart';

class InferenceService {
  /// Evaluates image quality (Blur variance, lighting, sharpness) without running ML model inference.
  static Future<BlurAnalysisResult> inspectImageQuality(String imagePath, {double threshold = 100.0}) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        return BlurDetector.analyzeImage(Uint8List(0), threshold: threshold);
      }
      final bytes = await file.readAsBytes();
      return BlurDetector.analyzeImage(bytes, threshold: threshold);
    } catch (e) {
      return BlurDetector.analyzeImage(Uint8List(0), threshold: threshold);
    }
  }
}
