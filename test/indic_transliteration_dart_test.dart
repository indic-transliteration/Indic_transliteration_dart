import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    initializeSchemes();
  });

  group('Basic transliteration tests', () {
    test('transliterate from HK to Devanagari', () {
      final result = transliterate(
        'rAma',
        fromScheme: hk,
        toScheme: devanagari,
      );
      expect(result, equals('राम'));
    });

    test('transliterate from Devanagari to HK', () {
      final result = transliterate('राम', fromScheme: devanagari, toScheme: hk);
      expect(result, equals('rAma'));
    });

    test('transliterate from ITRANS to Devanagari', () {
      final result = transliterate(
        'raama',
        fromScheme: itrans,
        toScheme: devanagari,
      );
      expect(result, equals('राम'));
    });

    test('transliterate from SLP1 to Devanagari', () {
      final result = transliterate(
        'rAma',
        fromScheme: slp1,
        toScheme: devanagari,
      );
      expect(result, equals('राम'));
    });
  });

  group('Detection tests', () {
    test('detect Devanagari', () {
      final result = detect('राम');
      expect(result, equals('devanagari'));
    });

    test('detect Bengali', () {
      final result = detect('রাম');
      expect(result, equals('bengali'));
    });

    test('detect IAST', () {
      final result = detect('rāma');
      expect(result, equals('iast'));
    });

    test('detect HK', () {
      final result = detect('rAma');
      expect(result, equals('hk'));
    });

    test('detect ITRANS', () {
      final result = detect('raama');
      expect(result, equals('itrans'));
    });
  });

  group('Scheme tests', () {
    test('getScheme returns valid scheme', () {
      final scheme = getScheme(devanagari);
      expect(scheme.name, equals('devanagari'));
      expect(scheme.isRoman, isFalse);
    });

    test('getSchemeMap creates valid mapping', () {
      final schemeMap = getSchemeMap(hk, devanagari);
      expect(schemeMap.fromScheme.name, equals('hk'));
      expect(schemeMap.toScheme.name, equals('devanagari'));
    });
  });

  group('Brahmic to Brahmic tests', () {
    test('transliterate from Devanagari to Bengali', () {
      final result = transliterate(
        'राम',
        fromScheme: devanagari,
        toScheme: bengali,
      );
      expect(result, equals('রাম'));
    });
  });

  group('Toggle tests', () {
    test('toggle test', () {
      final result = transliterate(
        'akSa##kSa##ra',
        fromScheme: hk,
        toScheme: devanagari,
        togglers: {'##': '##'},
      );
      expect(result, equals('अक्षkSaर'));
    });
  });
}
