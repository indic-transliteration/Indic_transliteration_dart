import '../transliterate.dart' show transliterate;

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
