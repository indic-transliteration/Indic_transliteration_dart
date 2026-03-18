import 'dart:io';
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main(List<String> arguments) {
  String? fromScheme;
  String? toScheme;
  String? inputFile;
  String? outputFile;

  for (int i = 0; i < arguments.length; i++) {
    switch (arguments[i]) {
      case '-f':
      case '--from':
        if (i + 1 < arguments.length) {
          fromScheme = arguments[++i];
        }
        break;
      case '-t':
      case '--to':
        if (i + 1 < arguments.length) {
          toScheme = arguments[++i];
        }
        break;
      case '-i':
      case '--input-file':
        if (i + 1 < arguments.length) {
          inputFile = arguments[++i];
        }
        break;
      case '-o':
      case '--output-file':
        if (i + 1 < arguments.length) {
          outputFile = arguments[++i];
        }
        break;
      case '-h':
      case '--help':
        printHelp();
        exit(0);
        break;
    }
  }

  if (fromScheme == null ||
      toScheme == null ||
      inputFile == null ||
      outputFile == null) {
    printHelp();
    exit(1);
  }

  initializeSchemes();

  try {
    final input = File(inputFile).readAsStringSync();
    final output =
        transliterate(input, fromScheme: fromScheme, toScheme: toScheme);
    File(outputFile).writeAsStringSync(output);
    print(
        'Successfully converted $inputFile ($fromScheme) to $outputFile ($toScheme)');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void printHelp() {
  print(
      'Usage: dart convert_file.dart -f <from_scheme> -t <to_scheme> -i <input_file> -o <output_file>');
  print('');
  print('Options:');
  print(
      '  -f, --from        Source transliteration scheme (e.g., slp1, iast, hk, itrans)');
  print(
      '  -t, --to          Destination transliteration scheme (e.g., devanagari, bengali, iast)');
  print('  -i, --input-file  Input file path');
  print('  -o, --output-file Output file path');
  print('  -h, --help        Show this help message');
  print('');
  print('Example:');
  print(
      '  dart convert_file.dart -f slp1 -t devanagari -i input.txt -o output.txt');
  print('');
  print('Available schemes:');
  print('  Roman: hk, iast, itrans, slp1, velthuis, wx, kolkata_v2, etc.');
  print(
      '  Brahmic: devanagari, bengali, gujarati, gurmukhi, kannada, malayalam, oriya, tamil, telugu, etc.');
}
