# DermaScout Model Storage

Place your trained TensorFlow Lite model file (`dermascout_model.tflite`) or label file (`labels.txt`) in this folder:

Path: `assets/models/dermascout_model.tflite`

When your team completes training and drops the `.tflite` file here, the app's `ModelRunner` service will automatically detect and load it for offline on-device screening!
