import 'src/scheme.dart' show getSchemeMap, SchemeMap;
import 'src/data/schemes.dart' show schemesData;
import 'src/brahmic_mapper.dart' as brahmic_mapper;
import 'src/roman_mapper.dart' as roman_mapper;

const String devanagari = 'devanagari';
const String bengali = 'bengali';
const String gujarati = 'gujarati';
const String gurmukhi = 'gurmukhi';
const String kannada = 'kannada';
const String malayalam = 'malayalam';
const String oriya = 'oriya';
const String tamil = 'tamil';
const String tamilSup = 'tamil_superscripted';
const String tamilSub = 'tamil_subscripted';
const String grantha = 'grantha';
const String telugu = 'telugu';

const String hk = 'hk';
const String hkDravidian = 'hk_dravidian';
const String iast = 'iast';
const String iso = 'iso';
const String isoVedic = 'iso_vedic';
const String itrans = 'itrans';
const String itransDravidian = 'itrans_dravidian';
const String titus = 'titus';
const String optitrans = 'optitrans';
const String optitransDravidian = 'optitrans_dravidian';
const String kolkata = 'kolkata_v2';
const String kolkataV2 = 'kolkata_v2';
const String slp1 = 'slp1';
const String velthuis = 'velthuis';
const String wx = 'wx';

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

String getStandardForm(String data, String schemeName) {
  return transliterate(
    transliterate(data, fromScheme: schemeName, toScheme: devanagari),
    fromScheme: devanagari,
    toScheme: schemeName,
  );
}

String getNumber(String text) {
  return transliterate(text, toScheme: iast);
}

String detect(String text) {
  const brahmicFirstCodePoint = 0x0900;
  const brahmicLastCodePoint = 0x0d7f;

  final schemes = <(String, int)>[
    ('bengali', 0x0980),
    ('devanagari', 0x0900),
    ('gujarati', 0x0a80),
    ('gurmukhi', 0x0a00),
    ('kannada', 0x0c80),
    ('malayalam', 0x0d00),
    ('oriya', 0x0b00),
    ('tamil', 0x0b80),
    ('telugu', 0x0c00),
  ];

  for (final char in text.runes) {
    if (char >= brahmicFirstCodePoint) {
      for (final entry in schemes) {
        final startCode = entry.$2;
        if (char >= startCode && char <= brahmicLastCodePoint) {
          return entry.$1;
        }
      }
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
