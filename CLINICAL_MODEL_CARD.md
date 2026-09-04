# Clinical Model Card 🩺

## Model Metadata

| Item | Details |
| :--- | :--- |
| **Model Name** | `dermascout_fp32` |
| **Architecture** | Convolutional Neural Network Feature Extractor |
| **Format** | ONNX 32-bit Floating Point (FP32) |
| **Asset Location** | `assets/models/dermascout_int8.onnx` |
| **Input Specification** | `[1, 3, 320, 320]` Float32 |
| **Outputs** | 1. `logits`: `[1, 4]`<br>2. `feature_map`: `[1, 1536, 10, 10]` |

---

## Target Classes & Categorization

| Class Index | Label | Medical Name | Clinical Category | Severity Tier |
| :---: | :--- | :--- | :--- | :--- |
| **0** | `mole` | **Melanocytic Nevus** | Benign Mole | Low Risk (Teal) |
| **1** | `cancer` | **Melanoma / Basal Cell Carcinoma** | Skin Cancer | High Risk (Red) |
| **2** | `precancer` | **Actinic Keratosis** | Pre-Cancerous Mark | Elevated Risk (Orange) |
| **3** | `healthy` | **Healthy Skin** | Normal Skin | Clear (Green) |

---

## Visual Explanability (Grad-CAM Feature Map)

The model exposes a secondary tensor `feature_map` of shape `[1, 1536, 10, 10]`. 
By averaging activations across the 1536 feature channels and applying percentile normalization, DermaScout renders an Explainable AI (XAI) thermal heatmap indicating the focal regions that influenced the model's prediction.
