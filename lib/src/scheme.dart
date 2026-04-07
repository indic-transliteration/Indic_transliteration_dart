import 'data/schemes.dart'
    show initSchemesData, schemesData, schemeTypes, devVowelToMarkMap;

/// Enum representing approximation modes for visarga (ः) character.
///
/// Visarga is a diacritical mark in Sanskrit that represents a breathing sound.
/// When converting between scripts, it may need to be approximated differently
/// depending on the target script's capabilities.
enum VisargaApproximation {
  /// Approximate visarga as 'aha' (हि) - inserts 'hi' after the preceding vowel.
  /// This is the default mode and preserves the traditional Sanskrit pronunciation.
  aha,

  /// Approximate visarga as 'h' (ह) - replaces visarga with a simple 'h' followed
  /// by virama if needed. This produces a simpler transliteration.
  h,
}

/// Mapping of ISO 639 language codes to their default Indic scripts.
///
/// This constant provides a convenient mapping between language codes and their
/// typical writing scripts. It's used to determine default scripts when
/// converting between languages.
///
/// Language codes mapped:
/// - 'sa' (Sanskrit) -> devanagari
/// - 'ta' (Tamil) -> tamil
/// - 'ka' (Kannada) -> kannada
/// - 'te' (Telugu) -> telugu
/// - 'hi' (Hindi) -> devanagari
/// - 'ma' (Marathi) -> devanagari
/// - 'ne' (Nepali) -> devanagari
/// - 'kok' (Konkani) -> devanagari
/// - 'as' (Assamese) -> assamese (falls back to bengali)
/// - 'ml' (Malayalam) -> malayalam
/// - 'bn' (Bengali) -> bengali
/// - 'gu' (Gujarati) -> gujarati
/// - 'pa' (Panjabi/Punjabi) -> panjabi (falls back to gurmukhi)
/// - 'or' (Odia/Oriya) -> oriya
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

/// Represents a transliteration scheme for Indic scripts or romanization.
///
/// A [Scheme] encapsulates the character mappings for a specific writing system,
/// including vowels, consonants, vowel marks, virama (halant), yogavaahas
/// (anusvara, visarga), symbols, and accents.
///
/// The scheme can represent either:
/// - A Brahmic (native Indic) script like Devanagari, Bengali, Tamil, etc.
/// - A romanization scheme like IAST, ITRANS, Harvard-Kyoto, etc.
///
/// The [isRoman] property indicates whether this is a romanization scheme
/// (true) or a native script (false).
///
/// Example:
/// ```dart
/// final scheme = getScheme('devanagari');
/// final vowels = scheme.getVowels(); // Get vowel mappings
/// final consonants = scheme.getConsonants(); // Get consonant mappings
/// ```
class Scheme {
  /// The name of this scheme (e.g., 'devanagari', 'iast', 'itrans').
  final String name;

  /// Whether this scheme is a romanization scheme (true) or a native script (false).
  final bool isRoman;

  /// The raw data map containing all character mappings for this scheme.
  /// Keys include: 'vowels', 'consonants', 'vowel_marks', 'virama', 'yogavaahas',
  /// 'symbols', 'accents', 'alternates', etc.
  final Map<String, Map<String, dynamic>> data;

  /// List of long vowel characters in this scheme, derived from the vowels map.
  /// Long vowels include: आ (ā), ई (ī), ऊ (ū), ॠ (ṝ), ए (e), ऐ (ai), ओ (o), औ (au).
  late final List<String> longVowels;

  /// Creates a new Scheme with the given name, romanization flag, and data.
  ///
  /// The constructor initializes the scheme by:
  /// 1. Extracting long vowels from the vowels map
  /// 2. For romanization schemes, deriving vowel_marks from vowels using devVowelToMarkMap
  ///
  /// [name] - The unique identifier for this scheme (e.g., 'devanagari', 'iast').
  ///
  /// [isRoman] - True if this is a romanization scheme, false for native scripts.
  ///
  /// [data] - A map containing character mappings for this scheme.
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

  /// Accesses the scheme data by key, returning an empty map if the key doesn't exist.
  ///
  /// [key] - The data key to access (e.g., 'vowels', 'consonants', 'virama').
  ///
  /// Returns the map of characters for that key, or an empty map if not found.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('devanagari');
  /// final vowelData = scheme['vowels']; // Get vowels map
  /// ```
  Map<String, dynamic> operator [](String key) => data[key] ?? {};

  /// Checks whether this scheme contains data for the given key.
  ///
  /// [key] - The data key to check (e.g., 'vowels', 'consonants', 'accents').
  ///
  /// Returns true if the scheme has data for this key, false otherwise.
  bool containsKey(String key) => data.containsKey(key);

  /// Gets the romanization for a specific vowel character.
  ///
  /// [key] - The vowel character (in Devanagari script, e.g., 'अ', 'आ', 'इ').
  ///
  /// Returns the romanization string, or null if not found.
  String? getVowel(String key) => data['vowels']?[key]?.toString();

  /// Gets the romanization for a specific vowel mark (matra).
  ///
  /// [key] - The vowel mark character (e.g., 'ा', 'ि', 'ी').
  ///
  /// Returns the romanization string, or null if not found.
  String? getVowelMark(String key) => data['vowel_marks']?[key]?.toString();

  /// Gets the romanization for a specific consonant.
  ///
  /// [key] - The consonant character (in Devanagari script, e.g., 'क', 'ख', 'ग').
  ///
  /// Returns the romanization string, or null if not found.
  String? getConsonant(String key) => data['consonants']?[key]?.toString();

  /// Gets the virama (halant) character for this scheme.
  ///
  /// [key] - The virama key (usually empty string '' for implicit virama).
  ///
  /// Returns the virama character, or null if not found.
  String? getVirama(String key) => data['virama']?[key]?.toString();

  /// Gets the yogavaaha character for a specific key.
  ///
  /// Yogavaahas include anusvara (ं), visarga (ः), chandrabindu (ँ), etc.
  ///
  /// [key] - The yogavaaha character key.
  ///
  /// Returns the romanization string, or null if not found.
  String? getYogavaaha(String key) => data['yogavaahas']?[key]?.toString();

  /// Gets the accent character for a specific key.
  ///
  /// Accents include svarita (॑), sannatara (॒), and Vedic accents.
  ///
  /// [key] - The accent character key.
  ///
  /// Returns the romanization string, or null if not found.
  String? getAccent(String key) => data['accents']?[key]?.toString();

  /// Gets the symbol character for a specific key.
  ///
  /// Symbols include om (ॐ), danda (।, ||), avagraha (ऽ), numerals, etc.
  ///
  /// [key] - The symbol character key.
  ///
  /// Returns the romanization string, or null if not found.
  String? getSymbol(String key) => data['symbols']?[key]?.toString();

  /// Gets the alternates map, which contains alternative representations
  /// for certain characters.
  ///
  /// Returns a map where keys are standard forms and values are lists of
  /// alternative representations, or null if alternates aren't defined.
  Map<String, dynamic>? getAlternates() => data['alternates'];

  /// Gets all vowel marks (matras) defined in this scheme.
  ///
  /// Returns a map where keys are Devanagari vowel mark characters and values
  /// are their romanizations, or null if vowel_marks aren't defined.
  ///
  /// Example:
  /// ```dart
  /// final marks = scheme.getVowelMarks();
  /// // Returns: {'ा': 'A', 'ि': 'i', 'ी': 'I', ...}
  /// ```
  Map<String, String>? getVowelMarks() {
    final marks = data['vowel_marks'];
    if (marks == null) return null;
    return marks.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets all vowels defined in this scheme.
  ///
  /// Returns a map where keys are Devanagari vowel characters and values
  /// are their romanizations, or null if vowels aren't defined.
  ///
  /// Example:
  /// ```dart
  /// final vowels = scheme.getVowels();
  /// // Returns: {'अ': 'a', 'आ': 'A', 'इ': 'i', ...}
  /// ```
  Map<String, String>? getVowels() {
    final vowels = data['vowels'];
    if (vowels == null) return null;
    return vowels.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets all consonants defined in this scheme.
  ///
  /// Returns a map where keys are Devanagari consonant characters and values
  /// are their romanizations, or null if consonants aren't defined.
  ///
  /// Example:
  /// ```dart
  /// final consonants = scheme.getConsonants();
  /// // Returns: {'क': 'k', 'ख': 'kh', 'ग': 'g', ...}
  /// ```
  Map<String, String>? getConsonants() {
    final consonants = data['consonants'];
    if (consonants == null) return null;
    return consonants.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets the virama map for this scheme.
  ///
  /// Virama (also called halant) is a diacritical mark that indicates
  /// the omission of the inherent vowel in a consonant.
  ///
  /// Returns a map where keys are virama characters and values are their
  /// romanizations (usually empty string), or null if virama isn't defined.
  Map<String, String>? getViramaMap() {
    final virama = data['virama'];
    if (virama == null) return null;
    return virama.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets all yogavaahas defined in this scheme.
  ///
  /// Yogavaahas are supplementary marks including:
  /// - Anusvara (ं) - represented as 'M' or 'ṃ'
  /// - Visarga (ः) - represented as 'H' or 'ḥ'
  /// - Chandrabindu (ँ) - represented as '.N' or '~'
  /// - Vedic accents and other marks
  ///
  /// Returns a map where keys are yogavaaha characters and values are their
  /// romanizations, or null if yogavaahas aren't defined.
  Map<String, String>? getYogavaahas() {
    final yogavaahas = data['yogavaahas'];
    if (yogavaahas == null) return null;
    return yogavaahas.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets all accents defined in this scheme.
  ///
  /// Accents include Vedic and Sanskrit tonal marks:
  /// - Svarita (॑) - rising tone
  /// - Sannatara (॒) - falling tone
  /// - Udatta, Anudatta, and other Vedic accents
  ///
  /// Returns a map where keys are accent characters and values are their
  /// romanizations, or null if accents aren't defined.
  Map<String, String>? getAccents() {
    final accents = data['accents'];
    if (accents == null) return null;
    return accents.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Gets accented vowel alternates defined in this scheme.
  ///
  /// These are alternative representations for vowels with diacritical
  /// accents (such as acute or grave accent marks in romanization).
  ///
  /// Returns a map where keys are standard accented vowels and values are
  /// lists of alternative representations, or null if not defined.
  ///
  /// Example:
  /// ```dart
  /// final alternates = scheme.getAccentedVowelAlternates();
  /// // Returns: {'á': ['á'], 'é': ['é'], 'à': ['à'], ...}
  /// ```
  Map<String, List<String>>? getAccentedVowelAlternates() {
    final alternates = data['accented_vowel_alternates'];
    if (alternates == null) return null;
    return alternates.map((k, v) => MapEntry(k, List<String>.from(v)));
  }

  /// Gets the shortcuts defined in this scheme.
  ///
  /// Shortcuts are abbreviated character sequences that expand to full
  /// representations. For example, in ITRANS, 'kSh' might be a shortcut
  /// for 'क्ष'.
  ///
  /// Returns a map where keys are shortcut sequences and values are their
  /// expanded forms, or null if shortcuts aren't defined.
  Map<String, String>? getShortcuts() {
    final shortcuts = data['shortcuts'];
    if (shortcuts == null) return null;
    return shortcuts.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Converts the sequence of 'o' + anusvara (or om with virama + ma)
  /// into the proper Om (ॐ) symbol.
  ///
  /// This handles the special case where the combination of 'o' vowel
  /// followed by anusvara should be rendered as the sacred Om symbol.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with Om sequences converted to the Om symbol.
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

  /// Applies shortcuts defined in this scheme to the input text.
  ///
  /// Shortcuts are abbreviated sequences that should be expanded. For example,
  /// '~nc' might be expanded to 'nc' in certain romanization schemes.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with shortcuts applied (replaced with their expanded forms).
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

  /// Reverses the application of shortcuts in the input text.
  ///
  /// This expands shortcut sequences back to their full forms, and also
  /// replaces accented vowel alternates with their standard forms.
  ///
  /// This is typically called before transliteration to normalize the input.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with shortcuts reversed (expanded back to original forms).
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

  /// Forces conversion of "lazy" anusvara (where anusvara appears after a consonant
  /// without proper virama) to explicit form with virama.
  ///
  /// In some writing conventions, anusvara appears after consonants without the
  /// explicit virama mark. This function forces the explicit form by inserting
  /// virama between the consonant and anusvara.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with lazy anusvara converted to explicit form.
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

  /// Fixes "lazy" anusvara based on Sanskrit grammar rules.
  ///
  /// Anusvara (ं) in Sanskrit can appear in different forms depending on
  /// context. This function converts lazy anusvara (that appears as a simple
  /// mark) to the appropriate form based on grammatical rules.
  ///
  /// Parameters:
  /// - [dataIn] - The input text to process.
  /// - [ignorePadaanta] - If true (default), ignores padaanta (word-final) position,
  ///   keeping the anusvara mark. If false, converts to explicit devanagari anusvara.
  /// - [omitYrl] - If true, omits anusvara after the letters य (y), र (r), ल (l).
  /// - [omitSam] - If true, omits anusvara after स (s) in 'sam' compounds.
  ///
  /// Returns the text with anusvara fixed according to the rules.
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

  /// Fixes "lazy" visarga to proper diacritic forms.
  ///
  /// Visarga (ः) appears in two forms in some contexts. This function
  /// converts visarga followed by space into the proper combining diacritical
  /// marks (U+1FD3 and U+1FD4) for better rendering.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with visarga converted to combining forms.
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

  /// Approximates visarga characters when converting to scripts that don't
  /// support the visarga diacritic.
  ///
  /// Visarga (ः) represents a breathing sound in Sanskrit. When the target
  /// script doesn't support this character, it needs to be approximated
  /// using alternative representations.
  ///
  /// Parameters:
  /// - [dataIn] - The input text to process.
  /// - [mode] - The approximation mode:
  ///   - [VisargaApproximation.aha] (default): Converts to 'हि' (hi)
  ///   - [VisargaApproximation.h]: Converts to 'ह' with virama if needed
  ///
  /// Returns the text with visarga approximated.
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

  /// Joins a consonant with a vowel, inserting virama if needed.
  ///
  /// When a consonant is followed by a vowel that isn't the inherent 'a',
  /// this function properly joins them using virama.
  ///
  /// [consonant] - The consonant character.
  /// [vowel] - The vowel character.
  ///
  /// Returns the joined string, with virama inserted between consonant
  /// and vowel if the vowel is not the inherent vowel.
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

  /// Splits text into individual letters (vyanjanas and svaras).
  ///
  /// This parses the input text and splits it into a list of individual
  /// characters, properly handling:
  /// - Consonants (vyanjanas)
  /// - Vowels (svaras)
  /// - Vowel marks (matras)
  /// - Virama (halant)
  /// - Anusvara (ं) and Visarga (ः)
  ///
  /// Parameters:
  /// - [dataIn] - The input text to split.
  /// - [skipPattern] - Optional regex pattern for text to skip during splitting.
  ///
  /// Returns a list of individual letters.
  ///
  /// Example:
  /// ```dart
  /// final letters = scheme.splitVyanjanasAndSvaras('हिंदी');
  /// // Returns: ['हिं', 'दी'] or similar segmentation
  /// ```
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

  /// Removes whitespace after virama in the input text.
  ///
  /// In some transliteration scenarios, virama might be followed by spaces.
  /// This function removes those spaces to create proper conjunct formations.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with spaces after virama removed.
  String joinPostViraama(String dataIn) {
    final virama = data['virama']?['']?.toString() ?? '्';
    final viramaPattern = RegExp('$virama\\s*');
    return dataIn.replaceAll(viramaPattern, '');
  }

  /// Joins a list of individual letters back into a single string.
  ///
  /// This is the inverse operation of [splitVyanjanasAndSvaras]. It takes
  /// a list of letters and properly joins them, inserting virama where needed
  /// between consecutive consonants.
  ///
  /// [letters] - A list of individual letters to join.
  ///
  /// Returns the joined string with proper conjunct formations.
  ///
  /// Example:
  /// ```dart
  /// final letters = ['क', '्', 'र'];
  /// final result = scheme.joinStrings(letters); // Returns 'क्र'
  /// ```
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

  /// Converts Devanagari numerals (०-९) to ASCII digits (0-9).
  ///
  /// This is useful for processing numeric content in Devanagari text,
  /// converting it to a more universally readable format.
  ///
  /// [dataIn] - The input text containing Devanagari numerals.
  ///
  /// Returns the text with numerals converted to ASCII digits.
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

  /// Replaces Devanagari danda (।) with ASCII period (.) for numeric IDs.
  ///
  /// In Devanagari numbering, danda (the vertical bar) is used as a separator.
  /// This function converts it to ASCII period for systems that expect
  /// ASCII punctuation.
  ///
  /// [dataIn] - The input text to process.
  ///
  /// Returns the text with danda replaced by period.
  String dotForNumericIds(String dataIn) {
    final dotDevanagari = '।';
    final dotAscii = '.';

    return dataIn.replaceAll(dotDevanagari, dotAscii);
  }
}

/// Represents a mapping between two transliteration schemes.
///
/// A [SchemeMap] contains the character mappings needed to transliterate
/// text from one scheme to another. It is built from a source [Scheme]
/// (fromScheme) and a target [Scheme] (toScheme).
///
/// The mapping includes:
/// - vowelMarks: Mappings for vowel signs (matras)
/// - virama: Mappings for virama (halant)
/// - vowels: Mappings for standalone vowels
/// - consonants: Mappings for consonants
/// - nonMarksViraama: Other character mappings
/// - accents: Mappings for accent marks
///
/// The [maxKeyLengthFromScheme] indicates the maximum length of keys in
/// the source scheme, used for optimal token matching during transliteration.
class SchemeMap {
  /// The source scheme to transliterate from.
  final Scheme fromScheme;

  /// The target scheme to transliterate to.
  final Scheme toScheme;

  /// Map of vowel marks (matras) from source to target scheme.
  /// Keys are source vowel marks, values are target vowel marks.
  final Map<String, String> vowelMarks = {};

  /// Map of virama (halant) from source to target scheme.
  final Map<String, String> virama = {};

  /// Map of standalone vowels from source to target scheme.
  final Map<String, String> vowels = {};

  /// Map of consonants from source to target scheme.
  final Map<String, String> consonants = {};

  /// Map of non-mark characters (excluding vowel marks and virama)
  /// from source to target scheme.
  final Map<String, String> nonMarksViraama = {};

  /// Map of accent marks from source to target scheme.
  final Map<String, String> accents = {};

  /// The maximum length of keys in the source scheme.
  /// Used for optimal token matching during transliteration.
  int maxKeyLengthFromScheme = 1;

  /// Creates a new SchemeMap for transliteration between two schemes.
  ///
  /// The constructor builds the character mapping tables by comparing the
  /// source and target scheme data, including regular, extra, and approximate
  /// character groups.
  ///
  /// [fromScheme] - The source scheme to transliterate from.
  /// [toScheme] - The target scheme to transliterate to.
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
      toGroup.addAll(
          Map<String, dynamic>.from((toData['extra_$group'] as Map?) ?? {}));
      toGroup.addAll(Map<String, dynamic>.from(
          (toData['approximate_$group'] as Map?) ?? {}));

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
            if (alternates != null &&
                alternates.containsKey(fromSchemeSymbol)) {
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

/// Cache of Scheme objects for performance.
final Map<String, Scheme> _schemesCache = {};

/// Gets a Scheme by name, using a cache for performance.
///
/// This function retrieves the scheme with the given name from the
/// schemes data. The result is cached for subsequent lookups.
///
/// [name] - The name of the scheme (e.g., 'devanagari', 'iast', 'itrans').
///
/// Returns the [Scheme] object for the given name.
///
/// Throws [ArgumentError] if the scheme is not found.
///
/// Example:
/// ```dart
/// final scheme = getScheme('devanagari');
/// final vowels = scheme.getVowels();
/// ```
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

/// Creates a SchemeMap for transliteration between two schemes.
///
/// This is a convenience function that gets the schemes and creates
/// a mapping between them.
///
/// [fromName] - The name of the source scheme.
/// [toName] - The name of the target scheme.
///
/// Returns a [SchemeMap] ready for transliteration.
///
/// Example:
/// ```dart
/// final map = getSchemeMap('devanagari', 'iast');
/// final result = transliterate('हिंदी', schemeMap: map);
/// ```
SchemeMap getSchemeMap(String fromName, String toName) {
  final fromScheme = getScheme(fromName);
  final toScheme = getScheme(toName);
  return SchemeMap(fromScheme, toScheme);
}

/// Initializes the schemes data if not already initialized.
///
/// This function must be called before using any transliteration
/// functions if the schemes data has not been initialized yet.
/// It loads all the scheme definitions from the internal data.
///
/// In most cases, this is called automatically by the transliterate()
/// function, but can be called explicitly if needed.
void initializeSchemes() {
  initSchemesData();
}

/// Extension methods on [Scheme] for additional transliteration operations.
extension SchemeExtensions on Scheme {
  /// Converts text to "Lay Indian" format.
  ///
  /// This transforms romanized text to a simplified representation that
  /// uses ASCII characters for common Sanskrit phonetic elements.
  ///
  /// Parameters:
  /// - [text] - The input text to convert.
  /// - [jnReplacement] - Replacement for 'jn' cluster (default: 'GY').
  /// - [tReplacement] - Replacement for 't' character (default: 't').
  ///
  /// Returns the text in Lay Indian format.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('iast');
  /// final result = scheme.toLayIndian('jnana'); // Returns 'gyana'
  /// ```
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

  /// Gets the standard form of romanized text.
  ///
  /// This normalizes text by replacing non-standard characters with their
  /// standard equivalents. For example, it replaces ŕ with ṛ, and fixes
  /// various encoding inconsistencies.
  ///
  /// [data] - The input text to normalize.
  ///
  /// Returns the text in standard form.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('iast');
  /// final result = scheme.getStandardForm('ŕ'); // Returns 'ṛ'
  /// ```
  String getStandardForm(String data) {
    var result = data;
    result = result.replaceAll('ŕ', 'ṛ');
    result = result.replaceAll('ṃ', 'ṃ');
    result = result.replaceAll('ŕ̥', 'ṛ̥');
    result = result.replaceAll('ṃ', 'ṃ');
    result = result.replaceAll('ṝ', 'ṝ');
    return result;
  }

  /// Expands double-letter vowel representations in the text.
  ///
  /// In some romanization schemes, long vowels can be represented by
  /// double letters (e.g., 'aa' for ā, 'ii' for ī, 'uu' for ū).
  /// This method expands these to their full double-letter form.
  ///
  /// [data] - The input text to process.
  ///
  /// Returns the text with double-letter vowels expanded.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('iast');
  /// final result = scheme.getDoubleLettered('A'); // Returns 'aa'
  /// ```
  String getDoubleLettered(String data) {
    final vowels = getVowels() ?? {};

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

  /// Marks off non-Indic characters in a line of text.
  ///
  /// This method processes text and identifies non-Indic characters,
  /// though currently it returns the words as-is with minimal processing.
  ///
  /// [text] - The input text to process.
  ///
  /// Returns the processed text with words preserved.
  String markOffNonIndicInLine(String text) {
    final words = text.split(RegExp(r'\s+'));
    final processedWords = <String>[];

    for (final word in words) {
      processedWords.add(word);
    }

    return processedWords.join(' ');
  }

  /// Approximates text from ISO 15919 Urdu representation to ITRANS.
  ///
  /// This method converts text using ISO 15919 conventions for Urdu
  /// into a format compatible with ITRANS romanization.
  ///
  /// Parameters:
  /// - [text] - The input text in ISO Urdu format.
  /// - [addTerminalA] - If true (default), adds terminal 'a' to words
  ///   ending in consonants.
  ///
  /// Returns the text approximated to ITRANS format.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('iso');
  /// final result = scheme.approximateFromIsoUrdu('qahwa'); // Returns 'qahew'
  /// ```
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

  /// Regex pattern for matching Indic accent characters.
  ///
  /// This matches Vedic and Sanskrit accent marks in the Unicode ranges:
  /// - U+1CD0 to U+1CE8 (Vedic accents)
  /// - U+1CF9 to U+1CFA (Vedic tone marks)
  /// - U+A8E0 to U+A8F1 (Devanagari extended)
  /// - U+0951 to U+0954 (Devanagari accents)
  /// - U+0957 (additional mark)
  static const _accentsPattern =
      r"[\u1CD0-\u1CE8\u1CF9\u1CFA\uA8E0-\uA8F1\u0951-\u0954\u0957]";

  /// Removes all accent marks from the text.
  ///
  /// This strips Vedic and Sanskrit tonal accents (svarita, sannatara, etc.)
  /// from the input text, returning plain text without diacritical marks.
  ///
  /// [text] - The input text with accents.
  ///
  /// Returns the text with all accents removed.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('devanagari');
  /// final result = scheme.stripAccents('हिंदी॑'); // Returns 'हिंदी'
  /// ```
  String stripAccents(String text) {
    return text.replaceAll(RegExp(_accentsPattern), '');
  }

  /// Gets the index of an adjacent syllable in the given direction.
  ///
  /// This method finds the next syllable in the specified direction by
  /// skipping over pause characters (dandas, commas, semicolons, newlines).
  ///
  /// Parameters:
  /// - [currentIndex] - The index to start searching from.
  /// - [letters] - A list of letters to search through.
  /// - [direction] - The direction to search: -1 for previous, 1 for next.
  /// - [pausesPattern] - Optional custom regex pattern for pause characters.
  ///
  /// Returns the index of the adjacent syllable, or null if no valid
  /// syllable is found in that direction.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('devanagari');
  /// final letters = scheme.splitVyanjanasAndSvaras('हिंदी। वन्दे');
  /// final index = scheme.getAdjacentSyllableIndex(0, letters, 1); // Returns 2
  /// ```
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

  /// Gets all letters (vowels and consonants) defined in this scheme.
  ///
  /// Returns a list of all vowel and consonant character values in this scheme.
  /// This is useful for iterating over all possible letters.
  ///
  /// Returns a list of strings representing all vowels and consonants.
  ///
  /// Example:
  /// ```dart
  /// final scheme = getScheme('devanagari');
  /// final letters = scheme.getLetters();
  /// // Returns: ['a', 'A', 'i', 'I', 'u', 'U', 'k', 'kh', 'g', ...]
  /// ```
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

/// Adds an accent to the previous syllable in text.
///
/// This function processes text and moves an accent mark from a syllable
/// to the preceding vowel. This is useful for handling Vedic accent
/// propagation rules.
///
/// Parameters:
/// - [scheme] - The [Scheme] to use for processing.
/// - [text] - The input text with accents.
/// - [oldAccent] - The accent character to look for (e.g., '॑').
/// - [newAccent] - The accent to add (defaults to oldAccent if not specified).
/// - [dropAtFirstSyllable] - If true, drops the accent at the first syllable.
/// - [retainOldAccent] - If true, retains the old accent in the output.
///
/// Returns the text with accent moved to the previous syllable.
///
/// Example:
/// ```dart
/// final result = addAccentToPreviousSyllable(
///   scheme: getScheme('devanagari'),
///   text: 'हिंदी॑',
///   oldAccent: '॑',
/// );
/// ```
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

/// Converts long svarita (॑) accents to a different accent mark.
///
/// In some transliteration conventions, the long svarita accent needs
/// to be converted to a different mark. This function finds long vowels
/// followed by svarita and replaces the svarita with the specified accent.
///
/// Parameters:
/// - [scheme] - The [Scheme] to use for identifying long vowels.
/// - [text] - The input text with svarita accents.
/// - [accent] - The replacement accent character (default: '᳚').
///
/// Returns the text with svarita replaced on long vowel syllables.
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

/// Converts US-style Vedic accents to standard Vedic accents.
///
/// This function converts text using US keyboard-friendly accent
/// representations to standard Devanagari Vedic accent marks.
///
/// Parameters:
/// - [text] - The input text with US-style accents (can be null).
/// - [scheme] - The [Scheme] to use (defaults to devanagari).
/// - [udatta] - The udatta accent character (default: '᳓').
/// - [svaritaNew] - The new svarita character (default: '᳙').
/// - [pauses] - Regex pattern for pause characters (default: '[।॥\n,;]+').
/// - [skipPattern] - Pattern for text to skip (default: r'\+\+\+\(.+?\)\+\+\+').
///
/// Returns the text with standardized Vedic accents, or empty string if text is null.
///
/// Example:
/// ```dart
/// final result = toUsAccents(text: 'test᳚text', scheme: getScheme('devanagari'));
/// ```
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
