import 'scheme.dart';

/// The name of the Gurmukhi script, used for identifying Gurmukhi-specific processing.
const String _gurmukhiName = 'gurmukhi';

/// The name of the Bengali script, used for identifying Bengali-specific processing.
const String _bengaliName = 'bengali';

/// The name of the Telugu script, used for identifying Telugu-specific processing.
const String _teluguName = 'telugu';

/// The name of the Kannada script, used for identifying Kannada-specific processing.
const String _kannadaName = 'kannada';

/// The name of the Tamil subscripted variant.
const String _tamilSubName = 'tamil_subscripted';

/// The name of the Tamil superscripted variant.
const String _tamilSupName = 'tamil_superscripted';

/// Replaces Addak (ੱ) with its equivalent virama + consonant form in Gurmukhi.
///
/// Addak is a half-form of a consonant in Gurmukhi that precedes another consonant.
/// This function converts Addak followed by a consonant into the full form
/// with virama.
///
/// Example:
/// - 'ੱਕ' becomes 'ਕ੍ਕ'
/// - 'ੱਗ' becomes 'ਗ੍ਗ'
///
/// [text] - The Gurmukhi text with Addak characters.
///
/// Returns the text with Addak replaced by virama forms.
String _replaceAddak(String text) {
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਕਖ])'),
    (match) => 'ਕ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਗਘ])'),
    (match) => 'ਗ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਚਛ])'),
    (match) => 'ਚ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਜਝ])'),
    (match) => 'ਜ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਟਠ])'),
    (match) => 'ਟ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਡਢ])'),
    (match) => 'ਡ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਤਥ])'),
    (match) => 'ਤ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਦਧ])'),
    (match) => 'ਦ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਪਫ])'),
    (match) => 'ਪ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਬਭ])'),
    (match) => 'ਬ੍${match.group(1)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'ੱ([ਯਰਲਵਸ਼ਸਹਙਞਣਨਮਜ਼ੜਫ਼])'),
    (match) => '${match.group(1)}੍${match.group(1)}',
  );
  return text;
}

/// Replaces Bengali Khanda ta (ৎ) with its equivalent form.
///
/// The Khanda ta is a special character in Bengali used for the ত sound
/// after vowels. This function converts it to its equivalent with virama.
///
/// [text] - The Bengali text with Khanda ta.
///
/// Returns the text with Khanda ta replaced by ত্.
String _replaceKhanda(String text) {
  return text.replaceAll('ৎ', 'ত্');
}

/// Replaces Telugu auxiliary mark (ౝ) with its equivalent form.
///
/// This function converts the Telugu auxiliary mark to its equivalent
/// representation using the anusvara + virama combination.
///
/// [text] - The Telugu text with auxiliary mark.
///
/// Returns the text with auxiliary mark replaced by न్.
String _replaceNTelugu(String text) {
  text = text.replaceAll('ౝ', 'న్');
  return text;
}

/// Replaces Kannada auxiliary marks with their equivalent forms.
///
/// This function converts Kannada auxiliary marks to their equivalent
/// representations. It handles:
/// - ೝ ( auxiliary mark) -> ನ್
/// - ೜ (Shri ligature) -> श्री
///
/// [text] - The Kannada text with auxiliary marks.
///
/// Returns the text with auxiliary marks replaced.
String _replaceNKannada(String text) {
  text = text.replaceAll('ೝ', 'ನ್');
  text = text.replaceAll('೜', 'श्री');
  return text;
}

/// Moves subscript numerals before their associated maatraa (vowel mark).
///
/// In Tamil subscripted notation, numerals appear after the vowel mark.
/// This function rearranges them to appear before the vowel mark for
/// proper transliteration.
///
/// Example:
/// - 'க்₂' becomes '₂க்'
///
/// [text] - The Tamil subscripted text with numerals after vowel marks.
///
/// Returns the text with numerals moved before vowel marks.
String _moveBeforeMaatraaSubscripts(String text) {
  text = text.replaceAllMapped(
    RegExp(r'([া-ௌ꞉ம்]+)([₂₃₄])'),
    (match) => '${match.group(2)}${match.group(1)}',
  );
  return text;
}

/// Moves superscript numerals before their associated maatraa (vowel mark).
///
/// In Tamil superscripted notation, numerals appear after the vowel mark.
/// This function rearranges them to appear before the vowel mark for
/// proper transliteration.
///
/// Example:
/// - 'க்²' becomes '²க்'
///
/// [text] - The Tamil superscripted text with numerals after vowel marks.
///
/// Returns the text with numerals moved before vowel marks.
String _moveBeforeMaatraaSuperscripts(String text) {
  text = text.replaceAllMapped(
    RegExp(r'([া-ௌ꞉ம்]+)([²³⁴])'),
    (match) => '${match.group(2)}${match.group(1)}',
  );
  return text;
}

/// Transliterates text from a Brahmic (Indic) script to another script.
///
/// This is the core function for converting between native Indic scripts
/// (like Devanagari, Bengali, Tamil, etc.). It handles:
/// - Script-specific character replacements (Gurmukhi Addak, Bengali Khanda, etc.)
/// - Proper handling of vowel marks (matras)
/// - Consonant-vowel joining with virama
/// - Accent reordering when converting to romanization
///
/// The function processes the input by:
/// 1. Applying any script-specific preprocessing (Addak, Khanda, etc.)
/// 2. Handling accent ordering for romanization output
/// 3. Iterating through characters and matching against the scheme map
/// 4. Appending 'a' after final consonants (for romanization)
///
/// [data] - The input text in the source Brahmic script.
/// [schemeMap] - The [SchemeMap] containing mappings from source to target.
///
/// Returns the transliterated text in the target script.
///
/// Example:
/// ```dart
/// final map = getSchemeMap('devanagari', 'iast');
/// final result = brahmic('हिंदी', map); // Returns 'hiṃdī'
/// ```
String brahmic(String data, SchemeMap schemeMap) {
  var processedData = data;

  if (schemeMap.fromScheme.name == _gurmukhiName) {
    processedData = _replaceAddak(processedData);
  } else if (schemeMap.fromScheme.name == _bengaliName) {
    processedData = _replaceKhanda(processedData);
  } else if (schemeMap.fromScheme.name == _teluguName) {
    processedData = _replaceNTelugu(processedData);
  } else if (schemeMap.fromScheme.name == _kannadaName) {
    processedData = _replaceNKannada(processedData);
  } else if (schemeMap.fromScheme.name == _tamilSubName) {
    processedData = _moveBeforeMaatraaSubscripts(processedData);
  } else if (schemeMap.fromScheme.name == _tamilSupName) {
    processedData = _moveBeforeMaatraaSuperscripts(processedData);
  }

  final vowelMarks = schemeMap.vowelMarks;
  final virama = schemeMap.virama;
  final consonants = schemeMap.consonants;
  final nonMarksViraama = schemeMap.nonMarksViraama;
  final toRoman = schemeMap.toScheme.isRoman;
  final maxKeyLengthFromScheme = schemeMap.maxKeyLengthFromScheme;

  if (toRoman && schemeMap.accents.isNotEmpty) {
    final yogavaahas = schemeMap.fromScheme.getYogavaahas() ?? {};
    final accentKeys = schemeMap.accents.keys.join();
    final yogavaahaKeys = yogavaahas.keys.join();
    if (yogavaahaKeys.isNotEmpty && accentKeys.isNotEmpty) {
      final pattern = RegExp('([$yogavaahaKeys])([$accentKeys])');
      processedData = processedData.replaceAllMapped(
        pattern,
        (match) => '${match.group(2)}${match.group(1)}',
      );
    }
  }

  final buf = <String>[];
  var i = 0;
  var toRomanHadConsonant = false;
  final dataLength = processedData.length;

  while (i <= dataLength) {
    var found = false;
    var token = '';
    if (i + maxKeyLengthFromScheme <= dataLength) {
      token = processedData.substring(i, i + maxKeyLengthFromScheme);
    } else {
      token = processedData.substring(i);
    }

    while (token.isNotEmpty) {
      if (token.length == 1) {
        if (vowelMarks.containsKey(token)) {
          buf.add(vowelMarks[token]!);
          found = true;
        } else if (virama.containsKey(token)) {
          buf.add(virama[token]!);
          found = true;
        } else {
          if (toRomanHadConsonant) {
            buf.add('a');
          }
          buf.add(nonMarksViraama[token] ?? token);
          found = true;
        }
      } else {
        if (nonMarksViraama.containsKey(token)) {
          if (toRomanHadConsonant) {
            buf.add('a');
          }
          buf.add(nonMarksViraama[token]!);
          found = true;
        }
      }

      if (found) {
        toRomanHadConsonant = toRoman && consonants.containsKey(token);
        i += token.length;
        break;
      } else {
        token = token.substring(0, token.length - 1);
      }
    }

    if (!found) {
      if (toRomanHadConsonant) {
        if (virama.isNotEmpty) {
          buf.add(virama.values.first);
        }
      }
      if (i < dataLength) {
        buf.add(processedData[i]);
        toRomanHadConsonant = false;
      }
      i++;
    }

    found = false;
  }

  if (toRomanHadConsonant) {
    buf.add('a');
  }

  return buf.join();
}
