import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../models/need.dart';

class VoiceReportScreen extends StatefulWidget {
  const VoiceReportScreen({super.key});

  @override
  State<VoiceReportScreen> createState() => _VoiceReportScreenState();
}

class _VoiceReportScreenState extends State<VoiceReportScreen> {
  bool _isRecording = false;
  bool _hasTranscript = false;
  bool _submitting = false;
  String _language = 'English';
  String _transcript = '';

  final _languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali'];

  final _mockTranscripts = {
    'English': 'Families in Sector 6 are in urgent need of food supplies. Around 30 families affected, children not eating since morning.',
    'Hindi': 'क्षेत्र 6 में परिवारों को खाद्य आपूर्ति की तत्काल आवश्यकता है। लगभग 30 परिवार प्रभावित हैं।',
    'Tamil': 'பகுதி 6 குடும்பங்களுக்கு உணவு தேவை. சுமார் 30 குடும்பங்கள் பாதிக்கப்பட்டுள்ளன.',
    'Telugu': 'సెక్టార్ 6 లో కుటుంబాలకు ఆహారం అవసరం. సుమారు 30 కుటుంబాలు ప్రభావితమయ్యాయి.',
    'Bengali': 'সেক্টর 6-এ পরিবারগুলির জরুরি খাদ্য সহায়তা প্রয়োজন। প্রায় 30টি পরিবার ক্ষতিগ্রস্ত।',
  };

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() { _isRecording = false; });
      await Future.delayed(const Duration(seconds: 2));
      // Simulates connectSpeechToTextAPI()
      if (mounted) {
        setState(() {
          _transcript = _mockTranscripts[_language] ?? _mockTranscripts['English']!;
          _hasTranscript = true;
        });
      }
    } else {
      setState(() { _isRecording = true; _hasTranscript = false; _transcript = ''; });
    }
  }

  Future<void> _submitTranscript() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Voice report submitted successfully'),
          backgroundColor: const Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Report')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(
                labelText: 'Language',
                prefixIcon: Icon(Icons.language),
              ),
              items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _language = v!),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _toggleRecording,
              child: _isRecording
                  ? Pulse(
                      infinite: true,
                      child: _MicButton(isRecording: true, theme: theme),
                    )
                  : _MicButton(isRecording: false, theme: theme),
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording ? 'Recording... Tap to stop' : 'Tap to speak your report',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _isRecording ? const Color(0xFFD32F2F) : theme.colorScheme.onSurfaceVariant,
                fontWeight: _isRecording ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            if (_hasTranscript) ...[
              FadeIn(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.transcribe, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text('Transcript', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_transcript, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submitTranscript,
                  icon: _submitting
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: const Text('Confirm & Submit'),
                ),
              ),
            ],
          ],
        ),
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRecording ? const Color(0xFFD32F2F) : theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: (isRecording ? const Color(0xFFD32F2F) : theme.colorScheme.primary).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
        size: 52,
        color: Colors.white,
      ),
    );
  }
}
