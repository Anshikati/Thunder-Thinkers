/// API key configuration for NeedsBridge.
/// 
/// IMPORTANT: Replace the placeholder keys below with your actual keys.
/// For production, use --dart-define or environment variables instead of
/// hardcoding keys here.
///
/// Usage with --dart-define:
///   flutter run --dart-define=GEMINI_API_KEY=your_key_here
///
/// Then access via:
///   const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
class ApiKeys {
  ApiKeys._();

  /// Gemini API key — replace with your actual key.
  /// You can also pass via: flutter run --dart-define=GEMINI_API_KEY=your_key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'pasteKeyHere',
  );

  /// Google Maps API key (already configured in AndroidManifest.xml for Android)
  static const String googleMapsApiKey = 'pasteGoogleMapKeyHere';
}
