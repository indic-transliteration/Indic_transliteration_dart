import 'dart:convert';
import 'dart:io';

import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> loadTestData() {
  try {
    final file = File('test/data/transliterationTests.json');
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      return json.decode(content) as Map<String, dynamic>;
    }
    return {};
  } catch (e) {
    return {};
  }
}

void main() {
  final testData = loadTestData();

  setUpAll(() {
    initializeSchemes();
  });

  group('JSON-based transliteration tests - to_devanagarii', () {
    final toDev = testData['to_devanaagarii'] as List<dynamic>? ?? [];
    for (final testCase in toDev) {
      final tc = testCase as Map<String, dynamic>;
      final description = tc['description'] ?? 'test';
      final devExpected = tc['dev'] as String?;
      if (devExpected == null) continue;

      for (final script in tc.keys) {
        if (script == 'description' ||
            script == 'dev' ||
            script == 'nonSupportingPrograms') continue;

        final input = tc[script] as String?;
        if (input == null) continue;

        test('$description - $script to devanagari', () {
          final result =
              transliterate(input, fromScheme: script, toScheme: devanagari);
          expect(result, equals(devExpected));
        });
      }
    }
  });

  group('JSON-based transliteration tests - from_devanagarii', () {
    final fromDev = testData['from_devanaagarii'] as List<dynamic>? ?? [];
    for (final testCase in fromDev) {
      final tc = testCase as Map<String, dynamic>;
      final description = tc['description'] ?? 'test';
      final devInput = tc['dev'] as String?;
      if (devInput == null) continue;

      for (final script in tc.keys) {
        if (script == 'description' ||
            script == 'dev' ||
            script == 'nonSupportingPrograms') continue;

        final expected = tc[script] as String?;
        if (expected == null) continue;

        test('$description - devanagari to $script', () {
          final result =
              transliterate(devInput, fromScheme: devanagari, toScheme: script);
          expect(result, equals(expected));
        });
      }
    }
  });

  group('JSON-based roundtrip tests', () {
    final roundTrip =
        testData['devanaagarii_round_trip'] as List<dynamic>? ?? [];
    for (final testCase in roundTrip) {
      final tc = testCase as Map<String, dynamic>;
      final description = tc['description'] ?? 'test';
      final devExpected = tc['dev'] as String?;
      if (devExpected == null) continue;

      for (final script in tc.keys) {
        if (script == 'description' ||
            script == 'dev' ||
            script == 'nonSupportingPrograms') continue;

        final input = tc[script] as String?;
        if (input == null) continue;

        test('roundtrip $description - $script', () {
          final toDev =
              transliterate(input, fromScheme: script, toScheme: devanagari);
          final back =
              transliterate(toDev, fromScheme: devanagari, toScheme: script);
          expect(back, equals(input));
        });
      }
    }
  });
}
