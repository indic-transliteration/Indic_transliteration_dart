import 'scheme.dart';

const String _gurmukhiName = 'gurmukhi';
const String _bengaliName = 'bengali';
const String _teluguName = 'telugu';
const String _kannadaName = 'kannada';
const String _tamilSubName = 'tamil_subscripted';
const String _tamilSupName = 'tamil_superscripted';

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

String _replaceKhanda(String text) {
  return text.replaceAll('ৎ', 'ত্');
}

String _replaceNTelugu(String text) {
  text = text.replaceAll('ౝ', 'న్');
  return text;
}

String _replaceNKannada(String text) {
  text = text.replaceAll('ೝ', 'ನ್');
  text = text.replaceAll('೜', 'श्री');
  return text;
}

String _moveBeforeMaatraaSubscripts(String text) {
  text = text.replaceAllMapped(
    RegExp(r'([া-ௌ꞉ம்]+)([₂₃₄])'),
    (match) => '${match.group(2)}${match.group(1)}',
  );
  return text;
}

String _moveBeforeMaatraaSuperscripts(String text) {
  text = text.replaceAllMapped(
    RegExp(r'([া-ௌ꞉ம்]+)([²³⁴])'),
    (match) => '${match.group(2)}${match.group(1)}',
  );
  return text;
}

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
  var found = false;
  final dataLength = processedData.length;

  while (i <= dataLength) {
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
