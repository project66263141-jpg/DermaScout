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
        medicalName: 'Healthy Skin',
        categoryName: 'Normal Skin',
        description: 'Normal healthy skin detected. No obvious pathological lesion found.',
        actionText: 'Keep monitoring your skin regularly. Recheck if anything appears.',
      ),
      'mole': DiseaseInfo(
        medicalName: 'Melanocytic Nevus',
        categoryName: 'Benign Mole',
        description: 'Common harmless pigmented skin mole.',
        actionText: 'Likely harmless. Recheck in 3 months or if size/shape changes.',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'Actinic Keratosis',
        categoryName: 'Pre-Cancerous Mark',
        description: 'Pre-cancerous sun-damaged skin lesion.',
        actionText: 'Consult a dermatologist within a few weeks for early preventive treatment.',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'Melanoma / Basal Cell Carcinoma',
        categoryName: 'Skin Cancer',
        description: 'Malignant or aggressive skin lesion detected.',
        actionText: 'Medical evaluation by a dermatologist strongly recommended soon.',
      ),
    },
    'hi': {
      'healthy': DiseaseInfo(
        medicalName: 'स्वस्थ त्वचा (Healthy Skin)',
        categoryName: 'सामान्य त्वचा',
        description: 'सामान्य स्वस्थ त्वचा पाई गई। कोई स्पष्ट बीमारी या निशान नहीं मिला।',
        actionText: 'अपनी त्वचा की नियमित निगरानी रखें। यदि कोई नया निशान दिखाई दे तो जांच कराएं।',
      ),
      'mole': DiseaseInfo(
        medicalName: 'मेलानोसाइटिक नेवस (Melanocytic Nevus)',
        categoryName: 'साधारण मस्सा (Benign Mole)',
        description: 'साधारण हानिरहित त्वचा का मस्सा/तिल।',
        actionText: 'संभवतः हानिरहित। 3 महीने में दोबारा जांचें या यदि आकार/रंग बदले तो डॉक्टर को दिखाएं।',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'एक्टिनिक केराटोसिस (Actinic Keratosis)',
        categoryName: 'कैंसर-पूर्व निशान (Pre-Cancerous)',
        description: 'धूप से क्षतिग्रस्त कैंसर-पूर्व त्वचा का निशान।',
        actionText: 'शुरुआती बचाव के लिए कुछ हफ्तों के भीतर त्वचा विशेषज्ञ से सलाह लें।',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'मेलेनोमा / बेसल सेल कार्सिनोमा (Skin Cancer)',
        categoryName: 'त्वचा का कैंसर (Skin Cancer)',
        description: 'संभावित त्वचा कैंसर या आक्रामक निशान का पता चला।',
        actionText: 'त्वचा रोग विशेषज्ञ से जल्द से जल्द डॉक्टरी जांच कराने की सख्त सिफारिश की जाती है।',
      ),
    },
    'kn': {
      'healthy': DiseaseInfo(
        medicalName: 'ಆರೋಗ್ಯಕರ ಚರ್ಮ (Healthy Skin)',
        categoryName: 'ಸಾಮಾನ್ಯ ಚರ್ಮ',
        description: 'ಸಾಮಾನ್ಯ ಆರೋಗ್ಯಕರ ಚರ್ಮ ಕಂಡುಬಂದಿದೆ. ಯಾವುದೇ ತೊಂದರೆ ಇಲ್ಲ.',
        actionText: 'ನಿಮ್ಮ ಚರ್ಮವನ್ನು ನಿಯಮಿತವಾಗಿ ಗಮನಿಸಿ. ಹೊಸ ಮಚ್ಚೆಗಳು ಕಂಡುಬಂದರೆ ಪರೀಕ್ಷಿಸಿ.',
      ),
      'mole': DiseaseInfo(
        medicalName: 'ಮೆಲನೋಸೈಟಿಕ್ ನೇವಸ್ (Melanocytic Nevus)',
        categoryName: 'ಸಾಮಾನ್ಯ ಮಚ್ಚೆ (Benign Mole)',
        description: 'ಹಾನಿಯಿಲ್ಲದ ಚರ್ಮದ ಸಾಮಾನ್ಯ ಮಚ್ಚೆ/ತಿಲಕ.',
        actionText: 'ಸಾಮಾನ್ಯವಾಗಿ ಹಾನಿಯಿಲ್ಲ. 3 ತಿಂಗಳಲ್ಲಿ ಮರುಪರಿಶೀಲಿಸಿ ಅಥವಾ ಗಾತ್ರ/ಬಣ್ಣ ಬದಲಾದರೆ ವೈದ್ಯರನ್ನು ಭೇಟಿಯಾಗಿ.',
      ),
      'precancer': DiseaseInfo(
        medicalName: 'ಆಕ್ಟಿನಿಕ್ ಕೆರಾಟೋಸಿಸ್ (Actinic Keratosis)',
        categoryName: 'ಕ್ಯಾನ್ಸರ್ ಮುನ್ನಾದಿ ಮಚ್ಚೆ (Pre-Cancerous)',
        description: 'ಬಿಸಿಲಿನಿಂದ ಉಂಟಾದ ಕ್ಯಾನ್ಸರ್‌ಗೆ ಕಾರಣವಾಗಬಹುದಾದ ಚರ್ಮದ ಮಚ್ಚೆ.',
        actionText: 'ಆರಂಭಿಕ ಚಿಕಿತ್ಸೆಗಾಗಿ ಕೆಲವು ವಾರಗಳ ಒಳಗೆ ಚರ್ಮ ವೈದ್ಯರನ್ನು ಸಂಪರ್ಕಿಸಿ.',
      ),
      'cancer': DiseaseInfo(
        medicalName: 'ಮೆಲನೋಮ / ಬೇಸಲ್ ಸೆಲ್ ಕಾರ್ಸಿನೋಮ (Skin Cancer)',
        categoryName: 'ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್ (Skin Cancer)',
        description: 'ಚರ್ಮದ ಕ್ಯಾನ್ಸರ್ ಸಾಧ್ಯತೆ ಕಂಡುಬಂದಿದೆ.',
        actionText: 'ತಕ್ಷಣ ಚರ್ಮ ರೋಗ ತಜ್ಞರಿಂದ ವೈದ್ಯಕೀಯ ತಪಾಸಣೆ ಮಾಡಿಸಿಕೊಳ್ಳುವುದು ಅತ್ಯಗತ್ಯ.',
      ),
    },
  };

  static String get(String lang, String key) {
    final map = _uiStrings[lang] ?? _uiStrings['en']!;
    return map[key] ?? _uiStrings['en']![key] ?? key;
  }

  static DiseaseInfo getDiseaseInfo(String lang, String labelKey) {
    final langMap = _diseaseData[lang] ?? _diseaseData['en']!;
    return langMap[labelKey.toLowerCase()] ??
        langMap['healthy'] ??
        const DiseaseInfo(
          medicalName: 'Unknown',
          categoryName: 'Unclassified',
          description: 'No classification',
          actionText: 'Consult a doctor.',
        );
  }
}
