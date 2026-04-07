import 'scheme.dart';

const _capitalizableSchemeIds = [
  'iast',
  'iast_iso_m',
  'iso',
  'iso_vedic',
  'kolkata_v2',
  'titus',
];

const _capitalToLower = {
  'A': 'a',
  'B': 'b',
  'C': 'c',
  'D': 'd',
  'E': 'e',
  'F': 'f',
  'G': 'g',
  'H': 'h',
  'I': 'i',
  'J': 'j',
  'K': 'k',
  'L': 'l',
  'M': 'm',
  'N': 'n',
  'O': 'o',
  'P': 'p',
  'Q': 'q',
  'R': 'r',
  'S': 's',
  'T': 't',
  'U': 'u',
  'V': 'v',
  'W': 'w',
  'X': 'x',
  'Y': 'y',
  'Z': 'z',
  'Ā': 'ā',
  'Ī': 'ī',
  'Ū': 'ū',
  'Ṛ': 'ṛ',
  'Ṝ': 'ṝ',
  'Ḷ': 'ḷ',
  'Ḹ': 'ḹ',
  'Ṅ': 'ṅ',
  'Ñ': 'ñ',
  'Ṭ': 'ṭ',
  'Ḍ': 'ḍ',
  'Ṇ': 'ṇ',
  'Ś': 'ś',
  'Ṣ': 'ṣ',
  'Ō': 'ō',
  'é': 'e',
  'à': 'a',
  'á': 'a',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'è': 'e',
  'ì': 'i',
  'ò': 'o',
  'ù': 'u',
  'ē': 'e',
};

String roman(
  String data,
  SchemeMap schemeMap, {
  Map<String, String> togglers = const {},
  Set<String> suspendOn = const {},
  Set<String> suspendOff = const {},
}) {
  final vowels = schemeMap.vowels;
  final vowelMarks = schemeMap.vowelMarks;
  final virama = schemeMap.virama;
  final consonants = schemeMap.consonants;
  final nonMarksViraama = schemeMap.nonMarksViraama;
  final maxKeyLengthFromScheme = schemeMap.maxKeyLengthFromScheme;
  final toRoman = schemeMap.toScheme.isRoman;
  final fromSchemeName = schemeMap.fromScheme.name;

  var processedData = data;
  if (_capitalizableSchemeIds.contains(fromSchemeName)) {
    final buf = StringBuffer();
    for (var i = 0; i < processedData.length; i++) {
      final char = processedData[i];
      if (_capitalToLower.containsKey(char)) {
        buf.write(_capitalToLower[char]!);
      } else {
        buf.write(char);
      }
    }
    processedData = buf.toString();
  }

  final buf = <String>[];
  var i = 0;
  var hadConsonant = false;
  var found = false;
  final dataLength = processedData.length;

  var toggled = false;
  var suspended = false;

  while (i <= dataLength) {
    var token = '';
    if (i + maxKeyLengthFromScheme <= dataLength) {
      token = processedData.substring(i, i + maxKeyLengthFromScheme);
    } else {
      token = processedData.substring(i);
    }

    while (token.isNotEmpty) {
      if (togglers.containsKey(token)) {
        toggled = !toggled;
        i += 2;
        found = true;
        break;
      }

      if (suspendOn.contains(token)) {
        suspended = true;
      } else if (suspendOff.contains(token)) {
        suspended = false;
      }

      if (toggled || suspended) {
        token = token.substring(0, token.length - 1);
        continue;
      }

      if (hadConsonant && vowels.containsKey(token)) {
        final mark = vowelMarks[token] ?? '';
        if (mark.isNotEmpty) {
          buf.add(mark);
        } else if (toRoman) {
          buf.add(vowels[token]!);
        }
        found = true;
      } else if (nonMarksViraama.containsKey(token)) {
        if (hadConsonant) {
          buf.add(virama[''] ?? '');
        }
        buf.add(nonMarksViraama[token]!);
        found = true;
      }

      if (found) {
        hadConsonant = consonants.containsKey(token);
        i += token.length;
        break;
      } else {
        token = token.substring(0, token.length - 1);
      }
    }

    if (!found) {
      if (hadConsonant) {
        buf.add(virama[''] ?? '');
      }
      if (i < dataLength) {
        buf.add(processedData[i]);
        hadConsonant = false;
      }
      i++;
    }

    found = false;
  }

  var result = buf.join();

  if (!toRoman && schemeMap.accents.isNotEmpty) {
    final accentValues = schemeMap.accents.values.join();
    final yogavaahas = schemeMap.toScheme.getYogavaahas() ?? {};
    final yogavaahaKeys = yogavaahas.keys.join();
    if (accentValues.isNotEmpty && yogavaahaKeys.isNotEmpty) {
      final pattern = RegExp('([$accentValues])([$yogavaahaKeys])');
      result = result.replaceAllMapped(
        pattern,
        (match) => '${match.group(2)}${match.group(1)}',
      );
    }
  }

  if (_capitalizableSchemeIds.contains(schemeMap.fromScheme.name)) {
    result = schemeMap.toScheme.fixOm(result);
  }

  return result;
}
