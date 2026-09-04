# DermaScout 🩺🔍

> **Offline-First AI Skin Lesion Screening & Multi-Lingual Diagnostic Guidance Application**

![Flutter](https://img.shields.io/badge/Flutter-3.29-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![ONNX Runtime](https://img.shields.io/badge/ONNX_Runtime-1.4.1-00599C?style=for-the-badge&logo=onnx&logoColor=white)
![Offline First](https://img.shields.io/badge/Offline_AI-100%25-green?style=for-the-badge)
![Languages](https://img.shields.io/badge/Languages-English%20%7C%20Hindi%20%7C%20Kannada-orange?style=for-the-badge)

---

## 📌 Executive Summary

**DermaScout** is a specialized, offline-first mobile medical screening application designed to assist healthcare workers, field nurses, and individuals in rural or resource-constrained settings with rapid, on-device skin lesion screening.

By leveraging an optimized **32-bit FP32 ONNX deep learning model** running locally via ONNX Runtime, DermaScout delivers real-time AI classification and **Visual Attention Heatmaps (Grad-CAM)** without requiring any cloud server or internet connection.

---

## ✨ Key Features

- **⚡ 100% Offline Deep Learning Inference**: Uses local ONNX Runtime execution (`assets/models/dermascout_int8.onnx`) for instant, private screening.
- **🩺 Clinical Disease Classification**:
  - **Melanocytic Nevus** *(benign mole)*
  - **Actinic Keratosis** *(pre-cancerous mark)*
  - **Melanoma / Basal Cell Carcinoma** *(skin cancer)*
  - **Healthy Skin** *(normal skin)*
- **🔥 AI Focus Heatmap (Explainable AI)**: Visualizes feature activation maps directly over the photo and in a dedicated diagnostic preview card so users can inspect where the AI focused its attention.
- **🌐 Tri-Lingual Support**: One-tap instant language toggle across **English**, **Hindi (हिन्दी)**, and **Kannada (ಕನ್ನಡ)**.
- **🌾 Rural-Clinic UX**: Simplified image quality verification (Clear & Sharp vs. Blurry: Retake) designed specifically for field conditions without overwhelming users with complex technical metrics.
- **🎯 Precision Reticle Guidance**: Crisp orange framing reticle corners for centering lesions during photo capture.

---

## 📊 Model & Performance Overview

| Property | Specification |
| :--- | :--- |
| **Model Format** | ONNX 32-bit FP32 (`dermascout_fp32`) |
| **Input Shape** | `[1, 3, 320, 320]` (NCHW format) |
| **Normalization** | ImageNet Mean `[0.485, 0.456, 0.406]`, Std `[0.229, 0.224, 0.225]` |
| **Output Tensors** | 1. `logits` `[1, 4]`<br>2. `feature_map` `[1, 1536, 10, 10]` |
| **Heatmap Normalization**| Robust Percentile Scaling ($p_{15} \rightarrow p_{95}$) with border artifact suppression |

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.29 / Dart 3.7
- **AI Engine**: `onnxruntime` v1.4.1 (Native C++ FFI)
- **State Management**: `provider` v6.1.2
- **Image Processing**: `image` v4.9.2
- **Typography**: Google Fonts (IBM Plex Serif, IBM Plex Sans, IBM Plex Mono)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.29.0`
- Android Studio / VS Code with Flutter extension
- Android Device running Android 7.0+ (API 24+)

### Build & Run
```bash
# 1. Clone the repository
git clone https://github.com/project66263141-jpg/DermaScout.git
cd DermaScout

# 2. Install dependencies
flutter pub get

# 3. Analyze codebase
flutter analyze

# 4. Run on connected Android device
flutter run --release
```

### Build APK
```bash
flutter build apk --release
```

---

## ⚠️ Medical Disclaimer

> **IMPORTANT**: DermaScout is an offline AI-assisted screening tool intended solely for preliminary assessment and educational guidance. It **does NOT constitute a formal medical diagnosis**. Users must always consult a licensed medical doctor or certified dermatologist for professional clinical evaluation.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
