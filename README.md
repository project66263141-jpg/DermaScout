# DermaScout

DermaScout is an offline-first mobile app designed for real-time skin lesion screening in low-resource environments. It runs an ONNX deep learning classification model directly on the smartphone, giving field workers, nurses, and local clinics instant diagnostic feedback and visual attention heatmaps without requiring internet connectivity or cloud servers.

## Overview

In many rural clinics and remote field settings, reliable internet access is unavailable, making cloud-based AI medical tools impractical. DermaScout solves this by embedding an optimized deep learning model directly inside a Flutter Android application via native C++ FFI bindings.

The application allows users to capture skin lesion images, automatically crops and formats the ROI (region of interest), runs local inference, and renders an explainable AI heatmap showing which regions of the lesion influenced the prediction.

## Key Capabilities

- **Offline Inference**: Executes an ONNX vision model locally using `onnxruntime` native bindings, running fully offline with low latency.
- **Disease Categorization**: Classifies lesions into four distinct categories:
  - Melanocytic Nevus (benign mole)
  - Actinic Keratosis (pre-cancerous mark)
  - Melanoma / Basal Cell Carcinoma (cancer)
  - Healthy Skin
- **Visual Attention Heatmap**: Computes channel-averaged feature activations from the model's bottleneck layer to overlay a thermal heatmap on top of the lesion image.
- **Tri-Lingual Interface**: Instant language switching between English, Hindi, and Kannada.
- **Field-Ready Design**: Simple quality check interface (clear vs. blurry warning), precise corner reticle framing, and straightforward user flows tailored for health workers in rural settings.

## Model Technical Summary

| Parameter | Specification |
| :--- | :--- |
| **Model Format** | ONNX 32-bit Floating Point (`dermascout_fp32`) |
| **Input Tensor** | `[1, 3, 320, 320]` (NCHW format, ImageNet normalized) |
| **Output Tensors** | 1. `logits`: `[1, 4]` classification vector<br>2. `feature_map`: `[1, 1536, 10, 10]` activation grid |
| **Heatmap Scaling** | Channel-wise mean reduction followed by percentile thresholding ($p_{15}$ to $p_{95}$) and bilinear scaling |

## Tech Stack

- **Framework**: Flutter 3.29 / Dart 3.7
- **Inference Engine**: ONNX Runtime 1.4.1 (C++ FFI)
- **State Management**: Provider
- **Image Preprocessing**: `image` package
- **UI & Typography**: Custom Flutter material design with IBM Plex typography

## Getting Started

### Prerequisites

- Flutter SDK (3.29 or newer)
- Android SDK (API level 24 / Android 7.0 minimum)
- An Android test device or emulator

### Installation and Running

1. Clone the repository:
   ```bash
   git clone https://github.com/project66263141-jpg/DermaScout.git
   cd DermaScout
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run on a connected Android device:
   ```bash
   flutter run --release
   ```

4. Build a standalone release APK:
   ```bash
   flutter build apk --release
   ```

## Disclaimer

DermaScout is a screening tool built to assist preliminary assessment in field environments. It is not a replacement for professional clinical judgment or formal dermatological biopsy. Any suspected malignant lesion should be referred to a qualified physician or dermatologist for evaluation.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
