import 'data/schemes.dart'
    show initSchemesData, schemesData, schemeTypes, devVowelToMarkMap;

enum VisargaApproximation { aha, h }

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
    if (shortcuts == null) return dataIn;

    var result = dataIn;
    for (final entry in shortcuts.entries) {
      final key = entry.key;
      final shortcut = entry.value;
      if (shortcut.contains(key)) {
        result = result.replaceAll(shortcut, key);
      }
      result = result.replaceAll(shortcut, key);
    }
    return result;
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
  final int maxKeyLengthFromScheme;

  SchemeMap(this.fromScheme, this.toScheme)
    : maxKeyLengthFromScheme = _calculateMaxKeyLength(fromScheme) {
    _buildMappings();
  }

  static int _calculateMaxKeyLength(Scheme scheme) {
    int maxLen = 1;
    for (final group in scheme.data.values) {
      for (final key in group.keys) {
        if (key.length > maxLen) {
          maxLen = key.length;
        }
      }
    }
    return maxLen;
  }

  void _buildMappings() {
    final fromData = fromScheme.data;
    final toData = toScheme.data;

    for (final group in fromData.keys) {
      if (group == 'alternates' || group == 'accented_vowel_alternates') {
        continue;
      }
      if (!toData.containsKey(group)) {
        continue;
      }

      final Map<String, String> conjunctMap = {};
      final fromGroup = fromData[group] ?? {};
      final toGroup = toData[group] ?? {};

      for (final entry in fromGroup.entries) {
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

          final alternates = fromScheme.getAlternates();
          if (alternates != null && alternates.containsKey(fromSchemeSymbol)) {
            final altValue = alternates[fromSchemeSymbol];
            if (altValue is List) {
              for (final alt in altValue) {
                conjunctMap[alt.toString()] = toSchemeSymbol;
              }
            }
          }
        }
      }

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
