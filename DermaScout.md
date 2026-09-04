# DermaScout
## AI-Based Transformer for Real-Time Skin Disease Classification

> **Project status:** Research / prototype implementation  
> **Primary environment:** Google Colab + Python  
> **Core framework:** PyTorch + `timm`  
> **Deployment target:** ONNX / ONNX Runtime  
> **Input:** Skin image  
> **Output:** 4-class prediction + confidence information + visual explanation + decision state

---

# 1. Project Overview

**DermaScout** is an AI-assisted skin-image classification system intended to classify a photographed skin lesion into one of four high-level categories:

1. `healthy`
2. `mole`
3. `precancer`
4. `cancer`

The current prototype uses image data from two datasets:

- **HAM10000**
- **PAD-UFES-20**

The project deliberately combines these datasets because they provide different image characteristics and acquisition conditions.

The current notebook performs the following major operations:

```text
Dataset Acquisition
        ↓
Dataset Extraction
        ↓
Dataset Integrity / Data Gate
        ↓
Healthy-Skin Candidate Generation
        ↓
Healthy-Skin Quality Filtering
        ↓
Model Definition
        ↓
ONNX Export
        ↓
PyTorch ↔ ONNX Parity Validation
        ↓
CAM / Feature Map Generation
        ↓
Prediction-State Contract
        ↓
Evaluation
```

The implementation is contained in:

```text
Mark1.ipynb
```

The notebook is currently organized into eight logical cells.

---

# 2. IMPORTANT INSTRUCTIONS FOR AI CODING AGENTS

This README is intended to act as the **engineering specification** for future AI coding agents.

Agents modifying this project MUST follow these rules.

## 2.1 Do not invent the existing architecture

The currently implemented model is:

```text
DermaScoutNet
    └── timm backbone
          ├── feature map
          └── global average pooling
                ↓
             Dropout
                ↓
             Linear classifier
                ↓
       4 class logits
```

Do not silently replace this architecture with:

- ResNet
- VGG
- DenseNet
- ViT
- arbitrary CNN
- arbitrary Transformer
- another classifier

unless explicitly instructed.

The notebook currently instantiates:

```python
DermaScoutNet(
    backbone='efficientnet_b0',
    n_classes=4,
    pretrained=True
)
```

and also validates:

```text
efficientnet_b0
swin_tiny_patch4_window7_224
```

during ONNX export testing.

---

## 2.2 Preserve the four-class ontology

The canonical class order is:

```python
K = [
    'healthy',
    'mole',
    'precancer',
    'cancer'
]
```

The numeric mapping is:

```text
0 → healthy
1 → mole
2 → precancer
3 → cancer
```

This mapping is critical.

Never change class ordering without updating:

- model output interpretation
- JSON contract
- evaluation
- confusion matrix
- UI
- inference code
- ONNX consumers
- documentation

A model returning:

```text
[0, 1, 2, 3]
```

must always mean:

```text
healthy
mole
precancer
cancer
```

---

# 3. Current Implementation Status

## Implemented

The notebook currently implements:

- Google Drive integration
- Kaggle authentication
- dataset directory creation
- HAM10000 download/archive handling
- PAD-UFES-20 archive validation
- nested ZIP extraction
- image flattening
- duplicate handling
- metadata extraction
- dataset integrity checks
- expected class-count validation
- missing-image validation
- null-key validation
- healthy-image generation from PAD-UFES-20 image corners
- skin-fraction filtering
- ink/tattoo filtering
- dark-region filtering
- manual visual inspection of generated healthy crops
- `DermaScoutNet`
- EfficientNet-B0 backbone support
- Swin Tiny backbone support
- feature-map output
- classifier logits output
- ONNX export
- ONNX model validation
- PyTorch/ONNX numerical parity checking
- CAM calculation
- prediction-state JSON contract
- classification-report evaluation
- confusion matrix generation
- cancer sensitivity calculation
- cancer-missed-as-benign calculation

The evaluation helper is defined around:

```python
classification_report
confusion_matrix
recall_score
```

and specifically reports cancer sensitivity and the number of cancer examples predicted as benign.

---

# 4. Current Repository / Storage Structure

The notebook expects the following Google Drive structure:

```text
MyDrive/
└── DermaScout/
    ├── data/
    │   ├── raw/
    │   │   ├── ham10000.zip
    │   │   └── pad_ufes_20.zip
    │   │
    │   └── interim/
    │       ├── ham_metadata.csv
    │       ├── pad_metadata.csv
    │       └── healthy_pad_crops.csv
    │
    ├── splits/
    │
    ├── checkpoints/
    │   ├── dummy_efficientnet_b0.onnx
    │   └── dummy_swin_tiny_patch4_window7_224.onnx
    │
    └── results/
        └── contract/
            ├── state_green.json
            ├── state_amber.json
            ├── state_orange.json
            ├── state_red.json
            └── state_grey.json
```

Local temporary data is stored under:

```text
/content/data/
```

with:

```text
/content/data/ham/images
/content/data/pad/images
/content/data/healthy
```

These paths are defined directly in the notebook.

---

# 5. Environment

The prototype is designed for Google Colab.

The notebook mounts:

```python
from google.colab import drive

drive.mount('/content/drive')
```

The required Python packages include:

```text
kagglehub
timm
onnx
onnxruntime
onnxscript
torch
numpy
pandas
opencv-python
matplotlib
scikit-learn
```

The notebook installs the first group with:

```bash
pip install -q kagglehub timm onnx onnxruntime onnxscript
```

The runtime automatically selects:

```python
DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
```

Worker count is currently:

```python
NUM_WORKERS = 2  # CPU
NUM_WORKERS = 4  # CUDA
```

The notebook also configures PyTorch to use all detected CPU threads.

---

# 6. Dataset Sources

## 6.1 HAM10000

The project uses the Kaggle dataset:

```text
kmader/skin-cancer-mnist-ham10000
```

The archive is stored as:

```text
DermaScout/data/raw/ham10000.zip
```

The expected image count is:

```text
10,015 JPG images
```

The notebook reads:

```text
HAM10000_metadata.csv
```

The metadata column used for diagnosis is:

```text
dx
```

---

# 7. HAM10000 Class Distribution

The notebook expects these original HAM10000 counts:

```text
nv       6705
mel      1113
bkl      1099
bcc       514
akiec     327
vasc      142
df        115
```

However, only four diagnostic categories are retained for the project's trainable disease taxonomy.

The selected HAM10000 diagnoses are:

```python
[
    'nv',
    'akiec',
    'mel',
    'bcc'
]
```

The notebook expects:

```text
HAM trainable records = 8,659
```

This is explicitly validated by the data gate.

---

# 8. HAM10000 → Four-Class Mapping

The intended high-level mapping is:

| Project class | HAM10000 diagnosis |
|---|---|
| `mole` | `nv` |
| `precancer` | `akiec` |
| `cancer` | `mel`, `bcc` |
| `healthy` | not directly available |

Therefore:

```text
nv       → mole
akiec    → precancer
mel      → cancer
bcc      → cancer
```

Important:

HAM10000 does **not** directly provide a normal/healthy class suitable for this four-class formulation.

The healthy class is therefore constructed separately from PAD-UFES-20 image regions.

---

# 9. PAD-UFES-20

PAD-UFES-20 is stored as:

```text
DermaScout/data/raw/pad_ufes_20.zip
```

The notebook expects:

```text
2,298 PNG images
```

and reads:

```text
metadata.csv
```

The relevant metadata fields include:

```text
img_id
patient_id
diagnostic
```

The selected diagnostic categories are:

```python
[
    'NEV',
    'ACK',
    'MEL',
    'BCC'
]
```

The expected counts are:

```text
BCC = 845
ACK = 730
NEV = 244
SCC = 192
MEL = 52
SEK = 235
```

The selected trainable records are:

```text
1,871
```

This is validated by the notebook's data gate.

---

# 10. Dataset Integrity Gate

Before any downstream processing, the dataset must pass the integrity gate.

The following conditions are required.

## HAM10000

```text
10,015 images
8,659 trainable records
0 missing referenced images
0 fake-null lesion IDs
unique image IDs
expected class distribution
```

## PAD-UFES-20

```text
2,298 images
1,871 selected records
0 missing referenced images
0 fake-null patient IDs
unique image IDs
expected diagnostic distribution
```

The notebook prints:

```text
GATE: PASS
```

when all checks succeed.

The current execution produced:

```text
ham jpgs: 10015
pad pngs: 2298

HAM 10015 rows / 7470 lesions
PAD 2298 rows / 1373 patients

trainable:
HAM 8659
PAD 1871

missing images: 0/0
fake-null keys: 0
ids unique: True

GATE: PASS
```



### Agent requirement

Never proceed silently when:

```text
GATE = FAIL
```

The pipeline should stop with an actionable error.

---

# 11. Data Extraction

The notebook supports nested ZIP archives.

The extraction helper:

```python
def unzip_nested(src, dest):
    ...
```

extracts the main ZIP and then searches for nested ZIP files.

Nested archives are extracted and subsequently deleted.

---

# 12. Image Flattening

Dataset images may be nested in directories.

The `flatten()` function:

1. recursively finds images
2. moves them into the expected image directory
3. removes duplicate copies
4. removes empty directories

The target directories are:

```text
/content/data/ham/images
/content/data/pad/images
```

Do not modify the filename semantics because metadata references these filenames.

---

# 13. Healthy Class Construction

A major part of the current implementation is the generation of synthetic/derived healthy-skin samples.

The notebook does **not** simply label entire PAD-UFES-20 images as healthy.

Instead, it extracts candidate crops from image corners.

This is important.

The goal is:

```text
PAD image
   ↓
four corner candidates
   ↓
quality scoring
   ↓
select best candidate
   ↓
skin / ink / dark-region filtering
   ↓
224 × 224 healthy crop
```

---

# 14. Skin Fraction

The notebook uses YCrCb color space.

```python
_, cr, cb = cv2.split(
    cv2.cvtColor(b, cv2.COLOR_BGR2YCrCb)
)
```

A pixel is considered part of the skin region when:

```text
133 <= Cr <= 173
77  <= Cb <= 127
```

The skin fraction is:

```python
mask.mean()
```

This becomes the crop's `skin` score.

---

# 15. Crop Quality Filtering

The candidate crop must satisfy basic image-quality requirements.

Rejected when:

```text
mean grayscale < 40
OR
mean grayscale > 240
OR
grayscale standard deviation < 5
```

These conditions attempt to reject:

- extremely dark images
- extremely bright images
- nearly uniform regions

---

# 16. Corner Crop Selection

For each PAD image, the implementation examines:

```text
top-left
top-right
bottom-left
bottom-right
```

The crop size is:

```python
s = min(224, min(H, W) // 3)
```

A margin of:

```python
m = 0.04 * min(H, W)
```

is used.

The corner having the highest quality/skin score is selected.

---

# 17. Healthy Crop Acceptance Rules

A selected crop is rejected when:

```text
skin fraction < 0.80
```

It is also rejected when:

```text
ink score >= 0.005
```

or:

```text
dark blob score >= 0.015
```

Therefore, the healthy-class generation pipeline is intentionally conservative.

The current execution produced:

```text
2,298 source PAD images

1,128 healthy crops kept

209 rejected because of low skin fraction
63 rejected because of ink
811 rejected because of dark blob

803 patients represented
0 UNKNOWN patient IDs
```



---

# 18. Healthy Crop Metadata

Every accepted crop generates a record similar to:

```json
{
  "path": "healthy/<filename>.jpg",
  "class4": 0,
  "group_key": "pad_<patient_id>",
  "source": "pad_crop",
  "domain": "smartphone",
  "skin": 0.85,
  "ink": 0.001,
  "dark": 0.005
}
```

The metadata file is:

```text
data/interim/healthy_pad_crops.csv
```

The `group_key` is critical because it allows patient-level grouping.

Never randomly split healthy crops without considering the source patient.

---

# 19. Visual Quality Inspection

The notebook samples up to 16 generated healthy crops:

```python
picks = crops.sample(
    min(16, len(crops)),
    random_state=0
)
```

and displays them in a:

```text
4 × 4
```

grid.

This is a human sanity check.

Agents should preserve an equivalent visual inspection stage when modifying healthy-class generation.

Automated filtering alone should not be assumed to prove that every generated crop is genuinely healthy skin.

---

# 20. Model Architecture

The current model is:

```python
class DermaScoutNet(nn.Module):
```

with configurable:

```text
backbone
number of classes
pretrained weights
```

Default:

```text
backbone = efficientnet_b0
n_classes = 4
pretrained = True
```

---

# 21. Backbone

The backbone is created through `timm`:

```python
timm.create_model(
    backbone,
    pretrained=pretrained,
    num_classes=0,
    global_pool=''
)
```

This means the classification head is removed from the backbone.

The model uses the backbone's feature representation directly.

---

# 22. Feature Map

The model explicitly retains the spatial feature map.

The feature map can be returned in either:

```text
N × C × H × W
```

or converted from another layout when required.

For EfficientNet-B0, the current test produces:

```text
n_feat = 1280
feature map = 1 × 1280 × 7 × 7
```

The notebook reports approximately:

```text
4,012,672 trainable parameters
```



---

# 23. Classification Head

After the feature map:

```text
Global Average Pooling
        ↓
Dropout(0.3)
        ↓
Linear(n_feat → 4)
```

The dropout probability is:

```text
0.3
```

The final output is:

```text
4 logits
```

plus the feature map.

---

# 24. Model Output Contract

The model's forward method returns:

```python
logits, feature_map
```

Therefore:

```python
logits.shape
```

should be:

```text
batch × 4
```

and:

```python
feature_map
```

contains spatial feature information.

This second output is required for explainability.

Do not simplify the model to return logits only unless explicitly requested.

---

# 25. Why Two Outputs Exist

The two-output architecture exists for two purposes.

### Output 1 — logits

Used for:

- classification
- softmax probabilities
- confidence
- class selection
- evaluation

### Output 2 — feature map

Used for:

- CAM
- visual explanation
- localization of influential image regions
- debugging model behavior

---

# 26. Supported Backbones

The notebook currently tests:

```text
efficientnet_b0
swin_tiny_patch4_window7_224
```

EfficientNet-B0 is currently used for CAM generation and is the default model.

The ONNX validation results recorded in the notebook are:

```text
efficientnet_b0
size: 16.0 MB
max difference: 2.93e-05
PASS

swin_tiny_patch4_window7_224
size: 112.9 MB
max difference: 6.38e-06
PASS
```



---

# 27. ONNX Deployment

The model is exported to ONNX with:

```text
opset = 18
```

Input name:

```text
image
```

Outputs:

```text
logits
feature_map
```

Dynamic batch dimensions are configured for:

```text
image
logits
feature_map
```

This allows inference with different batch sizes.

---

# 28. ONNX Runtime

The notebook validates the exported model using:

```python
onnxruntime.InferenceSession(
    path,
    providers=['CPUExecutionProvider']
)
```

The ONNX model must be executable through ONNX Runtime.

---

# 29. PyTorch ↔ ONNX Parity Requirement

Every exported model must be compared against the original PyTorch model.

The current validation calculates:

```python
max(
    abs(
        pytorch_output - onnx_output
    )
)
```

The acceptance threshold is:

```text
difference < 1e-3
```

and model size must be:

```text
> 5 MB
```

A model failing parity must not be considered deployment-ready.

---

# 30. Important ONNX Warning

The current notebook produces warnings because it uses the legacy:

```python
torch.onnx.export(...)
```

path.

It also produces a tracer warning around conditional feature-map handling.

This means future agents may improve the exporter, but must preserve:

```text
input name = image
output names = logits, feature_map
opset compatibility
PyTorch/ONNX numerical parity
```

Any exporter rewrite must rerun parity validation.

---

# 31. CAM / Explainability

The model's feature map is used to generate a Class Activation Map.

The classifier weights:

```python
model.fc.weight
```

are combined with the feature-map channels.

The current implementation effectively computes:

```text
CAM = weighted sum of feature-map channels
```

for the predicted class.

The CAM is then normalized:

```text
0 → minimum activation
1 → maximum activation
```

The current EfficientNet-B0 CAM has shape:

```text
7 × 7
```

and is checked to ensure it is not degenerate.

---

# 32. Explainability Requirement

The production system should expose the heatmap to the frontend.

The intended flow is:

```text
input image
      ↓
model
      ↓
prediction
      ↓
feature map
      ↓
CAM
      ↓
resize to image dimensions
      ↓
overlay
      ↓
frontend
```

The user should be able to see approximately **where the model focused**, not merely the predicted class.

Important:

A heatmap is an explanation of model behavior, not proof of disease.

---

# 33. Prediction State Contract

The notebook defines five UI/application states:

```text
green
amber
orange
red
grey
```

These are stored under:

```text
results/contract/
```

as JSON files.

---

# 34. Green State

Meaning:

```text
healthy
```

Label:

```text
Healthy skin
```

Action:

```text
Nothing detected. Recheck if something appears.
```

Tier:

```text
0
```

Image doubt:

```text
0.11
```

Model doubt:

```text
0.08
```

Status:

```text
ok
```

---

# 35. Amber State

Meaning:

```text
mole
```

Label:

```text
Benign mole
```

Action:

```text
Likely harmless. Recheck in 3 months if it changes.
```

Tier:

```text
1
```

Status:

```text
ok
```

---

# 36. Orange State

Meaning:

```text
precancer
```

Label:

```text
Pre-cancerous
```

Action:

```text
Get this checked within a few weeks.
```

Tier:

```text
2
```

Status:

```text
ok
```

---

# 37. Red State

Meaning:

```text
cancer
```

Label:

```text
Skin cancer
```

Action:

```text
See a doctor soon.
```

Tier:

```text
3
```

Status:

```text
ok
```

---

# 38. Grey / Uncertain State

The grey state represents model uncertainty.

Its semantic class remains:

```text
cancer
```

but the user-facing label is:

```text
Uncertain
```

Action:

```text
Cannot tell reliably. See a doctor, or retake the photo.
```

It additionally has:

```text
image_doubt = 0.71
blurry = true
status = ok
```

and:

```text
image_doubt flag = retake_photo
```

The exact state values are encoded in the notebook and must remain synchronized with any frontend implementation.

---

# 39. State JSON Schema

Each state JSON follows approximately:

```json
{
  "class": "healthy",
  "label": "Healthy skin",
  "action": "Nothing detected. Recheck if something appears.",
  "tier": 0,
  "probs": {
    "healthy": 0.91,
    "mole": 0.05,
    "precancer": 0.03,
    "cancer": 0.01
  },
  "model_doubt": 0.08,
  "image_doubt": 0.11,
  "blurry": false,
  "status": "ok",
  "heatmap_png_base64": ""
}
```

The heatmap field currently exists as:

```text
heatmap_png_base64
```

but is initially empty in the generated state contract.

Future inference code is responsible for populating it.

---

# 40. Probability Contract

Probabilities must always correspond to:

```text
healthy
mole
precancer
cancer
```

in that exact order.

For example:

```python
probs = softmax(logits)
```

must result in:

```python
{
    "healthy": probs[0],
    "mole": probs[1],
    "precancer": probs[2],
    "cancer": probs[3]
}
```

Never reorder these fields.

---

# 41. Inference Pipeline — Required Design

The production inference pipeline should follow:

```text
Image Upload
    ↓
Image Decode
    ↓
Image Validation
    ↓
Quality Assessment
    ↓
Preprocessing
    ↓
ONNX Runtime
    ↓
Logits
    ↓
Softmax
    ↓
4-Class Probability Vector
    ↓
Uncertainty / Image Quality Decision
    ↓
State Selection
    ↓
CAM
    ↓
JSON Response
```

---

# 42. Image Validation

The production application should reject or flag:

- unreadable files
- unsupported formats
- empty images
- extremely small images
- severely blurred images
- extremely dark images
- extremely bright images
- images containing no meaningful skin region

The current notebook has image-quality heuristics for healthy-crop construction.

Do not assume those heuristics are automatically sufficient for production inference.

---

# 43. Preprocessing

The model expects:

```text
3-channel image
224 × 224
```

The notebook's dummy model input is:

```python
torch.randn(
    1,
    3,
    224,
    224
)
```

and test batches use:

```text
3 × 3 × 224 × 224
```

The production preprocessing pipeline must therefore guarantee:

```text
H = 224
W = 224
C = 3
```

and use the same normalization expected by the backbone's pretrained weights.

Do not change preprocessing between training and inference.

---

# 44. Evaluation

The evaluation helper uses:

```python
classification_report(...)
confusion_matrix(...)
recall_score(...)
```

with class names:

```python
[
    'healthy',
    'mole',
    'precancer',
    'cancer'
]
```

The evaluation output includes:

```text
precision
recall
f1-score
support
```

for each class.

---

# 45. Most Important Safety Metric

The notebook explicitly emphasizes:

```text
CANCER SENSITIVITY
```

and:

```text
cancer missed as benign
```

The latter is calculated as:

```python
((y == 3) & (p < 2)).sum()
```

This means:

```text
actual cancer
+
predicted healthy/mole
=
dangerous false-negative category
```

This metric is particularly important for this project.

A model with high overall accuracy but poor cancer sensitivity should **not** be considered successful.

---

# 46. Evaluation Philosophy

Do not optimize only for:

```text
accuracy
```

The system should prioritize:

1. cancer sensitivity
2. cancer false negatives
3. class-wise recall
4. class-wise precision
5. F1 score
6. confusion matrix
7. calibration / confidence
8. cross-domain performance

Overall accuracy can be reported but must not be the only success criterion.

---

# 47. Patient-Level Splitting Requirement

Both datasets contain multiple images/records associated with patients or lesions.

The metadata contains:

```text
HAM:
lesion_id

PAD:
patient_id
```

The notebook explicitly tracks these identifiers.

Future train/validation/test splitting MUST avoid leakage.

Do not perform a naïve random image-level split when multiple images from the same patient/lesion can occur.

Preferred principle:

```text
same patient/lesion
        ↓
must belong to only one split
```

For PAD-derived healthy crops, use:

```text
group_key
```

for grouping.

---

# 48. Domain Shift

The project combines:

```text
HAM10000
PAD-UFES-20
```

and therefore must account for domain differences.

The healthy crop metadata currently records:

```text
domain = smartphone
```

Future evaluation should ideally report performance separately for:

```text
HAM domain
PAD domain
healthy smartphone crops
combined validation/test set
```

Do not assume performance on one dataset automatically transfers to another.

---

# 49. Training Requirements for Future Agents

The current notebook defines the model and data preparation but does not contain a complete end-to-end training loop in the visible implementation.

Any coding agent implementing training should add:

```text
dataset class
augmentation pipeline
group-aware splitting
train DataLoader
validation DataLoader
loss function
optimizer
scheduler
mixed precision if available
checkpointing
early stopping
metric logging
validation
test evaluation
```

without changing the established class mapping.

---

# 50. Recommended Training Architecture

The training implementation should conceptually be:

```text
Prepared metadata
       ↓
Group-aware split
       ↓
Training Dataset
       ↓
Augmentation
       ↓
DermaScoutNet
       ↓
Loss
       ↓
Backpropagation
       ↓
Optimizer
       ↓
Validation
       ↓
Checkpoint
```

---

# 51. Class Imbalance

The source datasets are not balanced.

For example, HAM10000 contains substantially more `nv` samples than several other diagnostic categories.

Therefore, training should explicitly consider imbalance.

Possible approaches include:

```text
class-weighted loss
weighted sampler
balanced batch construction
targeted augmentation
```

Agents should evaluate the effect of imbalance-handling rather than blindly adding every technique.

---

# 52. Data Augmentation

Any augmentation must preserve medically meaningful visual characteristics.

Potentially acceptable image transformations include:

```text
small rotations
horizontal/vertical flips where appropriate
mild crop/resize
mild brightness variation
mild contrast variation
```

Avoid aggressive transformations that could destroy lesion morphology.

Do not introduce unrealistic transformations merely to increase dataset size.

---

# 53. Healthy Class Caution

The healthy class is derived from corners of lesion photographs.

This is a **weak-label / pseudo-label generation strategy**.

Therefore:

```text
healthy ≠ clinically verified healthy
```

The project must document this clearly.

Agents must not describe these samples as medically confirmed healthy cases.

---

# 54. Medical Safety

DermaScout is an AI classification prototype.

It must not claim:

```text
"This image proves cancer."
```

or:

```text
"You definitely have cancer."
```

Instead, predictions should be presented as:

```text
AI classification / risk indication
```

with appropriate clinical guidance.

The system should encourage professional evaluation for:

```text
cancer
precancer
uncertain
poor-quality images
```

---

# 55. Uncertainty Handling

The system has an explicit `grey` state.

Agents should preserve the distinction between:

```text
high-confidence prediction
```

and:

```text
uncertain prediction
```

Possible uncertainty signals include:

```text
prediction confidence
entropy
margin between top classes
image quality
blur
out-of-distribution indicators
```

Do not represent uncertainty merely by changing the color of the UI.

It must exist in the machine-readable output.

---

# 56. API / JSON Response Design

A production inference endpoint should return a structure conceptually similar to:

```json
{
  "class": "cancer",
  "label": "Skin cancer",
  "action": "See a doctor soon.",
  "tier": 3,
  "probs": {
    "healthy": 0.02,
    "mole": 0.11,
    "precancer": 0.19,
    "cancer": 0.68
  },
  "model_doubt": 0.14,
  "image_doubt": 0.31,
  "blurry": false,
  "status": "ok",
  "heatmap_png_base64": "<base64>"
}
```

The exact schema should remain backward compatible with the state contract.

---

# 57. Suggested Application Architecture

The final system can be separated into:

```text
dermascout/
│
├── backend/
│   ├── api/
│   ├── inference/
│   ├── preprocessing/
│   ├── models/
│   ├── explainability/
│   └── schemas/
│
├── frontend/
│
├── training/
│   ├── datasets/
│   ├── train.py
│   ├── evaluate.py
│   └── split.py
│
├── models/
│   └── onnx/
│
├── data/
│   ├── raw/
│   └── interim/
│
├── results/
│
├── tests/
│
├── Mark1.ipynb
├── requirements.txt
└── README.md
```

This is a recommended engineering organization, not an existing structure in the notebook.

Agents should not assume these directories already exist.

---

# 58. Suggested Backend Responsibilities

The backend should provide:

```text
POST /predict
```

Input:

```text
image
```

Output:

```text
prediction JSON
```

The backend should:

1. validate upload
2. decode image
3. preprocess
4. execute ONNX model
5. calculate probabilities
6. determine state
7. calculate CAM
8. encode heatmap
9. return JSON

---

# 59. Suggested Frontend Responsibilities

The frontend should show:

```text
uploaded image
+
predicted category
+
confidence/probability
+
visual heatmap
+
recommended action
+
uncertainty warning
```

The UI should not expose raw model internals unless useful.

The frontend must consume the canonical JSON contract instead of independently recreating classification logic.

---

# 60. Model Artifact Requirements

A deployment-ready model should contain:

```text
model.onnx
```

and optionally:

```text
model metadata
class mapping
preprocessing configuration
model version
training dataset version
```

Example:

```json
{
  "model": "DermaScoutNet",
  "backbone": "efficientnet_b0",
  "input_size": [224, 224],
  "classes": [
    "healthy",
    "mole",
    "precancer",
    "cancer"
  ],
  "onnx_opset": 18
}
```

---

# 61. Versioning

Every trained model should have a unique version.

Example:

```text
dermascout-efficientnetb0-v1.onnx
dermascout-efficientnetb0-v2.onnx
```

Never overwrite a validated model without recording the change.

---

# 62. Reproducibility

Training and evaluation should record:

```text
random seed
dataset version
dataset counts
split assignment
model backbone
pretrained status
input resolution
augmentation configuration
optimizer
learning rate
batch size
epochs
loss
best validation metric
test metrics
```

This information should be saved alongside checkpoints.

---

# 63. Testing Requirements

Every production implementation should have tests for:

## Dataset

```text
dataset integrity
missing files
duplicate IDs
null IDs
class mapping
```

## Model

```text
input shape
output shape
class ordering
feature-map shape
```

## ONNX

```text
model loads
input name = image
outputs exist
PyTorch/ONNX parity
```

## Inference

```text
valid image
invalid image
blurred image
dark image
bright image
unknown image
```

## Contract

Validate:

```text
class
label
action
tier
probs
model_doubt
image_doubt
blurry
status
heatmap_png_base64
```

---

# 64. Hard Invariants

AI coding agents MUST preserve these invariants.

### Invariant 1

```text
Number of classes = 4
```

### Invariant 2

```text
0 = healthy
1 = mole
2 = precancer
3 = cancer
```

### Invariant 3

```text
Model input = 3 × 224 × 224
```

### Invariant 4

```text
Model outputs = logits + feature_map
```

### Invariant 5

```text
ONNX input name = image
```

### Invariant 6

```text
ONNX outputs = logits, feature_map
```

### Invariant 7

```text
ONNX parity difference < 1e-3
```

### Invariant 8

```text
Data gate must pass before training
```

### Invariant 9

```text
No patient/lesion leakage across splits
```

### Invariant 10

```text
Cancer false negatives must be explicitly measured
```

---

# 65. Current Verified Dataset State

The attached notebook currently demonstrates:

```text
HAM10000 images:              10,015
PAD-UFES-20 images:            2,298

HAM trainable:                 8,659
PAD trainable:                 1,871

HAM lesions:                   7,470
PAD patients:                  1,373

Missing images:                    0
Fake-null identifiers:             0

Healthy crops generated:       1,128
Healthy source patients:         803
Unknown healthy patient IDs:       0
```

The data integrity gate passed. 
---

# 66. Current Verified Model State

The current EfficientNet-B0 prototype has:

```text
Backbone: EfficientNet-B0
Features: 1280
Feature map: 7 × 7
Classes: 4
Dropout: 0.3
Trainable parameters: 4,012,672
```

The notebook also verifies a Swin Tiny backbone.



---

# 67. Current ONNX Validation

Verified:

```text
EfficientNet-B0:
16.0 MB
max difference = 2.93e-05
PASS

Swin Tiny:
112.9 MB
max difference = 6.38e-06
PASS
```

CAM validation:

```text
CAM = 7 × 7
non-degenerate = True
```



---

# 68. What Is NOT Yet Fully Implemented

Agents must recognize that the notebook is not yet a complete production application.

The following pieces need implementation/integration if required:

```text
complete training pipeline
group-aware train/validation/test splitting
trained production checkpoint
full inference preprocessing
production ONNX model
uncertainty algorithm
real-time inference API
frontend
heatmap encoding pipeline
deployment configuration
automated test suite
model calibration
production monitoring
```

Do not falsely claim these are already present.

---

# 69. Recommended Development Order

AI coding agents should implement the system in this order:

```text
STEP 1
Dataset preparation
        ↓
STEP 2
Group-aware split
        ↓
STEP 3
Training pipeline
        ↓
STEP 4
Validation
        ↓
STEP 5
Cancer sensitivity analysis
        ↓
STEP 6
Best checkpoint selection
        ↓
STEP 7
ONNX export
        ↓
STEP 8
ONNX parity validation
        ↓
STEP 9
Inference preprocessing
        ↓
STEP 10
CAM generation
        ↓
STEP 11
Prediction-state engine
        ↓
STEP 12
API
        ↓
STEP 13
Frontend
        ↓
STEP 14
End-to-end testing
```

Do not start with the frontend and fake model responses.

---

# 70. Agent Workflow

When asked to modify this project, an AI coding agent should:

### Step 1 — Inspect

Read:

```text
README.md
Mark1.ipynb
existing source files
existing tests
```

### Step 2 — Identify

Determine:

```text
what already exists
what is missing
what contract must remain unchanged
```

### Step 3 — Implement

Make the smallest architecture-compatible change.

### Step 4 — Test

Run:

```text
unit tests
model tests
ONNX parity tests
contract tests
```

### Step 5 — Report

Return:

```text
files changed
features implemented
tests executed
tests passed
known limitations
```

---

# 71. Do Not Do These Things

AI coding agents must NOT:

- silently change class order
- remove the feature-map output
- replace EfficientNet with another architecture without instruction
- remove ONNX support
- remove cancer sensitivity evaluation
- perform patient-leaking random splits
- label all PAD images as healthy
- treat pseudo-healthy crops as medically verified healthy data
- fabricate model accuracy
- fabricate clinical validation
- fabricate a trained checkpoint
- claim the model diagnoses cancer
- remove uncertainty handling
- hard-code fake predictions in the production API
- change the JSON contract without updating all consumers
- silently alter dataset filtering thresholds
- delete dataset integrity checks

---

# 72. Engineering Principle

The most important principle of this project is:

> **Correctness and clinically relevant error analysis are more important than raw accuracy.**

In particular:

```text
Missing a cancer case
```

is substantially more important to investigate than:

```text
misclassifying one benign sample
```

Therefore every model iteration must report:

```text
Cancer sensitivity
Cancer false negatives
Confusion matrix
Per-class recall
Per-class precision
F1
```

---

# 73. Definition of Done

A DermaScout version should not be considered complete until:

- [ ] Dataset integrity gate passes
- [ ] No patient/lesion leakage exists
- [ ] Four-class mapping is verified
- [ ] Training is reproducible
- [ ] Validation metrics are recorded
- [ ] Cancer sensitivity is reported
- [ ] Cancer false negatives are reported
- [ ] Best checkpoint is saved
- [ ] ONNX export succeeds
- [ ] ONNX Runtime inference succeeds
- [ ] PyTorch/ONNX parity passes
- [ ] Feature map is available
- [ ] CAM is generated
- [ ] Prediction JSON matches the contract
- [ ] Uncertain images can enter grey state
- [ ] API returns real model inference
- [ ] Frontend displays real inference
- [ ] Automated tests pass
- [ ] Medical-safety wording is preserved
- [ ] No unsupported clinical claims are made

---

# 74. Final System Concept

The intended final product is:

```text
                    ┌──────────────────────┐
                    │      User Image      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Image Quality Check  │
                    └──────────┬───────────┘
                               │
                       acceptable?
                       /          \
                     NO            YES
                     │              │
                     ▼              ▼
                  GREY        Preprocessing
                                   │
                                   ▼
                         ┌──────────────────┐
                         │  DermaScoutNet   │
                         │ EfficientNet-B0  │
                         └────────┬─────────┘
                                  │
                     ┌────────────┴────────────┐
                     ▼                         ▼
                  Logits                  Feature Map
                     │                         │
                     ▼                         ▼
                Softmax                     CAM
                     │                         │
                     └────────────┬────────────┘
                                  ▼
                       ┌────────────────────┐
                       │ State Determinator │
                       └─────────┬──────────┘
                                 │
             ┌──────────┬────────┼────────┬──────────┐
             ▼          ▼        ▼        ▼          ▼
          HEALTHY     MOLE   PRECANCER  CANCER   UNCERTAIN
             │          │        │        │          │
             └──────────┴────────┴────────┴──────────┘
                                 │
                                 ▼
                        JSON/API Response
                                 │
                                 ▼
                              Frontend
                                 │
                                 ▼
                       Result + Heatmap +
                       Recommended Action
```

---

# 75. Source of Truth

The original implementation analyzed for this specification is:

```text
Mark1.ipynb
```

The notebook is the authoritative source for the **currently implemented behavior**.

This README describes:

1. what the notebook currently does,
2. the invariants that must be preserved,
3. the interfaces future code must respect,
4. and the engineering work required to turn the prototype into a complete application.

When this README and the implementation disagree:

```text
inspect the implementation first,
identify the discrepancy,
then explicitly update the specification.
```

Do not silently assume one is correct.

---

## End of DermaScout Engineering Specification