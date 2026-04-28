import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

/// Service wrapping Google's Gemini generative AI for NeedsBridge.
///
/// Provides:
/// - Voice transcript summarization (for VoiceReportScreen)
/// - Image-based OCR form extraction (for ScanFormScreen)
class GeminiService {
  static GeminiService? _instance;
  late final GenerativeModel _textModel;
  late final GenerativeModel _visionModel;
  bool _isInitialized = false;

  GeminiService._();

  factory GeminiService() {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Initialize models. Call once at app start or lazily on first use.
  void _ensureInitialized() {
    if (_isInitialized) return;

    final apiKey = ApiKeys.geminiApiKey;
    if (apiKey == 'YOUR_GEMINI_API_KEY_HERE' || apiKey.isEmpty) {
      throw Exception(
        'Gemini API key not configured. '
        'Set it in lib/config/api_keys.dart or pass via '
        '--dart-define=GEMINI_API_KEY=your_key',
      );
    }

    _textModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 1024,
      ),
    );

    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2,
        maxOutputTokens: 1024,
      ),
    );

    _isInitialized = true;
  }

  /// Transcribe and summarize a voice report into a structured need description.
  ///
  /// [rawTranscript] — the raw speech-to-text output
  /// [language] — the language it was spoken in
  ///
  /// Returns a clean, structured summary suitable for creating a Need entry.
  Future<String> transcribeAndSummarize({
    required String rawTranscript,
    String language = 'English',
  }) async {
    _ensureInitialized();

    final prompt = '''
You are an assistant for an NGO volunteer coordination platform called NeedsBridge.
A field worker has recorded a voice report in $language. Below is the raw transcript.

Analyze this and return a clean, structured summary with:
1. **Location**: Where the need is (extract from the text)
2. **Category**: One of: Food, Medical, Shelter, Education, Sanitation, Other
3. **Description**: A clear 1-2 sentence description of the need
4. **People Affected**: Estimated number (extract from text or write "Unknown")
5. **Urgency**: One of: Low, Medium, Critical (based on content severity)

Raw transcript:
"""
$rawTranscript
"""

Return ONLY a JSON object with keys: location, category, description, peopleAffected, urgency
No markdown, no code fences, just valid JSON.
''';

    try {
      final response = await _textModel.generateContent([Content.text(prompt)]);
      return response.text ?? '{"error": "Empty response from Gemini"}';
    } catch (e) {
      return '{"error": "Gemini API error: ${e.toString().replaceAll('"', '\\"')}"}';
    }
  }

  /// Extract structured data from a scanned paper form image.
  ///
  /// [imageBytes] — the raw image bytes (JPEG/PNG)
  /// [mimeType] — the MIME type of the image (e.g., 'image/jpeg')
  ///
  /// Returns a JSON string with extracted form fields.
  Future<String> extractFormData({
    required Uint8List imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    _ensureInitialized();

    final prompt = '''
You are an OCR assistant for NeedsBridge, an NGO volunteer coordination platform.
This image is a scanned paper form reporting a community need.

Extract the following fields from the form:
1. **location**: Where the need is
2. **category**: One of: Food, Medical, Shelter, Education, Sanitation, Other
3. **description**: What the need is about
4. **peopleAffected**: Number of people affected (integer)
5. **urgency**: One of: Low, Medium, Critical
6. **submitterName**: Name of the person who filled the form (if visible)

If a field is not visible or readable, use "Unknown" for strings and 0 for numbers.

Return ONLY a valid JSON object with these keys. No markdown, no code fences.
''';

    try {
      final response = await _visionModel.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ]);
      return response.text ?? '{"error": "Empty response from Gemini"}';
    } catch (e) {
      return '{"error": "Gemini vision error: ${e.toString().replaceAll('"', '\\"')}"}';
    }
  }

  /// Check if the Gemini service is properly configured.
  bool get isConfigured {
    final key = ApiKeys.geminiApiKey;
    return key != 'YOUR_GEMINI_API_KEY_HERE' && key.isNotEmpty;
  }
}
