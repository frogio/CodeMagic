import 'package:flutter_tts/flutter_tts.dart';

class TTSAPI {
  static TTSAPI _instance = TTSAPI._private();
  late FlutterTts _flutterTts;

  TTSAPI._private();

  static TTSAPI getInstance() {
    return _instance;
  }

  Future<void> init() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0); // Range: 0.5 - 2.0
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> Speak(String sentence) async {
    await _flutterTts.speak(sentence);
  }
}
