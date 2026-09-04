import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BrandHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;

  const BrandHeader({
    super.key,
    this.eyebrow,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomPaint(
                size: const Size(22, 22),
                painter: BrandBlotPainter(),
              ),
              const SizedBox(width: 8),
              Text(
                'DermaScout',
                style: GoogleFonts.ibmPlexSerif(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.tealDeep,
                ),
              ),
            ],
          ),
          if (eyebrow != null) ...[
            const SizedBox(height: 8),
            Text(
              eyebrow!,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                color: AppTheme.inkSoft,
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.ibmPlexSerif(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppTheme.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class BrandBlotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()..color = AppTheme.teal;
    final bloomPaint = Paint()..color = AppTheme.bloom;

    final pathTeal = Path()
      ..moveTo(size.width * 0.5, 0)
      ..cubicTo(size.width * 0.9, size.height * 0.25, size.width, size.height * 0.6, size.width * 0.5, size.height)
      ..cubicTo(0, size.height * 0.6, size.width * 0.1, size.height * 0.25, size.width * 0.5, 0);

    canvas.drawPath(pathTeal, tealPaint);

    final pathBloom = Path()
      ..addOval(Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.5, size.height * 0.5));

    canvas.drawPath(pathBloom, bloomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
