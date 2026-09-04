import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:image/image.dart' as img;

class ModelInferenceResult {
  final bool isModelLoaded;
  final String modelStatusMessage;
  /// The raw winning class name exactly as the model outputs: healthy / mole / precancer / cancer
  final String? topLabel;
  final double? confidence;
  final Map<String, double>? labelProbabilities;
  /// 10×10 normalised heatmap values (0.0–1.0), averaged across feature_map channels
  final List<double>? heatmap;
  final DateTime timestamp;

  ModelInferenceResult({
    required this.isModelLoaded,
    required this.modelStatusMessage,
    this.topLabel,
    this.confidence,
    this.labelProbabilities,
    this.heatmap,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ModelRunner {
  static const String modelAssetPath = 'assets/models/dermascout_int8.onnx';
  static bool _isLoaded = false;
  static String _statusMessage = 'Model not loaded yet';

  static OrtSession? _ortSession;

  static const List<String> _classes = [
    "healthy",
    "mole",
    "precancer",
    "cancer",
  ];

  /// Load the model from assets if not already loaded.
  static Future<bool> isModelAvailable() async {
    if (_isLoaded && _ortSession != null) return true;
    try {
      final ByteData data = await rootBundle.load(modelAssetPath);
      if (data.lengthInBytes > 0) {
        OrtEnv.instance.init();
        final sessionOptions = OrtSessionOptions();
        final rawBytes = data.buffer.asUint8List();
        _ortSession = OrtSession.fromBuffer(rawBytes, sessionOptions);
        _isLoaded = true;
        _statusMessage =
            'Model loaded (${(data.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)} MB)';
        return true;
      }
    } catch (e) {
      debugPrint('Error loading ONNX model: $e');
    }
    _isLoaded = false;
    _statusMessage = 'Failed to load model';
    return false;
  }

  /// Run raw ONNX inference on image bytes with ZERO extra logic or math:
  ///   1. Decode image & bake EXIF orientation
  ///   2. Center crop (60% square) & resize 320×320
  ///   3. Normalize Float32 NCHW (0-1, subtract mean, divide std)
  ///   4. Run ONNX session
  ///   5. Softmax logits → argmax → raw model prediction
  static Future<ModelInferenceResult> runInference(Uint8List imageBytes) async {
    final available = await isModelAvailable();
    if (!available || _ortSession == null) {
      return ModelInferenceResult(
        isModelLoaded: false,
        modelStatusMessage: _statusMessage,
      );
    }

    try {
      // ── 1. Decode & Bake Orientation ───────────────────────────────────────
      img.Image? decoded = img.decodeImage(imageBytes);
      if (decoded == null) throw Exception('Failed to decode image');
      decoded = img.bakeOrientation(decoded);

      // ── 2. Center Crop & Resize to 320×320 ─────────────────────────────────
      final int baseSide = math.min(decoded.width, decoded.height);
      final double aspect = decoded.width / decoded.height;
      final bool isSquare = aspect >= 0.90 && aspect <= 1.10;
      final double cropRatio = isSquare ? 0.95 : 0.60;
      final int cropSize = (baseSide * cropRatio).round();
      final int ox = (decoded.width - cropSize) ~/ 2;
      final int oy = (decoded.height - cropSize) ~/ 2;
      final img.Image cropped =
          img.copyCrop(decoded, x: ox, y: oy, width: cropSize, height: cropSize);

      final img.Image resized =
          img.copyResize(cropped, width: 320, height: 320);

      // ── 3. Normalize → Float32 NCHW ───────────────────────────────────────
      const mean = [0.485, 0.456, 0.406];
      const std = [0.229, 0.224, 0.225];
      final inputData = Float32List(3 * 320 * 320);

      int idx = 0;
      for (int y = 0; y < 320; y++) {
        for (int x = 0; x < 320; x++) {
          final pixel = resized.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;

          inputData[idx]                 = (r - mean[0]) / std[0]; // R plane
          inputData[320 * 320 + idx]     = (g - mean[1]) / std[1]; // G plane
          inputData[2 * 320 * 320 + idx] = (b - mean[2]) / std[2]; // B plane
          idx++;
        }
      }

      // ── 4. Run ONNX Session ────────────────────────────────────────────────
      final tensor = OrtValueTensor.createTensorWithDataList(
          inputData, [1, 3, 320, 320]);
      final runOptions = OrtRunOptions();
      final inputs = {_ortSession!.inputNames[0]: tensor};
      final outputs = _ortSession!.run(runOptions, inputs);

      final batchLogits = outputs[0]?.value as List<dynamic>;
      final rawLogits = batchLogits[0] as List<dynamic>;
      final logits = rawLogits.map((e) => (e as num).toDouble()).toList();

      List<double>? heatmap;
      if (outputs.length > 1 && outputs[1] != null) {
        heatmap = _extractHeatmap(outputs[1]!.value);
      }

      // Clean up tensors
      tensor.release();
      runOptions.release();
      for (final out in outputs) {
        out?.release();
      }

      // ── 5. Pure Softmax → Argmax (Pure Raw Model Output) ───────────────────
      final probs = _softmax(logits);
      int topIdx = 0;
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > probs[topIdx]) topIdx = i;
      }

      final probMap = <String, double>{
        for (int i = 0; i < _classes.length; i++) _classes[i]: probs[i],
      };

      return ModelInferenceResult(
        isModelLoaded: true,
        modelStatusMessage: 'Inference complete',
        topLabel: _classes[topIdx],
        confidence: probs[topIdx],
        labelProbabilities: probMap,
        heatmap: heatmap,
      );
    } catch (e) {
      return ModelInferenceResult(
        isModelLoaded: true,
        modelStatusMessage: 'Inference failed: $e',
      );
    }
  }

  /// Average feature_map across channels to produce a 10×10 normalised heatmap (0.0–1.0).
  static List<double>? _extractHeatmap(dynamic rawValue) {
    if (rawValue == null) return null;
    try {
      final batch = rawValue as List<dynamic>;
      final channels = batch[0] as List<dynamic>;
      const h = 10, w = 10;
      final int numChannels = channels.length;

      final rawHeatmap = List<double>.filled(h * w, 0.0);

      for (int c = 0; c < numChannels; c++) {
        final rows = channels[c] as List<dynamic>;
        for (int row = 0; row < h; row++) {
          final cols = rows[row] as List<dynamic>;
          for (int col = 0; col < w; col++) {
            rawHeatmap[row * w + col] += (cols[col] as num).toDouble();
          }
        }
      }

      for (int i = 0; i < rawHeatmap.length; i++) {
        rawHeatmap[i] /= numChannels;
      }

      // Suppress extreme corner zero-padding artifacts from CNN borders
      // by clamping corner cells to their adjacent interior neighbors
      rawHeatmap[0] = math.min(rawHeatmap[0], math.max(rawHeatmap[1], rawHeatmap[w])); // [0,0]
      rawHeatmap[w - 1] = math.min(rawHeatmap[w - 1], math.max(rawHeatmap[w - 2], rawHeatmap[2 * w - 1])); // [0,9]
      rawHeatmap[(h - 1) * w] = math.min(rawHeatmap[(h - 1) * w], math.max(rawHeatmap[(h - 2) * w], rawHeatmap[(h - 1) * w + 1])); // [9,0]
      rawHeatmap[h * w - 1] = math.min(rawHeatmap[h * w - 1], math.max(rawHeatmap[h * w - 2], rawHeatmap[(h - 1) * w - 1])); // [9,9]

      // Robust percentile normalization
      final sorted = List<double>.from(rawHeatmap)..sort();
      final p15 = sorted[(sorted.length * 0.15).floor()];
      final p95 = sorted[(sorted.length * 0.95).floor()];
      final range = p95 - p15;

      final normalized = List<double>.filled(h * w, 0.0);
      if (range > 0.0001) {
        for (int i = 0; i < rawHeatmap.length; i++) {
          normalized[i] = ((rawHeatmap[i] - p15) / range).clamp(0.0, 1.0);
        }
      }

      return normalized;
    } catch (e) {
      debugPrint('Heatmap extraction error: $e');
      return null;
    }
  }

  static List<double> _softmax(List<double> values) {
    final maxVal = values.reduce(math.max);
    final expVals = values.map((v) => math.exp(v - maxVal)).toList();
    final sumExp = expVals.reduce((a, b) => a + b);
    return expVals.map((v) => v / sumExp).toList();
  }

  static String get currentStatus => _statusMessage;
  static bool get isLoaded => _isLoaded;
}
