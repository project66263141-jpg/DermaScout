import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final history = appState.scanHistory;

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
              'Inspection Log',
              style: GoogleFonts.ibmPlexSerif(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
            Text(
              'History of quality checks in this session',
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
              tooltip: 'Clear Log',
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
                      Icons.history_outlined,
                      size: 48,
                      color: AppTheme.inkSoft,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Inspections Yet',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Photos you test will appear in this history list.',
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.line),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: File(record.imagePath).existsSync()
                                ? Image.file(File(record.imagePath), fit: BoxFit.cover)
                                : Container(
                                    color: AppTheme.bg,
                                    child: const Icon(Icons.image, color: AppTheme.inkSoft),
                                  ),
                          ),
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
                                    analysis.isBlurry ? 'FAIL (Blurry)' : 'PASS (Clear)',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: analysis.isBlurry ? AppTheme.tierRed : AppTheme.tierGreen,
                                    ),
                                  ),
                                  Text(
                                    '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.ibmPlexMono(
                                      fontSize: 11,
                                      color: AppTheme.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Variance: ${analysis.variance} · Sharpness: ${analysis.sharpnessScore.round()}%',
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 11.5,
                                  color: AppTheme.inkSoft,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Lighting: ${analysis.lightingStatus}',
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
                },
              ),
      ),
    );
  }
}
