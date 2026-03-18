import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();

  // Transliterate from IAST to Devanagari
  final result1 = transliterate('rāma', fromScheme: iast, toScheme: devanagari);
  print('IAST to Devanagari: $result1'); // Expected: राम

  // Transliterate from Devanagari to IAST
  final result2 = transliterate('राम', fromScheme: devanagari, toScheme: iast);
  print('Devanagari to IAST: $result2'); // Expected: rāma

  // Transliterate from HK to Devanagari
  final result3 = transliterate('rAma', fromScheme: hk, toScheme: devanagari);
  print('HK to Devanagari: $result3'); // Expected: राम

  // Detect the script of a string
  final detected = detect('राम');
  print('Detected script: $detected'); // Expected: devanagari
}
