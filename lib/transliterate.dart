import 'src/scheme.dart' show getSchemeMap, SchemeMap;
import 'package:indic_transliteration_maps/indic_transliteration_maps.dart'
    show schemesData;
import 'src/brahmic_mapper.dart' as brahmic_mapper;
import 'src/roman_mapper.dart' as roman_mapper;

/// Devanagari script identifier.
/// Used as a scheme name in transliteration operations.
const String devanagari = 'devanagari';

/// Bengali script identifier.
const String bengali = 'bengali';

/// Gujarati script identifier.
const String gujarati = 'gujarati';

/// Gurmukhi (Punjabi) script identifier.
const String gurmukhi = 'gurmukhi';

/// Kannada script identifier.
const String kannada = 'kannada';

/// Malayalam script identifier.
const String malayalam = 'malayalam';

/// Oriya script identifier.
const String oriya = 'oriya';

/// Tamil script identifier.
const String tamil = 'tamil';

/// Tamil with superscripted numerals identifier.
const String tamilSup = 'tamil_superscripted';

/// Tamil with subscripted numerals identifier.
const String tamilSub = 'tamil_subscripted';

/// Grantha script identifier.
const String grantha = 'grantha';

/// Telugu script identifier.
const String telugu = 'telugu';

/// Harvard-Kyoto romanization scheme identifier.
const String hk = 'hk';

/// Harvard-Kyoto Dravidian variant identifier.
const String hkDravidian = 'hk_dravidian';

/// International Alphabet of Sanskrit Transliteration (IAST) identifier.
const String iast = 'iast';

/// ISO 15919 romanization scheme identifier.
const String iso = 'iso';

/// ISO 15919 Vedic variant identifier.
const String isoVedic = 'iso_vedic';

/// ITRANS romanization scheme identifier.
const String itrans = 'itrans';

/// ITRANS Dravidian variant identifier.
const String itransDravidian = 'itrans_dravidian';

/// Titus romanization scheme identifier.
const String titus = 'titus';

/// Optitrans romanization scheme identifier.
const String optitrans = 'optitrans';

/// Optitrans Dravidian variant identifier.
const String optitransDravidian = 'optitrans_dravidian';

/// Kolkata romanization scheme v2 identifier.
const String kolkata = 'kolkata_v2';

/// Alias for kolkata_v2.
const String kolkataV2 = 'kolkata_v2';

/// SLP1 (Sanskrit Library Project 1) romanization scheme identifier.
const String slp1 = 'slp1';

/// Velthuis romanization scheme identifier.
const String velthuis = 'velthuis';

/// WX romanization scheme identifier.
const String wx = 'wx';

/// Transliterates text from one Indic script or romanization scheme to another.
///
/// This is the main function for converting text between different Indic scripts
/// (such as Devanagari, Bengali, Tamil, etc.) and romanization schemes
/// (such as IAST, ITRANS, HK, etc.).
///
/// The function automatically detects the source script if not specified,
/// and supports various options for handling Dravidian language variants,
/// togglers, and suspension markers.
///
/// Example usage:
/// ```dart
/// // Convert Devanagari to IAST
/// final result = transliterate('हिंदी', fromScheme: 'devanagari', toScheme: 'iast');
/// // Result: 'hindi'
///
/// // Convert ITRANS to Devanagari
/// final result = transliterate('namaste', fromScheme: 'itrans', toScheme: 'devanagari');
/// // Result: 'नमस्ते'
/// ```
///
/// [data] - The input text to transliterate.
///
/// [fromScheme] - The source scheme name (e.g., 'devanagari', 'iast', 'itrans').
/// If null, auto-detection will be attempted.
///
/// [toScheme] - The target scheme name. Required if schemeMap is not provided.
///
/// [schemeMap] - Optional pre-built SchemeMap for custom transliteration rules.
/// If provided, fromScheme and toScheme are ignored.
///
/// [togglers] - A map of token pairs that toggle transliteration mode on/off.
/// Useful for handling special characters or escape sequences.
///
/// [suspendOn] - Set of tokens that suspend transliteration when encountered.
///
/// [suspendOff] - Set of tokens that resume transliteration after suspension.
///
/// [maybeUseDravidianVariant] - Controls Dravidian variant usage:
///   - 'no' (default): Do not use Dravidian variants
///   - 'yes': Use Dravidian variant if available and source/target is Dravidian
///   - 'force': Force Dravidian variant regardless of source/target
///
/// Returns the transliterated string.
///
/// Throws [ArgumentError] if toScheme is not specified and schemeMap is not provided.
String transliterate(
  String data, {
  String? fromScheme,
  String? toScheme,
  SchemeMap? schemeMap,
  Map<String, String> togglers = const {},
  Set<String> suspendOn = const {},
  Set<String> suspendOff = const {},
  String maybeUseDravidianVariant = 'no',
}) {
  if (schemeMap == null) {
    fromScheme ??= detect(data);

    var toSchemeFinal = toScheme;

    if (maybeUseDravidianVariant == 'yes' ||
        maybeUseDravidianVariant == 'force') {
      if (['kannada', 'tamil', 'telugu', 'malayalam'].contains(fromScheme)) {
        final dravidianScheme = '${toScheme}_dravidian';
        if (schemesData.containsKey(dravidianScheme)) {
          toSchemeFinal = dravidianScheme;
        }
      } else if (['optitrans', 'itrans', 'hk'].contains(fromScheme)) {
        final dravidianScheme = '${fromScheme}_dravidian';
        if (schemesData.containsKey(dravidianScheme)) {
          fromScheme = dravidianScheme;
        }
      }
    }

    if (toSchemeFinal == null) {
      throw ArgumentError(
        'toScheme must be specified if schemeMap is not provided',
      );
    }

    schemeMap = getSchemeMap(fromScheme, toSchemeFinal);
  }

  var result = schemeMap.fromScheme.unapplyShortcuts(data);

  if (schemeMap.fromScheme.isRoman) {
    result = roman_mapper.roman(
      result,
      schemeMap,
      togglers: togglers,
      suspendOn: suspendOn,
      suspendOff: suspendOff,
    );
  } else {
    result = brahmic_mapper.brahmic(result, schemeMap);
  }

  result = schemeMap.toScheme.applyShortcuts(result);
  return result;
}

/// Converts text to the standard form for a given romanization scheme.
///
/// This function performs a round-trip conversion: first from the source scheme
/// to Devanagari, then from Devanagari to the target scheme. This helps normalize
/// text by eliminating ambiguities in the original encoding.
///
/// For example, in ITRANS 'I' can represent either the vowel 'I' (इ) or the
/// consonant 'i'. By converting through Devanagari, this ambiguity is resolved.
///
/// [data] - The input text in the specified scheme.
///
/// [schemeName] - The name of the romanization scheme (e.g., 'iast', 'itrans', 'hk').
///
/// Returns the normalized text in the specified scheme.
///
/// Example:
/// ```dart
/// // 'I' in ITRANS could mean either 'इ' or 'ि'
/// final result = getStandardForm('I', 'itrans');
/// // Returns the unambiguous form
/// ```
String getStandardForm(String data, String schemeName) {
  return transliterate(
    transliterate(data, fromScheme: schemeName, toScheme: devanagari),
    fromScheme: devanagari,
    toScheme: schemeName,
  );
}

/// Converts Indic numerals in text to IAST romanization numerals.
///
/// This function takes any text containing Indic script numerals (such as
/// Devanagari digits ٠١٢٣٤٥٦٧٨٩ or other Indic digit sets) and converts them
/// to their IAST romanization equivalents.
///
/// [text] - The input text containing Indic numerals.
///
/// Returns a string with numerals converted to IAST format (ASCII digits).
///
/// Example:
/// ```dart
/// final result = getNumber('१२३'); // Returns '123'
/// final result = getNumber('Devanagari: १२३, Bengali: ০১২'); // Returns 'Devanagari: 123, Bengali: 012'
/// ```
String getNumber(String text) {
  return transliterate(text, toScheme: iast);
}

/// Automatically detects the Indic script or romanization scheme of the given text.
///
/// This function analyzes the Unicode character ranges and specific patterns in the
/// input text to determine which script or romanization scheme is most likely used.
///
/// The detection works as follows:
/// 1. First checks for Brahmic script Unicode ranges (Devanagari, Bengali, etc.)
/// 2. Then checks for romanization-specific patterns (diacritics, special sequences)
///
/// Brahmic scripts detected (by Unicode range):
/// - Bengali (U+0980 - U+09FF)
/// - Devanagari (U+0900 - U+097F)
/// - Gujarati (U+0A80 - U+0AFF)
/// - Gurmukhi (U+0A00 - U+0A7F)
/// - Kannada (U+0C80 - U+0CFF)
/// - Malayalam (U+0D00 - U+0D7F)
/// - Oriya (U+0B00 - U+0B7F)
/// - Tamil (U+0B80 - U+0BFF)
/// - Telugu (U+0C00 - U+0C7F)
///
/// Romanization schemes detected (by pattern matching):
/// - `kolkata_v2`: Presence of 'ē' or 'ō' (distinct from IAST)
/// - `iast`: Presence of IAST-specific diacritics (āīūṛṝḷḹēōṃḥṅñṭḍṇśṣ)
/// - `itrans`: Patterns like 'ee', 'oo', '^i', 'RRi', 'Ch', 'sh', '.a'
/// - `slp1`: Patterns like 'fFxXEOCYwWqQPB', 'kz', 'Nk', 'tT', 'dD'
/// - `velthuis`: Patterns like '.m', '.h', '.n', '"n', '~s'
/// - `hk` (default): Falls back to HK if other romanizations don't match
///
/// [text] - The input text to analyze.
///
/// Returns the detected scheme name as a string (e.g., 'devanagari', 'iast', 'itrans').
///
/// Note: Detection is not guaranteed to be 100% accurate. For best results,
/// explicitly specify the source scheme when known.
String detect(String text) {
  for (final char in text.runes) {
    if (char >= 0x0980 && char <= 0x09FF) {
      return 'bengali';
    }
    if (char >= 0x0900 && char <= 0x097F) {
      return 'devanagari';
    }
    if (char >= 0x0A80 && char <= 0x0AFF) {
      return 'gujarati';
    }
    if (char >= 0x0A00 && char <= 0x0A7F) {
      return 'gurmukhi';
    }
    if (char >= 0x0C80 && char <= 0x0CFF) {
      return 'kannada';
    }
    if (char >= 0x0D00 && char <= 0x0D7F) {
      return 'malayalam';
    }
    if (char >= 0x0B00 && char <= 0x0B7F) {
      return 'oriya';
    }
    if (char >= 0x0B80 && char <= 0x0BFF) {
      return 'tamil';
    }
    if (char >= 0x0C00 && char <= 0x0C7F) {
      return 'telugu';
    }
  }

  final iastOrKolkataOnly = RegExp(r'[āīūṛṝḷḹēōṃḥṅñṭḍṇśṣḻĀĪŪṚṜḶḸĒŌṂḤṄÑṬḌṆŚṢḺ]');
  if (iastOrKolkataOnly.hasMatch(text)) {
    final kolkataOnly = RegExp(r'[ēō]');
    if (kolkataOnly.hasMatch(text)) {
      return 'kolkata_v2';
    } else {
      return 'iast';
    }
  }

  final itransOnly = RegExp(
    r'ee|oo|\^[iI]|RR[iI]|L[iI]|~N|N\^|Ch|chh|JN|sh|Sh|\.a',
  );
  if (itransOnly.hasMatch(text)) {
    return 'itrans';
  }

  final slp1Only = RegExp(
    r'[fFxXEOCYwWqQPB]|kz|Nk|Ng|tT|dD|Sc|Sn|[aAiIuUfFxXeEoO]R|(\W|^)G',
  );
  if (slp1Only.hasMatch(text)) {
    return 'slp1';
  }

  final velthuisOnly = RegExp(r'\.[mhnrltds]|"n|~s');
  if (velthuisOnly.hasMatch(text)) {
    return 'velthuis';
  }

  final itransOrVelthuisOnly = RegExp(r'aa|ii|uu|~n');
  if (itransOrVelthuisOnly.hasMatch(text)) {
    return 'itrans';
  }

  return 'hk';
}

/// Checks if the given script is a Dravidian language script.
///
/// Dravidian languages (Tamil, Telugu, Kannada, Malayalam) have different
/// orthographic conventions compared to Indo-Aryan languages. This function
/// helps identify whether a script falls into the Dravidian category.
///
/// [script] - The script name to check (e.g., 'devanagari', 'tamil', 'kannada').
///
/// Returns `true` if the script is Dravidian, `false` otherwise.
///
/// Dravidian scripts: kannada, tamil, telugu, malayalam
/// Non-Dravidian (Indo-Aryan) scripts: devanagari, gujarati, gurmukhi, bengali, oriya
///
/// Example:
/// ```dart
/// likelyDravidian('tamil');    // Returns true
/// likelyDravidian('devanagari'); // Returns false
/// ```
bool likelyDravidian(String script) {
  const nonDravidianScripts = [
    'devanagari',
    'gujarati',
    'gurmukhi',
    'bengali',
    'oriya',
  ];
  return !nonDravidianScripts.contains(script);
}
