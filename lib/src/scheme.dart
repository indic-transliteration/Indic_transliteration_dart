import 'data/schemes.dart'
    show initSchemesData, schemesData, schemeTypes, devVowelToMarkMap;

enum VisargaApproximation { aha, h }

const languageCodeToScript = {
  'sa': 'devanagari',
  'ta': 'tamil',
  'ka': 'kannada',
  'te': 'telugu',
  'hi': 'devanagari',
  'ma': 'devanagari',
  'ne': 'devanagari',
  'kok': 'devanagari',
  'as': 'assamese',
  'ml': 'malayalam',
  'bn': 'bengali',
  'gu': 'gujarati',
  'pa': 'panjabi',
  'or': 'oriya',
};

class Scheme {
  final String name;
  final bool isRoman;
  final Map<String, Map<String, dynamic>> data;
  late final List<String> longVowels;

  Scheme({required this.name, required this.isRoman, required this.data}) {
    final vowels = data['vowels'] ?? {};
    longVowels = ['आ', 'ई', 'ऊ', 'ॠ', 'ए', 'ऐ', 'ओ', 'औ']
        .where((v) => vowels.containsKey(v))
        .map((v) => vowels[v].toString())
        .toList();

    // For Roman schemes, add vowel_marks derived from vowels and devVowelToMarkMap
    // Key is Devanagari vowel mark (e.g., "ा"), value is Roman (e.g., "A")
    if (isRoman && !data.containsKey('vowel_marks')) {
      final vowelMarks = <String, String>{};
      for (final entry in vowels.entries) {
        final devVowel = entry.key;
        final romanValue = entry.value.toString();
        if (devVowel != 'अ' && devVowelToMarkMap.containsKey(devVowel)) {
          final mark = devVowelToMarkMap[devVowel]!;
          vowelMarks[mark] =
              romanValue; // Key is Devanagari mark, value is Roman
        }
      }
      if (vowelMarks.isNotEmpty) {
        data['vowel_marks'] = vowelMarks;
      }
    }
  }

  Map<String, dynamic> operator [](String key) => data[key] ?? {};

  bool containsKey(String key) => data.containsKey(key);

  String? getVowel(String key) => data['vowels']?[key]?.toString();
  String? getVowelMark(String key) => data['vowel_marks']?[key]?.toString();
  String? getConsonant(String key) => data['consonants']?[key]?.toString();
  String? getVirama(String key) => data['virama']?[key]?.toString();
  String? getYogavaaha(String key) => data['yogavaahas']?[key]?.toString();
  String? getAccent(String key) => data['accents']?[key]?.toString();
  String? getSymbol(String key) => data['symbols']?[key]?.toString();
  Map<String, dynamic>? getAlternates() => data['alternates'];
  Map<String, String>? getVowelMarks() {
    final marks = data['vowel_marks'];
    if (marks == null) return null;
    return marks.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, String>? getVowels() {
    final vowels = data['vowels'];
    if (vowels == null) return null;
    return vowels.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, String>? getConsonants() {
    final consonants = data['consonants'];
    if (consonants == null) return null;
    return consonants.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, String>? getViramaMap() {
    final virama = data['virama'];
    if (virama == null) return null;
    return virama.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, String>? getYogavaahas() {
    final yogavaahas = data['yogavaahas'];
    if (yogavaahas == null) return null;
    return yogavaahas.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, String>? getAccents() {
    final accents = data['accents'];
    if (accents == null) return null;
    return accents.map((k, v) => MapEntry(k, v.toString()));
  }

  Map<String, List<String>>? getAccentedVowelAlternates() {
    final alternates = data['accented_vowel_alternates'];
    if (alternates == null) return null;
    return alternates.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  Map<String, String>? getShortcuts() {
    final shortcuts = data['shortcuts'];
    if (shortcuts == null) return null;
    return shortcuts.map((k, v) => MapEntry(k, v.toString()));
  }

  String fixOm(String dataIn) {
    final vowelsVal = data['vowels']?['ओ']?.toString() ?? '';
    final yogavaahasVal = data['yogavaahas']?['ं']?.toString() ?? '';
    final viramaVal = data['virama']?['्']?.toString() ?? '';
    final consonantsVal = data['consonants']?['म']?.toString() ?? '';
    final omSymbol = data['symbols']?['ॐ']?.toString() ?? 'ॐ';

    if (vowelsVal.isEmpty || yogavaahasVal.isEmpty || consonantsVal.isEmpty) {
      return dataIn;
    }

    try {
      final pattern = RegExp(
        r'(?<=(^|\s|\p{Punct}))' +
            RegExp.escape(vowelsVal) +
            r'(' +
            RegExp.escape(yogavaahasVal) +
            r'|' +
            RegExp.escape(viramaVal + consonantsVal) +
            r')(?=(\s|$|\p{Punct}))',
        unicode: true,
      );

      return dataIn.replaceAllMapped(pattern, (match) => omSymbol);
    } catch (e) {
      return dataIn;
    }
  }

  String applyShortcuts(String dataIn) {
    final shortcuts = getShortcuts();
    if (shortcuts == null) return dataIn;

    var result = dataIn;
    for (final entry in shortcuts.entries) {
      final key = entry.key;
      final shortcut = entry.value;
      if (key.contains(shortcut)) {
        result = result.replaceAll(key, shortcut);
      }
      result = result.replaceAll(key, shortcut);
    }
    return result;
  }

  String unapplyShortcuts(String dataIn) {
    final shortcuts = getShortcuts();
    final accentedAlternates = getAccentedVowelAlternates();
    var result = dataIn;

    if (shortcuts != null) {
      for (final entry in shortcuts.entries) {
        final key = entry.key;
        final shortcut = entry.value;
        if (shortcut.contains(key)) {
          result = result.replaceAll(shortcut, key);
        }
        result = result.replaceAll(shortcut, key);
      }
    }

    if (accentedAlternates != null) {
      for (final entry in accentedAlternates.entries) {
        final standard = entry.key;
        for (final alternate in entry.value) {
          result = result.replaceAll(alternate, standard);
        }
      }
    }

    return result;
  }

  String forceLazyAnusvaara(String dataIn) {
    final anusvara = data['yogavaahas']?['ं']?.toString() ?? 'ं';
    final consonants = getConsonants() ?? {};
    final virama = data['virama']?['']?.toString() ?? '्';

    final result = StringBuffer();
    for (var i = 0; i < dataIn.length; i++) {
      final char = dataIn[i];
      if (char == anusvara && i > 0) {
        final prevChar = dataIn[i - 1];
        if (consonants.containsKey(prevChar)) {
          result.write(prevChar);
          result.write(virama);
          result.write(anusvara);
          continue;
        }
      }
      result.write(char);
    }
    return result.toString();
  }

  String fixLazyAnusvaara(
    String dataIn, {
    bool ignorePadaanta = true,
    bool omitYrl = false,
    bool omitSam = false,
  }) {
    final anusvara = data['yogavaahas']?['ं']?.toString() ?? 'ं';
    final consonants = getConsonants() ?? {};
    final result = StringBuffer();

    for (var i = 0; i < dataIn.length; i++) {
      final char = dataIn[i];

      if (char == anusvara && i > 0) {
        final prevChar = dataIn[i - 1];

        if (consonants.containsKey(prevChar)) {
          final following = i + 1 < dataIn.length ? dataIn[i + 1] : '';
          final followingConsonant = consonants.containsKey(following);

          if (!followingConsonant || i + 1 >= dataIn.length) {
            if (omitSam && prevChar == 'स') {
              result.write(char);
              continue;
            }
            if (omitYrl &&
                (prevChar == 'य' || prevChar == 'र' || prevChar == 'ल')) {
              result.write(char);
              continue;
            }
            if (ignorePadaanta) {
              result.write(char);
              continue;
            }
            final anusvaraDev = '\u0901';
            result.write(anusvaraDev);
            continue;
          }
        }
      }
      result.write(char);
    }

    return result.toString();
  }

  String fixLazyVisarga(String dataIn) {
    final visargas = data['yogavaahas']?['ः']?.toString() ?? 'ः';
    final result = dataIn;

    if (visargas.isEmpty) return result;

    final char1 = '\u1FD3';
    final char2 = '\u1FD4';

    return result
        .replaceAllMapped(
          RegExp('(?<=.)($visargas)(?= )'),
          (match) => char1,
        )
        .replaceAllMapped(
          RegExp('(?<=.)($visargas)(?= )'),
          (match) => char2,
        );
  }

  String approximateVisargas(String dataIn,
      {VisargaApproximation mode = VisargaApproximation.aha}) {
    final visarga = data['yogavaahas']?['ः']?.toString() ?? 'ः';
    if (visarga.isEmpty) return dataIn;

    if (mode == VisargaApproximation.h) {
      final virama = data['virama']?['']?.toString() ?? '्';
      return dataIn.replaceAll(visarga, 'ह$virama');
    } else {
      return dataIn.replaceAll(visarga, 'हि');
    }
  }

  String doVyanjanaSvaraJoin(String consonant, String vowel) {
    final virama = data['virama']?['']?.toString() ?? '्';

    final consonants = getConsonants() ?? {};
    final vowels = getVowels() ?? {};

    if (consonants.containsKey(consonant) ||
        (consonant.length > 1 &&
            vowels.containsKey(consonant[consonant.length - 1]))) {
      if (consonant != vowel && !vowels.containsKey(consonant)) {
        return consonant + virama + vowel;
      }
    }
    return consonant + vowel;
  }

  List<String> splitVyanjanasAndSvaras(String dataIn, {String? skipPattern}) {
    final consonants = getConsonants() ?? {};
    final vowels = getVowels() ?? {};
    final vowelMarks = getVowelMarks() ?? {};
    final virama = data['virama']?['']?.toString() ?? '्';
    final anusvara = data['yogavaahas']?['ं']?.toString() ?? 'ं';
    final visarga = data['yogavaahas']?['ः']?.toString() ?? 'ः';

    final result = <String>[];
    final buf = StringBuffer();
    var hadConsonant = false;

    for (var i = 0; i < dataIn.length; i++) {
      final char = dataIn[i];
      final remaining = dataIn.substring(i);

      if (skipPattern != null && remaining.startsWith(skipPattern)) {
        if (buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
          hadConsonant = false;
        }
        final match = RegExp(skipPattern).firstMatch(remaining);
        if (match != null) {
          result.add(match.group(0)!);
          i += match.group(0)!.length - 1;
          continue;
        }
      }

      if (consonants.containsKey(char)) {
        if (buf.isNotEmpty && hadConsonant) {
          result.add(buf.toString());
          buf.clear();
        }
        buf.write(char);
        hadConsonant = true;

        if (i + 1 < dataIn.length) {
          final nextChar = dataIn[i + 1];
          if (nextChar != virama &&
              !consonants.containsKey(nextChar) &&
              !vowels.containsKey(nextChar)) {
            result.add(buf.toString());
            buf.clear();
            hadConsonant = false;
          }
        }
      } else if (vowels.containsKey(char)) {
        if (hadConsonant && buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
          hadConsonant = false;
        }
        buf.write(char);
      } else if (vowelMarks.containsKey(char)) {
        buf.write(char);
      } else if (char == virama) {
        buf.write(char);
      } else if (char == anusvara || char == visarga) {
        buf.write(char);
      } else {
        if (buf.isNotEmpty) {
          result.add(buf.toString());
          buf.clear();
          hadConsonant = false;
        }
        buf.write(char);
      }
    }

    if (buf.isNotEmpty) {
      result.add(buf.toString());
    }

    return result;
  }

  String joinPostViraama(String dataIn) {
    final virama = data['virama']?['']?.toString() ?? '्';
    final viramaPattern = RegExp('$virama\\s*');
    return dataIn.replaceAll(viramaPattern, '');
  }

  String joinStrings(List<String> letters) {
    if (letters.isEmpty) return '';

    final consonants = getConsonants() ?? {};
    final vowels = getVowels() ?? {};
    final vowelMarks = getVowelMarks() ?? {};
    final virama = data['virama']?['']?.toString() ?? '्';

    final result = StringBuffer();
    var lastWasConsonant = false;

    for (var i = 0; i < letters.length; i++) {
      final letter = letters[i];

      if (letter.isEmpty) continue;

      final isConsonant = consonants.containsKey(letter);
      final endsWithVirama = letter.endsWith(virama);
      final isVowel =
          vowels.containsKey(letter) || vowelMarks.containsKey(letter);

      if (i > 0 && lastWasConsonant && !endsWithVirama) {
        if (isConsonant || isVowel) {
          result.write(virama);
        }
      }

      result.write(letter);
      lastWasConsonant = isConsonant || endsWithVirama;
    }

    return result.toString();
  }

  String applyRomanNumerals(String dataIn) {
    final devanagariDigits =
        '\u0966\u0967\u0968\u0969\u096A\u096B\u096C\u096D\u096E\u096F';
    const asciiDigits = '0123456789';

    final digitMap = <String, String>{};
    for (var i = 0; i < devanagariDigits.length; i++) {
      digitMap[devanagariDigits[i]] = asciiDigits[i];
    }

    var result = dataIn;
    for (final entry in digitMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  String dotForNumericIds(String dataIn) {
    final dotDevanagari = '।';
    final dotAscii = '.';

    return dataIn.replaceAll(dotDevanagari, dotAscii);
  }
}

class SchemeMap {
  final Scheme fromScheme;
  final Scheme toScheme;
  final Map<String, String> vowelMarks = {};
  final Map<String, String> virama = {};
  final Map<String, String> vowels = {};
  final Map<String, String> consonants = {};
  final Map<String, String> nonMarksViraama = {};
  final Map<String, String> accents = {};
  int maxKeyLengthFromScheme = 1;

  SchemeMap(this.fromScheme, this.toScheme) {
    _buildMappings();
  }

  void _buildMappings() {
    final fromData = fromScheme.data;
    final toData = toScheme.data;

    for (final group in fromData.keys) {
      if (group == 'alternates' ||
          group == 'accented_vowel_alternates' ||
          group.startsWith('approximate_') ||
          group.startsWith('extra_')) {
        continue;
      }
      if (!toData.containsKey(group)) {
        continue;
      }

      final Map<String, String> conjunctMap = {};
      final Map<String, dynamic> toGroup = {};
      toGroup.addAll(Map<String, dynamic>.from((toData[group] as Map?) ?? {}));
      toGroup.addAll(Map<String, dynamic>.from((toData['extra_$group'] as Map?) ?? {}));
      toGroup.addAll(Map<String, dynamic>.from((toData['approximate_$group'] as Map?) ?? {}));

      void processFromGroup(Map? groupData) {
        if (groupData == null) return;
        for (final entry in groupData.entries) {
          final key = entry.key;
          final fromSchemeSymbol = entry.value.toString();

          if (toGroup.containsKey(key)) {
            var toSchemeSymbol = toGroup[key]?.toString() ?? '';

            if (toSchemeSymbol.isEmpty &&
                group != 'virama' &&
                group != 'zwj' &&
                group != 'skip') {
              toSchemeSymbol = fromSchemeSymbol;
            }

            conjunctMap[fromSchemeSymbol] = toSchemeSymbol;
            if (fromSchemeSymbol.length > maxKeyLengthFromScheme) {
              maxKeyLengthFromScheme = fromSchemeSymbol.length;
            }

            final alternates = fromScheme.getAlternates();
            if (alternates != null && alternates.containsKey(fromSchemeSymbol)) {
              final altValue = alternates[fromSchemeSymbol];
              if (altValue is List) {
                for (final alt in altValue) {
                  final altStr = alt.toString();
                  conjunctMap[altStr] = toSchemeSymbol;
                  if (altStr.length > maxKeyLengthFromScheme) {
                    maxKeyLengthFromScheme = altStr.length;
                  }
                }
              }
            }
          }
        }
      }

      processFromGroup(fromData['approximate_$group'] as Map?);
      processFromGroup(fromData[group] as Map?);
      processFromGroup(fromData['extra_$group'] as Map?);

      if (group == 'vowel_marks' || group.endsWith('_vowel_marks')) {
        vowelMarks.addAll(conjunctMap);
      } else if (group == 'virama') {
        virama.addAll(conjunctMap);
      } else {
        nonMarksViraama.addAll(conjunctMap);
        if (group == 'consonants' || group.endsWith('_consonants')) {
          consonants.addAll(conjunctMap);
        } else if (group == 'vowels' || group.endsWith('_vowels')) {
          vowels.addAll(conjunctMap);
        } else if (group == 'accents') {
          accents.addAll(conjunctMap);
        }
      }
    }
  }

  @override
  String toString() {
    return 'SchemeMap(\n'
        '  vowels: $vowels,\n'
        '  vowelMarks: $vowelMarks,\n'
        '  virama: $virama,\n'
        '  consonants: $consonants\n'
        ')';
  }
}

final Map<String, Scheme> _schemesCache = {};

Scheme getScheme(String name) {
  if (_schemesCache.containsKey(name)) {
    return _schemesCache[name]!;
  }

  final schemeData = schemesData[name];
  if (schemeData == null) {
    throw ArgumentError('Scheme not found: $name');
  }

  final isRoman = schemeTypes[name] ?? true;

  final scheme = Scheme(
    name: name,
    isRoman: isRoman,
    data: schemeData.map((key, value) {
      if (value is Map) {
        return MapEntry(key, Map<String, dynamic>.from(value));
      }
      return MapEntry(key, <String, dynamic>{});
    }),
  );

  _schemesCache[name] = scheme;
  return scheme;
}

SchemeMap getSchemeMap(String fromName, String toName) {
  final fromScheme = getScheme(fromName);
  final toScheme = getScheme(toName);
  return SchemeMap(fromScheme, toScheme);
}

void initializeSchemes() {
  initSchemesData();
}

extension SchemeExtensions on Scheme {
  String toLayIndian(String text,
      {String jnReplacement = "GY", String tReplacement = "t"}) {
    var result = text;
    result = result.replaceAll('RR', 'ri');
    result = result.replaceAll('R', 'ri');
    result = result.replaceAll('LLi', 'lri');
    result = result.replaceAll('LLI', 'lri');
    result = result.replaceAll('jn', jnReplacement);
    result = result.replaceAll('x', 'ksh');
    if (tReplacement != "t") {
      result = result.replaceAll("t", tReplacement);
    }
    return result.toLowerCase();
  }

  String getStandardForm(String data) {
    var result = data;
    result = result.replaceAll('ŕ', 'ṛ');
    result = result.replaceAll('ṃ', 'ṃ');
    result = result.replaceAll('ŕ̥', 'ṛ̥');
    result = result.replaceAll('ṃ', 'ṃ');
    result = result.replaceAll('ṝ', 'ṝ');
    return result;
  }

  String getDoubleLettered(String data) {
    final vowels = getVowels() ?? {};
    final vowelMarks = getVowelMarks() ?? {};

    var result = data;
    for (final entry in vowels.entries) {
      final devVowel = entry.key;
      final romanValue = entry.value.toString();
      if (devVowel == 'आ') {
        result = result.replaceAll('A', 'aa');
        result = result.replaceAll(romanValue, 'aa');
      } else if (devVowel == 'ई') {
        result = result.replaceAll('I', 'ii');
        result = result.replaceAll(romanValue, 'ii');
      } else if (devVowel == 'ऊ') {
        result = result.replaceAll('U', 'uu');
        result = result.replaceAll(romanValue, 'uu');
      }
    }
    return result;
  }

  String markOffNonIndicInLine(String text) {
    final words = text.split(RegExp(r'\s+'));
    final processedWords = <String>[];

    for (final word in words) {
      processedWords.add(word);
    }

    return processedWords.join(' ');
  }

  String approximateFromIsoUrdu(String text, {bool addTerminalA = true}) {
    var result = text;

    final replacements = {
      '‘': '',
      'ʼ': '{}',
      '’': '{}',
      'oo': 'uu',
      'ee': 'ii',
      'ë': 'E',
      'ě': 'E',
      'e': 'ē',
      'o': 'ō',
      'ā': 'aa',
      'ī': 'ii',
      'ū': 'uu',
      'w': 'v',
      'ẕ': 'z',
      'ż': 'z',
      'ẓ': 'z',
      'ž': 'z',
      'ḳ': 'q',
      'ṣ': 's',
      's̱ẖ': 'sh',
      's̱': 't',
      'ẖ': 'h',
      'ḥ': 'h',
    };

    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }

    final vowelsPattern = RegExp(r"([aāeēiīoōuū])'");
    result = result.replaceAllMapped(vowelsPattern, (match) => match.group(1)!);

    final vowelsPattern2 = RegExp(r"'([aāeēiīoōuū])");
    result =
        result.replaceAllMapped(vowelsPattern2, (match) => match.group(1)!);

    result = result.replaceAll("'", "");
    result = result.replaceAllMapped(RegExp(r"'h"), (match) => "{}h");

    if (addTerminalA) {
      result = result.replaceAllMapped(
        RegExp(r'([kghncjzftdTDpbmyrlvsq])(?=\s|$|-)'),
        (match) => '${match.group(1)}a',
      );
    }

    return result;
  }

  static const _accentsPattern =
      r"[\u1CD0-\u1CE8\u1CF9\u1CFA\uA8E0-\uA8F1\u0951-\u0954\u0957]";

  String stripAccents(String text) {
    return text.replaceAll(RegExp(_accentsPattern), '');
  }

  int? getAdjacentSyllableIndex(
      int currentIndex, List<String> letters, int direction,
      {String? pausesPattern}) {
    final pauser =
        pausesPattern != null ? RegExp(pausesPattern) : RegExp(r'[।॥\n,;]+');

    var index = currentIndex + direction;
    while (index >= 0 && index < letters.length) {
      if (pauser.hasMatch(letters[index])) {
        return null;
      }
      final letter = letters[index];
      final consonants = getConsonants() ?? {};
      final vowels = getVowels() ?? {};

      for (final char in letter.runes) {
        final charStr = String.fromCharCode(char);
        if (consonants.containsKey(charStr) || vowels.containsKey(charStr)) {
          return index;
        }
      }
      index += direction;
    }
    return null;
  }

  List<String> getLetters() {
    final result = <String>[];
    final vowels = getVowels();
    final consonants = getConsonants();

    if (vowels != null) {
      result.addAll(vowels.values);
    }
    if (consonants != null) {
      result.addAll(consonants.values);
    }
    return result;
  }
}

String addAccentToPreviousSyllable({
  required Scheme scheme,
  required String text,
  required String oldAccent,
  String? newAccent,
  bool dropAtFirstSyllable = false,
  bool retainOldAccent = false,
}) {
  newAccent ??= oldAccent;
  final letters = scheme.splitVyanjanasAndSvaras(text);
  final outLetters = <String>[];
  final vowels = scheme['vowels'].values.map((v) => v.toString()).toList();
  final vowelsYogavaahas = vowels
    ..addAll(scheme['yogavaahas'].values.map((v) => v.toString()));
  var accentCarryover = '';

  for (var index = 0; index < letters.length; index++) {
    final letter = letters[index];
    if (letter.endsWith(oldAccent)) {
      var vowelPosition = -1;
      for (var i = outLetters.length - 1; i >= 0; i--) {
        final prevLetter = outLetters[i];
        if (prevLetter.isNotEmpty && vowelsYogavaahas.contains(prevLetter[0])) {
          vowelPosition = i;
          break;
        }
      }
      if (vowelPosition == -1) {
        if (!dropAtFirstSyllable) {
          accentCarryover += newAccent;
        }
      } else {
        outLetters[vowelPosition] += newAccent;
      }
      if (!retainOldAccent) {
        outLetters.add(letter.substring(0, letter.length - 1));
      } else {
        outLetters.add(letter);
      }
    } else {
      outLetters.add(letter);
    }
  }
  return accentCarryover + scheme.joinStrings(outLetters);
}

String setDiirghaSvaritas(
    {required Scheme scheme, required String text, String accent = '᳚'}) {
  final longVowels = scheme.longVowels;
  final vowelMarks = scheme.getVowelMarks() ?? {};
  final longVowelMarks =
      vowelMarks.values.where((v) => longVowels.contains(v)).toList();
  final yogavaahas =
      scheme['yogavaahas'].values.map((v) => v.toString()).toList();

  final vowelString = [...longVowels, ...longVowelMarks, ...yogavaahas].join();
  if (vowelString.isEmpty) return text;

  return text.replaceAllMapped(
      RegExp('(?<=[$vowelString]+)॑'), (match) => accent);
}

String toUsAccents({
  String? text,
  Scheme? scheme,
  String udatta = '᳓',
  String svaritaNew = '᳙',
  String pauses = r'[।॥\n,;]+',
  String skipPattern = r'\+\+\+\(.+?\)\+\+\+',
}) {
  if (text == null) return '';

  scheme ??= getScheme('devanagari');

  const sannatara = '॒';
  const svarita = '॑';

  if (!text.contains(svarita) &&
      !text.contains(sannatara) &&
      !text.contains('᳚') &&
      !text.contains('᳛')) {
    return text;
  }

  if (text.contains(svaritaNew) || text.contains(udatta)) {
    return text;
  }

  text = text.replaceAll(RegExp(r'[᳖᳚᳛]'), svarita);

  return text;
}
