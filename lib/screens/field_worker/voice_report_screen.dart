import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../services/gemini_service.dart';
import '../../models/need.dart';
import '../../providers/app_providers.dart';

class VoiceReportScreen extends StatefulWidget {
  const VoiceReportScreen({super.key});

  @override
  State<VoiceReportScreen> createState() => _VoiceReportScreenState();
}

class _VoiceReportScreenState extends State<VoiceReportScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRecording = false;
  bool _hasTranscript = false;
  bool _submitting = false;
  bool _processing = false;
  String _language = 'English';
  String _transcript = '';
  Map<String, dynamic>? _structuredData;
  final _textCtrl = TextEditingController();

  final _languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'];
  final _gemini = GeminiService();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }
      
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (status) => print('STT Status: $status'),
          onError: (error) => print('STT Error: $error'),
          debugLogging: true,
        );
        if (!available) {
          print('Speech recognition not available on this device');
        }
      } else {
        print('Microphone permission denied');
      }
    } catch (e) {
      print('STT Init failed: $e');
    }
  }

  bool _speechInitialized = false;

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // STOP RECORDING
        await _speech.stop();
        setState(() {
          _isRecording = false;
          _processing = true;
        });

        final rawTranscript = _textCtrl.text.isNotEmpty ? _textCtrl.text : _transcript;
        
        if (rawTranscript.isEmpty) {
          setState(() => _processing = false);
          return;
        }

        final result = await _gemini.transcribeAndSummarize(
          rawTranscript: rawTranscript,
          language: _language,
        );

        if (mounted) {
          try {
            final parsed = json.decode(result) as Map<String, dynamic>;
            if (parsed.containsKey('error')) {
              _structuredData = _smartLocalParse(rawTranscript);
            } else {
              _structuredData = parsed;
            }
          } catch (_) {
            _structuredData = _smartLocalParse(rawTranscript);
          }

          setState(() {
            _transcript = rawTranscript;
            _hasTranscript = true;
            _processing = false;
          });
        }
      } else {
        // START RECORDING
        _textCtrl.clear();
        
        if (!_speechInitialized) {
          _speechInitialized = await _speech.initialize(
            onError: (val) => print('Error: $val'),
            onStatus: (val) => print('Status: $val'),
          );
        }

        if (_speechInitialized) {
          setState(() {
            _isRecording = true;
            _hasTranscript = false;
            _transcript = '';
            _structuredData = null;
          });
          
          // Small delay to ensure engine is ready
          await Future.delayed(const Duration(milliseconds: 300));

          _speech.listen(
            onResult: (result) {
              setState(() {
                _transcript = result.recognizedWords;
                _textCtrl.text = _transcript;
                if (result.finalResult) {
                  _hasTranscript = true;
                }
              });
            },
            localeId: _getLocaleId(_language),
            cancelOnError: true,
            partialResults: true,
            listenMode: stt.ListenMode.dictation,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Speech recognition not available on this device.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String _getLocaleId(String lang) {
    switch (lang) {
      case 'Hindi': return 'hi_IN';
      case 'Tamil': return 'ta_IN';
      case 'Telugu': return 'te_IN';
      case 'Bengali': return 'bn_IN';
      default: return 'en_US';
    }
  }

  Map<String, dynamic> _smartLocalParse(String input) {
    final text = input.toLowerCase();
    
    // Extract Category
    String category = 'Other';
    if (text.contains('food') || text.contains('water') || text.contains('ration')) category = 'Food';
    else if (text.contains('medic') || text.contains('doctor') || text.contains('kit')) category = 'Medical';
    else if (text.contains('shelter') || text.contains('tent') || text.contains('camp')) category = 'Shelter';
    else if (text.contains('school') || text.contains('book') || text.contains('educat')) category = 'Education';
    
    // Extract Urgency
    String urgency = 'Medium';
    if (text.contains('urgent') || text.contains('critical') || text.contains('emergency')) urgency = 'Critical';
    else if (text.contains('low')) urgency = 'Low';

    // Extract Number of People
    final numberRegex = RegExp(r'\b\d+\b');
    final match = numberRegex.firstMatch(text);
    final peopleAffected = match != null ? int.parse(match.group(0)!) : 10;

    // Extract Location
    String location = 'Local Community';
    final locRegex = RegExp(r'(?:at|in|near|to)\s+([A-Z][a-zA-Z\s0-9]+)');
    final locMatch = locRegex.firstMatch(input);
    if (locMatch != null) {
      location = locMatch.group(1)!.trim();
    }

    return {
      'category': category,
      'urgency': urgency,
      'location': location,
      'peopleAffected': peopleAffected,
      'description': input.length > 100 ? input.substring(0, 97) + '...' : input,
    };
  }

  Future<void> _submitTranscript() async {
    setState(() => _submitting = true);

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id ?? 'unknown';

      final data = _structuredData ?? {};
      final categoryStr = (data['category'] as String? ?? 'other').toLowerCase();
      final urgencyStr = (data['urgency'] as String? ?? 'medium').toLowerCase();

      final urgencyLevel = urgencyStr == 'critical' || urgencyStr == 'high'
          ? UrgencyLevel.critical
          : urgencyStr == 'low' ? UrgencyLevel.low : UrgencyLevel.medium;

      final need = Need(
        id: '',
        category: NeedCategory.values.firstWhere(
          (c) => c.name.toLowerCase() == categoryStr,
          orElse: () => NeedCategory.other,
        ),
        description: data['description'] ?? _transcript,
        urgencyScore: urgencyLevel == UrgencyLevel.critical ? 9.0 : 5.0,
        urgencyLevel: urgencyLevel,
        status: NeedStatus.reported,
        location: data['location'] ?? 'Unknown',
        submittedBy: userId,
        timestamp: DateTime.now(),
        peopleAffected: data['peopleAffected'] ?? 0,
      );

      await context.read<NeedsProvider>().submitNeed(need);

      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(labelText: 'Language', prefixIcon: Icon(Icons.language)),
              items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _language = v!),
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: _processing ? null : _toggleRecording,
              borderRadius: BorderRadius.circular(50),
              child: _isRecording
                  ? Pulse(infinite: true, child: _MicButton(isRecording: true, theme: theme))
                  : _MicButton(isRecording: false, theme: theme),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording ? 'Listening... Speak now' : (_processing ? 'Analyzing...' : 'Tap to speak'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _isRecording ? Colors.red : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            if (_isRecording || _hasTranscript)
              TextField(
                controller: _textCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Live Transcript',
                  hintText: 'Your words will appear here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            if (_hasTranscript && _structuredData != null) ...[
              const SizedBox(height: 24),
              FadeIn(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Category', value: _structuredData!['category']),
                      _InfoRow(label: 'Location', value: _structuredData!['location']),
                      _InfoRow(label: 'Urgency', value: _structuredData!['urgency']),
                      _InfoRow(label: 'People', value: '${_structuredData!['peopleAffected']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitting ? null : _submitTranscript,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit to Database'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final bool isRecording;
  final ThemeData theme;
  const _MicButton({required this.isRecording, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRecording ? Colors.red : theme.colorScheme.primary,
      ),
      child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 48),
    );
  }
}
