class AppLanguage {
  static const String english = 'en';
  static const String hindi = 'hi';
  static const String kannada = 'kn';
}

class DiseaseInfo {
  final String medicalName;
  final String categoryName;
  final String description;
  final String actionText;

  const DiseaseInfo({
    required this.medicalName,
    required this.categoryName,
    required this.description,
    required this.actionText,
  });
}

class AppLocalization {
  static const Map<String, Map<String, String>> _uiStrings = {
    'en': {
      'app_title': 'DermaScout',
      'app_subtitle': 'AI Camera & Skin Disease Inspector',
      'take_photo': 'Take Photo',
      'gallery': 'Gallery',
      'live_camera': 'Live Camera',
      'quality_ready': 'Quality Clear: Ready',
      'quality_ready_desc': 'Photo is clear and well-focused.',
      'quality_blur': 'Warning: Low Sharpness / Blurry',
      'quality_blur_desc': 'Hold camera steady and re-focus on the skin mark.',
      'focus_score': 'Focus & Sharpness Score',
      'framing_title': 'Center Framing Guidance',
      'framing_desc': 'Please position the skin mark or lesion directly inside the center target box before taking the photo.',
      'ai_result_title': 'AI Screening Result',
      'confidence': 'Confidence',
      'probabilities': 'Class Probability Breakdown',
      'disclaimer': '⚠ Screening tool only — not a medical diagnosis. Always consult a licensed dermatologist.',
      'heatmap_toggle': 'Toggle AI Focus Heatmap',
      'lang_select': 'Language',
      'audit_log': 'Analysis Log',
      'history_title': 'Analysis Log',
      'history_subtitle': 'History of AI disease analysis in this session',
      'no_scans': 'No analysis history recorded yet.',
      'clear_history': 'Clear Log',
    },
    'hi': {
      'app_title': 'डर्मास्काउट (DermaScout)',
      'app_subtitle': 'एआई कैमरा और त्वचा रोग निरीक्षक',
      'take_photo': 'फोटो लें',
      'gallery': 'गैलरी',
      'live_camera': 'लाइव कैमरा',
      'quality_ready': 'गुणवत्ता सही: तैयार',
      'quality_ready_desc': 'फोटो स्पष्ट और अच्छी तरह से केंद्रित है।',
      'quality_blur': 'चेतावनी: फोटो धुंधली है',
      'quality_blur_desc': 'कैमरा स्थिर रखें और त्वचा के निशान पर दोबारा फोकस करें।',
      'focus_score': 'फोकस और स्पष्टता स्कोर',
      'framing_title': 'सेंटर फ्रेमिंग मार्गदर्शन',
      'framing_desc': 'कृपया फोटो खींचने से पहले त्वचा के निशान को सीधे मध्य बॉक्स में रखें।',
      'ai_result_title': 'एआई स्क्रीनिंग परिणाम',
      'confidence': 'आत्मविश्वास (Confidence)',
      'probabilities': 'वर्ग संभावना विवरण (Probabilities)',
      'disclaimer': '⚠ केवल स्क्रीनिंग टूल — यह डॉक्टरी निदान नहीं है। हमेशा त्वचा विशेषज्ञ से सलाह लें।',
      'heatmap_toggle': 'एआई फोकस हीटमैप चालू/बंद',
      'lang_select': 'भाषा (Language)',
      'audit_log': 'विश्लेषण लॉग',
      'history_title': 'विश्लेषण लॉग',
      'history_subtitle': 'इस सत्र में एआई रोग विश्लेषण का इतिहास',
      'no_scans': 'अभी तक कोई विश्लेषण इतिहास रिकॉर्ड नहीं किया गया है।',
      'clear_history': 'इतिहास हटाएं',
    },
    'kn': {
      'app_title': 'ಡರ್ಮಾಸ್ಕೌಟ್ (DermaScout)',
      'app_subtitle': 'ಎಐ ಕ್ಯಾಮೆರಾ ಮತ್ತು ಚರ್ಮ ರೋಗ ಪರೀಕ್ಷಕ',
      'take_photo': 'ಫೋಟೋ ತೆಗೆಯಿರಿ',
      'gallery': 'ಗ್ಯಾಲರಿ',
      'live_camera': 'ಲೈವ್ ಕ್ಯಾಮೆರಾ',
      'quality_ready': 'ಗುಣಮಟ್ಟ ಸಿದ್ಧವಾಗಿದೆ',
      'quality_ready_desc': 'ಫೋಟೋ ಸ್ಪಷ್ಟವಾಗಿದೆ ಮತ್ತು ಸರಿಯಾಗಿ ಫೋಕಸ್ ಆಗಿದೆ.',
      'quality_blur': 'ಎಚ್ಚರಿಕೆ: ಫೋಟೋ ಮಸುಕಾಗಿದೆ',
      'quality_blur_desc': 'ಕ್ಯಾಮೆರಾವನ್ನು ಸ್ಥಿರವಾಗಿ ಹಿಡಿದು ಮಚ್ಚೆಯ ಮೇಲೆ ಮರು-ಫೋಕಸ್ ಮಾಡಿ.',
      'focus_score': 'ಫೋಕಸ್ ಮತ್ತು ಸ್ಪಷ್ಟತೆ ಸ್ಕೋರ್',
      'framing_title': 'ಫ್ರೇಮಿಂಗ್ ಮಾರ್ಗದರ್ಶನ',
      'framing_desc': 'ಫೋಟೋ ತೆಗೆಯುವ ಮೊದಲು ಚರ್ಮದ ಮಚ್ಚೆಯನ್ನು ಮಧ್ಯದ ಬಾಕ್ಸ್ ಒಳಗೆ ಇರಿಸಿ.',
      'ai_result_title': 'ಎಐ ತಪಾಸಣೆ ಫಲಿತಾಂಶ',
      'confidence': 'ವಿಶ್ವಾಸಾರ್ಹತೆ (Confidence)',
      'probabilities': 'ಸಾಧ್ಯತೆಗಳ ವಿವರಣೆ (Probabilities)',
      'disclaimer': '⚠ ಕೇವಲ ಪರೀಕ್ಷಾ ಸಾಧನ — ಇದು ವೈದ್ಯಕೀಯ ರೋಗನಿರ್ಣಯವಲ್ಲ. ಯಾವಾಗಲೂ ಚರ್ಮ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.',
      'heatmap_toggle': 'ಎಐ ಫೋಕಸ್ ಹೀಟ್‌ಮ್ಯಾಪ್ ಆನ್/ಆಫ್',
      'lang_select': 'ಭಾಷೆ (Language)',
      'audit_log': 'ವಿಶ್ಲೇಷಣೆ ಲಾಗ್',
      'history_title': 'ವಿಶ್ಲೇಷಣೆ ಲಾಗ್',
      'history_subtitle': 'ಈ ಅವಧಿಯ ಎಐ ರೋಗ ವಿಶ್ಲೇಷಣೆಯ ಇತಿಹಾಸ',
      'no_scans': 'ಇನ್ನೂ ಯಾವುದೇ ವಿಶ್ಲೇಷಣೆ ಇತಿಹಾಸ ದಾಖಲಾಗಿಲ್ಲ.',
      'clear_history': 'ಇತಿಹಾಸ ಅಳಿಸಿ',
    },
  };

  static const Map<String, Map<String, DiseaseInfo>> _diseaseData = {
    'en': {
      'healthy': DiseaseInfo(
        medicalName: 'Healthy skin',
        categoryName: 'Normal skin',
        description: 'Nothing found on this patch of skin.',
        actionText: 'No action needed. Recheck if something new appears.',
      ),
      'mole': DiseaseInfo(
        medicalName: 'Melanocytic nevus',
        categoryName: 'Ordinary mole',
        description: 'An ordinary mole. Not cancer.',
        actionText: 'Likely harmless. Recheck in 3 months if it changes.',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'Actinic keratosis',
        categoryName: 'Pre-cancerous',
        description: 'Sun-damaged skin that can turn into cancer if left alone.',
        actionText: 'Pre-cancerous. See a doctor within a few weeks.',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'Melanoma or basal cell carcinoma',
        categoryName: 'Skin cancer',
        description: 'Signs consistent with skin cancer.',
        actionText: 'See a doctor soon. Do not wait for it to change further.',
      ),
    },
    'hi': {
      'healthy': DiseaseInfo(
        medicalName: 'स्वस्थ त्वचा (Healthy skin)',
        categoryName: 'सामान्य त्वचा',
        description: 'त्वचा के इस हिस्से पर कुछ नहीं मिला।',
        actionText: 'किसी कार्रवाई की आवश्यकता नहीं है। यदि कुछ नया दिखाई दे तो मुरुजांच करें।',
      ),
      'mole': DiseaseInfo(
        medicalName: 'मेलानोसाइटिक नेवस (Melanocytic nevus)',
        categoryName: 'साधारण मस्सा',
        description: 'एक साधारण मस्सा। कैंसर नहीं।',
        actionText: 'संभवतः हानिरहित। 3 महीने में दोबारा जांचें यदि यह बदलता है।',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'एक्टिनिक केराटोसिस (Actinic keratosis)',
        categoryName: 'कैंसर-पूर्व',
        description: 'धूप से क्षतिग्रस्त त्वचा जो अकेले रहने पर कैंसर बन सकती है।',
        actionText: 'कैंसर-पूर्व। कुछ हफ्तों के भीतर डॉक्टर को दिखाएं।',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'मेलेनोमा या बेसल सेल कार्सिनोमा (Skin cancer)',
        categoryName: 'त्वचा का कैंसर',
        description: 'त्वचा कैंसर के अनुरूप लक्षण।',
        actionText: 'जल्द ही डॉक्टर को दिखाएं। इसके और बदलने का इंतजार न करें।',
      ),
    },
    'kn': {
      'healthy': DiseaseInfo(
        medicalName: 'ಆರೋಗ್ಯಕರ ಚರ್ಮ (Healthy skin)',
        categoryName: 'ಸಾಮಾನ್ಯ ಚರ್ಮ',
        description: 'ಚರ್ಮದ ಈ ಭಾಗದಲ್ಲಿ ಏನೂ ಕಂಡುಬಂದಿಲ್ಲ.',
        actionText: 'ಯಾವುದೇ ಕ್ರಮ ಅಗತ್ಯವಿಲ್ಲ. ಹೊಸದೇನಾದರೂ ಕಾಣಿಸಿಕೊಂಡರೆ ಮರುಪರಿಶೀಲಿಸಿ.',
      ),
      'mole': DiseaseInfo(
        medicalName: 'ಮೆಲನೋಸೈಟಿಕ್ ನೇವಸ್ (Melanocytic nevus)',
        categoryName: 'ಸಾಮಾನ್ಯ ಮಚ್ಚೆ',
        description: 'ಸಾಮಾನ್ಯ ಮಚ್ಚೆ. ಕ್ಯಾನ್ಸರ್ ಅಲ್ಲ.',
        actionText: 'ಸಾಮಾನ್ಯವಾಗಿ ಹಾನಿಯಿಲ್ಲ. ಬದಲಾದರೆ 3 ತಿಂಗಳಲ್ಲಿ ಮರುಪರಿಶೀಲಿಸಿ.',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'ಆಕ್ಟಿನಿಕ್ ಕೆರಾಟೋಸಿಸ್ (Actinic keratosis)',
        categoryName: 'ಕ್ಯಾನ್ಸರ್ ಮುನ್ನಾದಿ',
        description: 'ಬಿಸಿಲಿನಿಂದ ಉಂಟಾದ ಚರ್ಮ, ಇದು ಹಾಗೆಯೇ ಬಿಟ್ಟರೆ ಕ್ಯಾನ್ಸರ್ ಆಗಬಹುದು.',
        actionText: 'ಕ್ಯಾನ್ಸರ್ ಮುನ್ನಾದಿ. ಕೆಲವು ವಾರಗಳ ಒಳಗೆ ವೈದ್ಯರನ್ನು ಭೇಟಿಯಾಗಿ.',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'ಮೆಲನೋಮ ಅಥವಾ ಬೇಸಲ್ ಸೆಲ್ ಕಾರ್ಸಿನೋಮ (Skin cancer)',
        categoryName: 'ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್',
        description: 'ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್‌ಗೆ ಸೂಕ್ತವಾದ ಚಿಹ್ನೆಗಳು.',
        actionText: 'ತಕ್ಷಣ ವೈದ್ಯರನ್ನು ಭೇಟಿಯಾಗಿ. ಮತ್ತಷ್ಟು ಬದಲಾಗಲು ಕಾಯಬೇಡಿ.',
      ),
    },
  };

  static String get(String lang, String key) {
    final map = _uiStrings[lang] ?? _uiStrings['en']!;
    return map[key] ?? _uiStrings['en']![key] ?? key;
  }

  static DiseaseInfo getDiseaseInfo(
    String lang,
    String labelKey, {
    bool isEscalated = false,
    String? rawModelPickLabel,
    double cancerProb = 0.0,
    int cutoffPct = 35,
  }) {
    if (isEscalated) {
      final pickInfo = getDiseaseInfo(lang, rawModelPickLabel ?? 'mole');
      final int cancerPct = (cancerProb * 100).round();

      if (lang == 'hi') {
        return DiseaseInfo(
          medicalName: 'संभावित त्वचा कैंसर (Possible skin cancer)',
          categoryName: 'संभावित त्वचा कैंसर',
          description: 'निकटतम मिलान ${pickInfo.medicalName} था, लेकिन कैंसर का संकेत $cancerPct% तक पहुंच गया — हमारी $cutoffPct% सुरक्षा सीमा से ऊपर।',
          actionText: 'यह एक सावधानी है, निदान नहीं। पुष्टि के लिए डॉक्टर को दिखाएं।',
        );
      } else if (lang == 'kn') {
        return DiseaseInfo(
          medicalName: 'ಸಾಧ್ಯತೆಯ ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್ (Possible skin cancer)',
          categoryName: 'ಸಾಧ್ಯತೆಯ ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್',
          description: 'ಹತ್ತಿರದ ಹೊಂದಾಣಿಕೆ ${pickInfo.medicalName} ಆಗಿತ್ತು, ಆದರೆ ಕ್ಯಾನ್ಸರ್ ಸಿಗ್ನಲ್ $cancerPct% ಗೆ ತಲುಪಿದೆ — ನಮ್ಮ $cutoffPct% ಸುರಕ್ಷತಾ ಮಿತಿಗಿಂತ ಹೆಚ್ಚು.',
          actionText: 'ಇದು ಮುನ್ನೆಚ್ಚರಿಕೆ, ರೋಗನಿರ್ಣಯವಲ್ಲ. ಖಚಿತಪಡಿಸಲು ವೈದ್ಯರನ್ನು ಭೇಟಿಯಾಗಿ.',
        );
      } else {
        return DiseaseInfo(
          medicalName: 'Possible skin cancer',
          categoryName: 'Possible skin cancer',
          description: 'The closest match was ${pickInfo.medicalName}, but the cancer signal reached $cancerPct% — above our $cutoffPct% safety cutoff.',
          actionText: 'This is a precaution, not a diagnosis. See a doctor to confirm.',
        );
      }
    }

    final langMap = _diseaseData[lang] ?? _diseaseData['en']!;
    return langMap[labelKey.toLowerCase()] ??
        langMap['healthy'] ??
        const DiseaseInfo(
          medicalName: 'Healthy skin',
          categoryName: 'Normal skin',
          description: 'Nothing found on this patch of skin.',
          actionText: 'No action needed. Recheck if something new appears.',
        );
  }
}
