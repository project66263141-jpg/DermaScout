class DermaContractResult {
  final String classId;
  final String label;
  final String action;
  final int tier;
  final Map<String, double> probs;
  final double modelDoubt;
  final double imageDoubt;
  final bool blurry;
  final String status;
  final String heatmapPngBase64;
  final String? imagePath;
  final DateTime timestamp;

  DermaContractResult({
    required this.classId,
    required this.label,
    required this.action,
    required this.tier,
    required this.probs,
    required this.modelDoubt,
    required this.imageDoubt,
    required this.blurry,
    required this.status,
    required this.heatmapPngBase64,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory DermaContractResult.getPreset(String stateKey, {String? imagePath}) {
    switch (stateKey) {
      case 'red':
        return DermaContractResult(
          classId: 'cancer',
          label: 'Skin cancer',
          action: 'See a doctor soon.',
          tier: 3,
          probs: {'healthy': 0.02, 'mole': 0.11, 'precancer': 0.19, 'cancer': 0.68},
          modelDoubt: 0.14,
          imageDoubt: 0.31,
          blurry: false,
          status: 'ok',
          heatmapPngBase64: '',
          imagePath: imagePath,
        );
      case 'orange':
        return DermaContractResult(
          classId: 'precancer',
          label: 'Pre-cancerous',
          action: 'Get this checked within a few weeks.',
          tier: 2,
          probs: {'healthy': 0.02, 'mole': 0.09, 'precancer': 0.77, 'cancer': 0.12},
          modelDoubt: 0.19,
          imageDoubt: 0.16,
          blurry: false,
          status: 'ok',
          heatmapPngBase64: '',
          imagePath: imagePath,
        );
      case 'amber':
        return DermaContractResult(
          classId: 'mole',
          label: 'Benign mole',
          action: 'Likely harmless. Recheck in 3 months if it changes.',
          tier: 1,
          probs: {'healthy': 0.03, 'mole': 0.88, 'precancer': 0.06, 'cancer': 0.03},
          modelDoubt: 0.12,
          imageDoubt: 0.14,
          blurry: false,
          status: 'ok',
          heatmapPngBase64: '',
          imagePath: imagePath,
        );
      case 'grey':
        return DermaContractResult(
          classId: 'cancer',
          label: 'Uncertain',
          action: 'Cannot tell reliably. See a doctor, or retake the photo.',
          tier: 3,
          probs: {'healthy': 0.21, 'mole': 0.28, 'precancer': 0.24, 'cancer': 0.27},
          modelDoubt: 0.62,
          imageDoubt: 0.71,
          blurry: true,
          status: 'retake_photo',
          heatmapPngBase64: '',
          imagePath: imagePath,
        );
      case 'green':
      default:
        return DermaContractResult(
          classId: 'healthy',
          label: 'Healthy skin',
          action: 'Nothing detected. Recheck if something appears.',
          tier: 0,
          probs: {'healthy': 0.91, 'mole': 0.05, 'precancer': 0.03, 'cancer': 0.01},
          modelDoubt: 0.08,
          imageDoubt: 0.11,
          blurry: false,
          status: 'ok',
          heatmapPngBase64: '',
          imagePath: imagePath,
        );
    }
  }
}
