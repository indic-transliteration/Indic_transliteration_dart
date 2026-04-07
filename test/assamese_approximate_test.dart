import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    initializeAll();
  });

  group('Assamese Approximate Mappings', () {
    test('Devanagari to Assamese uses approximates', () {
      // Devanagari 'ळ' (\u0933) should become Assamese 'ড়' (\u09a1\u09bc)
      // Standard mapping in [consonants] is 'ল়' (\u09b2\u09bc)
      // Approximate mapping in [approximate_consonants] is 'ড়' (\u09a1\u09bc)
      final result = transliterate('ळ', fromScheme: 'devanagari', toScheme: 'assamese');
      expect(result, equals('ড়'));
      expect(result, isNot(equals('ল়')));
    });

    test('Assamese to Devanagari does NOT use approximates', () {
      // Assamese 'ড়' (\u09dc) should map to Devanagari 'ड़' (\u095c)
      // according to [extra_consonants], NOT 'ळ' (\u0933).
      final result = transliterate('ড়', fromScheme: 'assamese', toScheme: 'devanagari');
      expect(result, equals('ड़'));
      expect(result, isNot(equals('ळ')));
    });

    test('Assamese standard consonants still work', () {
      final result = transliterate('ক', fromScheme: 'assamese', toScheme: 'devanagari');
      expect(result, equals('क'));
    });
  });
}
