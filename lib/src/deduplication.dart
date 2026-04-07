import '../transliterate.dart' show transliterate;

/// Generates a deduplication key for text using approximate matching.
///
/// This function creates a normalized key that can be used for approximate
/// text matching and deduplication. It:
/// 1. Strips non-Devanagari characters
/// 2. Removes whitespace and punctuation
/// 3. Removes Vedic accents and om symbols
/// 4. Normalizes nasal sounds (anusvara)
/// 5. Converts to optitrans romanization for consistent comparison
///
/// The resulting key allows for approximate matching where slight variations
/// in spelling or encoding will still match.
///
/// Parameters:
/// - [text] - The input text to create a key for.
/// - [encodingScheme] - The encoding scheme to use (default: 'devanagari').
///   Currently only 'devanagari' is fully supported.
///
/// Returns a normalized key string for approximate matching.
///
/// Example:
/// ```dart
/// // These might produce the same key despite slight differences
/// final key1 = getApproxDeduplicatingKey('हिंदी');
/// final key2 = getApproxDeduplicatingKey('हिन्दी');
/// // Both keys would be similar for matching purposes
/// ```
String getApproxDeduplicatingKey(String text,
    {String encodingScheme = 'devanagari'}) {
  if (encodingScheme == 'devanagari') {
    var key = text;

    key = key.replaceAll(RegExp(r'[^\u0900-\u097F]'), '');
    key = key.replaceAll(RegExp(r'\s'), '');
    key = key.replaceAll(RegExp(r'\p{P}', unicode: true), '');
    key = key.replaceAll(RegExp(r'[।॥॰ऽ]|[॑-॔]'), '');
    key = key.replaceAll(RegExp(r'[यरल]्ँ'), 'म');
    key = key.replaceAll(RegExp(r'[ङञणन]'), 'म');
    key = key.replaceAll(RegExp(r'[ँं]'), 'म');
    key = key.replaceAll('ॐ', 'ओम');
    key = key.replaceAll(RegExp(r'[ळऴ]'), 'ल');

    key = transliterate(key, fromScheme: encodingScheme, toScheme: 'optitrans');
    return key;
  } else {
    return text.replaceAll(RegExp(r'\s'), '');
  }
}
