import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/blur_detector.dart';
import '../theme/app_theme.dart';

class QualityGateScreen extends StatelessWidget {
  final String? imagePath;

  const QualityGateScreen({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final path = imagePath ?? appState.currentImagePath;
    final analysis = appState.currentAnalysis;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Image Quality Inspection',
          style: GoogleFonts.ibmPlexSerif(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (path != null && File(path).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppTheme.inkSoft),
                  ),
                ),

              const SizedBox(height: 18),

              if (analysis != null) ...[
                // Quality Status Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: analysis.isBlurry ? AppTheme.tierRedWash : AppTheme.tierGreenWash,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        analysis.isBlurry ? Icons.warning_rounded : Icons.verified_rounded,
                        color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analysis.isBlurry ? 'Image Failed Blur Check' : 'Quality Passed',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              analysis.recommendation,
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
                ),

                const SizedBox(height: 18),

                // Detailed Technical Metrics
                Text(
                  'Technical Metrics',
                  style: GoogleFonts.ibmPlexSerif(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 10),

                _buildDetailRow('Blur Variance Score', '${analysis.variance}', 'Threshold: ${BlurDetector.defaultBlurThreshold.round()}'),
                _buildDetailRow('Sharpness Percentage', '${analysis.sharpnessScore}%', 'Scale: 0 to 100'),
                _buildDetailRow('Lighting Brightness', '${analysis.brightness} / 255', analysis.lightingStatus),
                _buildDetailRow('Uncertainty / Doubt Index', '${(analysis.doubtScore * 100).round()}%', analysis.isBlurry ? 'High' : 'Low'),
                _buildDetailRow('Dimensions', '${analysis.width} x ${analysis.height}', 'Pixels'),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.tealDeep),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, color: AppTheme.tealDeep),
                        label: Text(
                          'Retake / Re-test',
                          style: GoogleFonts.ibmPlexSans(
                            color: AppTheme.tealDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.tealDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                        label: Text(
                          'Accept Image',
                          style: GoogleFonts.ibmPlexSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String tag) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(fontSize: 13.5, color: AppTheme.ink),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.tealDeep,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.ibmPlexSans(fontSize: 11, color: AppTheme.inkSoft),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
