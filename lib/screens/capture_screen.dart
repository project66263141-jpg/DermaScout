import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/blur_detector.dart';
import '../services/localization.dart';
import '../services/model_runner.dart';
import '../theme/app_theme.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  bool _isExpanded = true; // Default to larger camera window for clear framing
  bool _showHeatmap = true; // Toggle heatmap overlay
  FlashMode _flashMode = FlashMode.off;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final backCamera = _cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();
        // Ensure flash mode defaults to off safely
        try {
          await _cameraController!.setFlashMode(_flashMode);
        } catch (_) {}

        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    }
  }

  Future<void> _cycleFlashMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    FlashMode next;
    if (_flashMode == FlashMode.off) {
      next = FlashMode.always;
    } else if (_flashMode == FlashMode.always) {
      next = FlashMode.torch;
    } else if (_flashMode == FlashMode.torch) {
      next = FlashMode.auto;
    } else {
      next = FlashMode.off;
    }

    try {
      await _cameraController!.setFlashMode(next);
      setState(() => _flashMode = next);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flash set to ${_flashModeLabel(next)}'),
            duration: const Duration(milliseconds: 900),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  String _flashModeLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
        return 'ON (Clear lighting)';
      case FlashMode.torch:
        return 'TORCH (Continuous light)';
      case FlashMode.auto:
        return 'AUTO';
      case FlashMode.off:
      default:
        return 'OFF';
    }
  }

  IconData _flashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
        return Icons.flash_on_rounded;
      case FlashMode.torch:
        return Icons.highlight_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.off:
      default:
        return Icons.flash_off_rounded;
    }
  }

  Color _flashColor(FlashMode mode) {
    switch (mode) {
      case FlashMode.always:
      case FlashMode.torch:
        return Colors.amberAccent;
      case FlashMode.auto:
        return Colors.lightBlueAccent;
      case FlashMode.off:
      default:
        return Colors.white70;
    }
  }

  Future<void> _captureFromLiveCamera() async {
    // Ensure expanded window when capturing
    if (!_isExpanded) {
      setState(() => _isExpanded = true);
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized || _isAnalyzing) {
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.analyzeFile(photo.path);
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isAnalyzing = true);
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (photo != null && mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.analyzeFile(photo.path);
      }
    } catch (e) {
      debugPrint('Error picking gallery image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _resetToLiveCamera() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.analyzeFile(''); // Clears current image to reveal live viewfinder
    setState(() => _isExpanded = true);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentPath = appState.currentImagePath;
    final hasCapturedPhoto = currentPath != null && File(currentPath).existsSync();
    final analysis = appState.currentAnalysis;

    // Viewfinder height: Large mode (460px) vs Compact (320px)
    final double viewfinderHeight = _isExpanded ? 460.0 : 320.0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // App Logo Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 36,
                  height: 36,
                  color: AppTheme.tealWash,
                  child: const Icon(Icons.medical_services_rounded, color: AppTheme.tealDeep, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalization.get(appState.currentLanguage, 'app_title'),
                    style: GoogleFonts.ibmPlexSerif(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalization.get(appState.currentLanguage, 'app_subtitle'),
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      color: AppTheme.inkSoft,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Multilingual Selector Chips
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.tealWash,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.tealDeep.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLangChip(context, appState, 'en', 'EN'),
                  _buildLangChip(context, appState, 'hi', 'हिन्दी'),
                  _buildLangChip(context, appState, 'kn', 'ಕನ್ನಡ'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Camera Viewfinder (Taller & expandable)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                height: viewfinderHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.tealDeep, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Layer 1: Captured Image OR Live Camera Preview
                      if (hasCapturedPhoto)
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(currentPath),
                              fit: BoxFit.cover,
                            ),
                            // Heatmap overlay if model result has one and toggled on
                            if (_showHeatmap && appState.currentModelResult?.heatmap != null)
                              _HeatmapOverlay(
                                heatmap: appState.currentModelResult!.heatmap!,
                              ),
                          ],
                        )
                      else if (_isCameraInitialized && _cameraController != null)
                        CameraPreview(_cameraController!)
                      else
                        Container(
                          color: const Color(0xFF162320),
                          child: const Center(
                            child: CircularProgressIndicator(color: AppTheme.tealDeep),
                          ),
                        ),

                      // Layer 2: 3x3 Grid Overlay (Grid lines hide after capture, keeping only the center square)
                      CameraGridOverlay(showGridLines: !hasCapturedPhoto),

                      // Layer 3: Top Floating Control Bar (Flash Mode, Expand, & Heatmap Toggle)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Expand / Collapse Size Button
                                InkWell(
                                  onTap: () {
                                    setState(() => _isExpanded = !_isExpanded);
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isExpanded ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _isExpanded ? 'Compact' : 'Large View',
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (hasCapturedPhoto && appState.currentModelResult?.heatmap != null) ...[
                                  const SizedBox(width: 6),
                                  // Heatmap Toggle Button
                                  InkWell(
                                    onTap: () {
                                      setState(() => _showHeatmap = !_showHeatmap);
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _showHeatmap
                                            ? Colors.deepOrange.withValues(alpha: 0.85)
                                            : Colors.black.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _showHeatmap ? Colors.amberAccent : Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.whatshot_rounded,
                                            size: 16,
                                            color: _showHeatmap ? Colors.amberAccent : Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _showHeatmap ? 'Heatmap ON' : 'Heatmap OFF',
                                            style: GoogleFonts.ibmPlexSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Flash Mode Toggle Button
                            InkWell(
                              onTap: _cycleFlashMode,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _flashMode == FlashMode.off ? Colors.white24 : Colors.amberAccent,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _flashIcon(_flashMode),
                                      size: 18,
                                      color: _flashColor(_flashMode),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _flashMode == FlashMode.always
                                          ? 'Flash ON'
                                          : _flashMode == FlashMode.torch
                                              ? 'Torch'
                                              : _flashMode == FlashMode.auto
                                                  ? 'Auto'
                                                  : 'Flash OFF',
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: _flashColor(_flashMode),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Layer 4: Status / Retake Banner (when a photo is currently shown)
                      if (hasCapturedPhoto)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            children: [
                              // Status pill
                              if (analysis != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          analysis.isBlurry
                                              ? Icons.warning_amber_rounded
                                              : Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: analysis.isBlurry ? Colors.amberAccent : Colors.greenAccent,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            analysis.isBlurry ? 'BLUR DETECTED' : 'CLEAR & SHARP',
                                            style: GoogleFonts.ibmPlexMono(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              // Switch back to live camera
                              ElevatedButton.icon(
                                onPressed: _resetToLiveCamera,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.bloom,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.videocam_rounded, size: 16),
                                label: Text(
                                  'Live Camera',
                                  style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Center Box Framing Guidance Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.paper,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.line),
                  boxShadow: const [
                    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.tealWash,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.center_focus_strong_rounded,
                        color: AppTheme.tealDeep,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Center Framing Guidance',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Please position the skin mark or lesion directly inside the center target box before taking the photo.',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              color: AppTheme.inkSoft,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Action Buttons: Take Photo (With Flash) & Gallery
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _captureFromLiveCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tealDeep,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.camera_alt_rounded, size: 22),
                      label: Text(
                        _flashMode != FlashMode.off ? 'Take Photo (Flash)' : 'Take Photo',
                        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : _pickFromGallery,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.tealDeep,
                        side: const BorderSide(color: AppTheme.tealDeep, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.photo_library_rounded, size: 20),
                      label: Text(
                        'Gallery',
                        style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quality Gate Analysis Card
              if (analysis != null) ...[
                _buildAnalysisCard(context, analysis),
                const SizedBox(height: 14),
              ],

              // AI Screening Result Card
              if (appState.currentModelResult != null)
                _buildDiagnosisCard(context, appState.currentModelResult!)
              else
                _buildModelStatusCard(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, BlurAnalysisResult analysis) {
    final bool isBlurry = analysis.isBlurry;
    final appState = Provider.of<AppState>(context, listen: false);
    final lang = appState.currentLanguage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isBlurry ? AppTheme.tierRedWash : AppTheme.tierGreenWash,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBlurry ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
              color: isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBlurry
                      ? AppLocalization.get(lang, 'quality_blur')
                      : AppLocalization.get(lang, 'quality_ready'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isBlurry
                      ? AppLocalization.get(lang, 'quality_blur_desc')
                      : AppLocalization.get(lang, 'quality_ready_desc'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12.5,
                    color: AppTheme.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStatusCard() {
    final isLoaded = ModelRunner.isLoaded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isLoaded ? AppTheme.tealWash : AppTheme.tierAmberWash,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLoaded ? Icons.memory_rounded : Icons.pending_actions_rounded,
              color: isLoaded ? AppTheme.tealDeep : AppTheme.tierAmber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoaded ? 'AI Screening Model Ready' : 'AI Model Loading…',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ModelRunner.currentStatus,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11.5,
                    color: AppTheme.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(
    BuildContext context,
    AppState appState,
    String langCode,
    String label,
  ) {
    final bool isSelected = appState.currentLanguage == langCode;
    return InkWell(
      onTap: () => appState.setLanguage(langCode),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tealDeep : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(BuildContext context, ModelInferenceResult result) {
    final appState = Provider.of<AppState>(context, listen: false);
    final lang = appState.currentLanguage;

    final String rawLabel = result.topLabel ?? '';
    final diseaseInfo = AppLocalization.getDiseaseInfo(lang, rawLabel);

    final Color cardColor;
    final Color borderColor;
    final IconData icon;

    if (!result.isModelLoaded) {
      cardColor = AppTheme.tierAmberWash;
      borderColor = AppTheme.tierAmber;
      icon = Icons.pending_actions_rounded;
    } else {
      switch (rawLabel) {
        case 'cancer':
          cardColor = AppTheme.tierRedWash;
          borderColor = AppTheme.tierRed;
          icon = Icons.warning_rounded;
          break;
        case 'precancer':
          cardColor = const Color(0xFFFFF3E0);
          borderColor = Colors.orange;
          icon = Icons.report_problem_outlined;
          break;
        case 'mole':
          cardColor = AppTheme.tealWash;
          borderColor = AppTheme.tealDeep;
          icon = Icons.radio_button_checked_rounded;
          break;
        case 'healthy':
        default:
          cardColor = AppTheme.tierGreenWash;
          borderColor = AppTheme.tierGreen;
          icon = Icons.verified_rounded;
      }
    }

    final conf = result.confidence;
    final confText = conf != null ? '${(conf * 100).toStringAsFixed(1)}%' : '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Icon(icon, color: borderColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalization.get(lang, 'ai_result_title'),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.inkSoft,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            diseaseInfo.categoryName,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: borderColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diseaseInfo.medicalName,
                      style: GoogleFonts.ibmPlexSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                    if (confText.isNotEmpty)
                      Text(
                        '${AppLocalization.get(lang, 'confidence')}: $confText',
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 12,
                          color: AppTheme.inkSoft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: borderColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diseaseInfo.description,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        diseaseInfo.actionText,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          color: AppTheme.ink,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (result.labelProbabilities != null) ...[
            const SizedBox(height: 14),
            Text(
              AppLocalization.get(lang, 'probabilities'),
              style: GoogleFonts.ibmPlexSans(
                fontSize: 11.5,
                color: AppTheme.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...result.labelProbabilities!.entries.map((e) {
              final String classKey = e.key;
              final classInfo = AppLocalization.getDiseaseInfo(lang, classKey);
              final pct = (e.value * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        classInfo.medicalName,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          color: borderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$pct%',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (result.heatmap != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.whatshot_rounded, color: Colors.deepOrangeAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'AI Focus Heatmap',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
                Text(
                  _showHeatmap ? 'Active on photo' : 'Hidden',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _showHeatmap ? Colors.deepOrangeAccent : AppTheme.inkSoft,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF162320),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrangeAccent.withValues(alpha: 0.4), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _HeatmapPainter(result.heatmap!),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            AppLocalization.get(lang, 'disclaimer'),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10.5,
              color: AppTheme.inkSoft,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Heatmap overlay drawn on top of the captured photo.
/// [heatmap] is a 10×10 list of normalised values (0.0–1.0).
class _HeatmapOverlay extends StatelessWidget {
  final List<double> heatmap;
  const _HeatmapOverlay({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _HeatmapPainter(heatmap),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<double> heatmap;
  _HeatmapPainter(this.heatmap);

  @override
  void paint(Canvas canvas, Size size) {
    const int cols = 10;
    const int rows = 10;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final val = heatmap[r * cols + c].clamp(0.0, 1.0);
        // Paint active focal spots (>= 0.15) with high-visibility thermal colors
        if (val < 0.15) continue;

        final norm = (val - 0.15) / 0.85;
        final color = _heatColor(norm).withValues(alpha: 0.35 + 0.40 * norm);
        final paint = Paint()..color = color;
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          paint,
        );
      }
    }
  }

  Color _heatColor(double t) {
    // Thermal spectrum: Bright Yellow → Vivid Orange → Deep Crimson Red
    if (t < 0.35) {
      return Color.lerp(const Color(0xFFFFEB3B), const Color(0xFFFF9800), t / 0.35)!;
    } else if (t < 0.70) {
      return Color.lerp(const Color(0xFFFF9800), const Color(0xFFFF3D00), (t - 0.35) / 0.35)!;
    } else {
      return Color.lerp(const Color(0xFFFF3D00), const Color(0xFFD50000), (t - 0.70) / 0.30)!;
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.heatmap != heatmap;
}


/// 3x3 Framing Grid & Center Box Highlight Widget
class CameraGridOverlay extends StatelessWidget {
  final bool showGridLines;

  const CameraGridOverlay({
    super.key,
    this.showGridLines = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showGridLines) ...[
          // 3x3 Grid Lines
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white24, width: 1)),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white24, width: 1)),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],

        // Center Box Reticle Highlight — ONLY Orange Corners (NO white line)
        Center(
          child: SizedBox(
            width: 175,
            height: 175,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, child: _buildCorner(top: true, left: true)),
                Positioned(top: 0, right: 0, child: _buildCorner(top: true, left: false)),
                Positioned(bottom: 0, left: 0, child: _buildCorner(top: false, left: true)),
                Positioned(bottom: 0, right: 0, child: _buildCorner(top: false, left: false)),
                Center(
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bloom,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: AppTheme.bloom, width: 3.5) : BorderSide.none,
          bottom: !top ? const BorderSide(color: AppTheme.bloom, width: 3.5) : BorderSide.none,
          left: left ? const BorderSide(color: AppTheme.bloom, width: 3.5) : BorderSide.none,
          right: !left ? const BorderSide(color: AppTheme.bloom, width: 3.5) : BorderSide.none,
        ),
      ),
    );
  }
}
