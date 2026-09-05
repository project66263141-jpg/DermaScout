import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';
import '../widgets/probability_bar.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  int _getTierForLabel(String? label) {
    switch (label?.toLowerCase()) {
      case 'healthy':
        return 0;
      case 'mole':
        return 1;
      case 'precancer':
        return 2;
      case 'cancer':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final history = appState.scanHistory;
    final lang = appState.currentLanguage;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalization.get(lang, 'history_title'),
              style: GoogleFonts.ibmPlexSerif(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
            Text(
              AppLocalization.get(lang, 'history_subtitle'),
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.inkSoft),
              tooltip: AppLocalization.get(lang, 'clear_history'),
              onPressed: () => appState.clearHistory(),
            ),
        ],
      ),
      body: SafeArea(
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: AppTheme.inkSoft,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalization.get(lang, 'no_scans'),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Photos you analyze will appear in this history log.',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  final analysis = record.analysis;
                  final modelResult = record.modelResult;
                  final topLabel = modelResult.topLabel ?? 'healthy';
                  final tier = _getTierForLabel(topLabel);
                  final tierColor = AppTheme.getTierColor(tier);
                  final tierWash = AppTheme.getTierWash(tier);
                  final diseaseInfo = AppLocalization.getDiseaseInfo(lang, topLabel);
                  final confidencePct = ((modelResult.confidence ?? 0.0) * 100).round();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showRecordDetails(context, record, lang),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image Thumbnail with Tier Color Border
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tierColor, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: File(record.imagePath).existsSync()
                                      ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                                      : Container(
                                          color: AppTheme.bg,
                                          child: const Icon(Icons.image, color: AppTheme.inkSoft),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Details Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Category Pill Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: tierWash,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: tierColor.withOpacity(0.4), width: 0.8),
                                        ),
                                        child: Text(
                                          diseaseInfo.categoryName,
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: tierColor,
                                          ),
                                        ),
                                      ),
                                      // Timestamp
                                      Text(
                                        '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: GoogleFonts.ibmPlexMono(
                                          fontSize: 11,
                                          color: AppTheme.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Medical Name
                                  Text(
                                    diseaseInfo.medicalName,
                                    style: GoogleFonts.ibmPlexSerif(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Confidence & Quality Subtitle
                                  Row(
                                    children: [
                                      Text(
                                        'Conf: $confidencePct%',
                                        style: GoogleFonts.ibmPlexMono(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.ink,
                                        ),
                                      ),
                                      Text(
                                        ' · ',
                                        style: GoogleFonts.ibmPlexSans(fontSize: 11.5, color: AppTheme.inkSoft),
                                      ),
                                      Icon(
                                        analysis.isBlurry ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                                        size: 13,
                                        color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        analysis.isBlurry ? 'Blurry' : 'Clear (${analysis.sharpnessScore.round()}%)',
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 11.5,
                                          color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppTheme.inkSoft,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showRecordDetails(BuildContext context, ScanRecord record, String lang) {
    final modelResult = record.modelResult;
    final topLabel = modelResult.topLabel ?? 'healthy';
    final diseaseInfo = AppLocalization.getDiseaseInfo(lang, topLabel);
    final tier = _getTierForLabel(topLabel);
    final tierColor = AppTheme.getTierColor(tier);
    final tierWash = AppTheme.getTierWash(tier);
    final probs = modelResult.labelProbabilities ?? {'healthy': 1.0};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Image preview & Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: File(record.imagePath).existsSync()
                            ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                            : Container(color: AppTheme.bg, child: const Icon(Icons.image)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tierWash,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: tierColor),
                            ),
                            child: Text(
                              diseaseInfo.categoryName,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tierColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            diseaseInfo.medicalName,
                            style: GoogleFonts.ibmPlexSerif(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${((modelResult.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.tealDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppTheme.line),
                const SizedBox(height: 10),
                // Description & Action
                Text(
                  'Clinical Summary',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  diseaseInfo.description,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    color: AppTheme.inkSoft,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tierWash.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: tierColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services_outlined, color: tierColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          diseaseInfo.actionText,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Probability breakdown
                Text(
                  AppLocalization.get(lang, 'probabilities'),
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...probs.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  final itemInfo = AppLocalization.getDiseaseInfo(lang, key);
                  final isTop = key == topLabel;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ProbabilityBar(
                      label: itemInfo.categoryName,
                      percentage: value,
                      barColor: isTop ? tierColor : AppTheme.inkSoft,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Quality stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Quality', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: AppTheme.inkSoft)),
                          const SizedBox(height: 2),
                          Text(
                            record.analysis.isBlurry ? 'Blurry' : 'Clear',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: record.analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Sharpness', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: AppTheme.inkSoft)),
                          const SizedBox(height: 2),
                          Text(
                            '${record.analysis.sharpnessScore.round()}%',
                            style: GoogleFonts.ibmPlexMono(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Lighting', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: AppTheme.inkSoft)),
                          const SizedBox(height: 2),
                          Text(
                            record.analysis.lightingStatus,
                            style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
