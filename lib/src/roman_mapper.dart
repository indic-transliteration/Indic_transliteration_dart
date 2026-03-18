import 'scheme.dart';

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

  final buf = <String>[];
  var i = 0;
  var hadConsonant = false;
  var found = false;
  final dataLength = data.length;

  var toggled = false;
  var suspended = false;

  while (i <= dataLength) {
    var token = '';
    if (i + maxKeyLengthFromScheme <= dataLength) {
      token = data.substring(i, i + maxKeyLengthFromScheme);
    } else {
      token = data.substring(i);
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
        buf.add(data[i]);
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

  const capitalizableSchemeIds = [
    'iast',
    'iast_iso_m',
    'iso',
    'iso_vedic',
    'kolkata_v2',
    'titus',
  ];
  if (capitalizableSchemeIds.contains(schemeMap.fromScheme.name)) {
    result = schemeMap.toScheme.fixOm(result);
  }

  return result;
}
