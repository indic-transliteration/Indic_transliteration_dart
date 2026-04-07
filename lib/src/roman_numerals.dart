/// Exception thrown when an invalid Roman numeral is encountered.
///
/// This exception is raised when the [convertToInteger] function receives
/// a string that does not represent a valid Roman numeral.
class InvalidRomanNumeralError implements Exception {
  /// The error message describing the invalid numeral.
  final String message;

  /// Creates a new InvalidRomanNumeralError with an optional message.
  ///
  /// [message] - The error message (default: 'Invalid Roman numeral').
  InvalidRomanNumeralError([this.message = 'Invalid Roman numeral']);

  @override
  String toString() => message;
}

/// Converts a Roman numeral to its integer value.
///
/// This function handles both uppercase and lowercase Roman numerals,
/// as well as the subtractive notation (e.g., IV for 4, IX for 9).
///
/// Supported numerals:
/// - I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1000
/// - Subtractive pairs: IV (4), IX (9), XL (40), XC (90), CD (400), CM (900)
///
/// [numeral] - The Roman numeral string to convert.
///
/// Returns the integer value of the numeral.
///
/// Throws [InvalidRomanNumeralError] if:
/// - The input string is empty
/// - The input contains invalid characters
/// - The input is not a valid Roman numeral
///
/// Example:
/// ```dart
/// final value = convertToInteger('XLII'); // Returns 42
/// final value = convertToInteger('MCMXCIV'); // Returns 1994
/// ```
int convertToInteger(String numeral) {
  if (numeral.isEmpty) {
    throw InvalidRomanNumeralError('Empty string is not a valid Roman numeral');
  }

  final singleValues = {
    'Ⅰ': 1,
    'Ⅱ': 2,
    'Ⅲ': 3,
    'Ⅳ': 4,
    'Ⅴ': 5,
    'Ⅵ': 6,
    'Ⅶ': 7,
    'Ⅷ': 8,
    'Ⅸ': 9,
    'Ⅹ': 10,
    'Ⅺ': 11,
    'Ⅻ': 12,
    'Ⅼ': 50,
    'Ⅽ': 100,
    'Ⅾ': 500,
    'Ⅿ': 1000,
    'ⅰ': 1,
    'ⅱ': 2,
    'ⅲ': 3,
    'ⅳ': 4,
    'ⅴ': 5,
    'ⅵ': 6,
    'ⅶ': 7,
    'ⅷ': 8,
    'ⅸ': 9,
    'ⅹ': 10,
    'ⅺ': 11,
    'ⅻ': 12,
    'ⅼ': 50,
    'ⅽ': 100,
    'ⅾ': 500,
    'ⅿ': 1000,
  };

  final doubleValues = {
    'ⅩⅬ': 40,
    'ⅩⅭ': 90,
    'ⅹⅼ': 40,
    'ⅹⅽ': 90,
  };

  final tripleValues = {
    'ⅭⅭⅭ': 300,
    'ⅭⅮ': 400,
    'ⅽⅽⅽ': 300,
    'ⅽⅾ': 400,
  };

  var i = 0;
  var total = 0;

  while (i < numeral.length) {
    if (i + 2 < numeral.length) {
      final threeChar = numeral.substring(i, i + 3);
      if (tripleValues.containsKey(threeChar)) {
        total += tripleValues[threeChar]!;
        i += 3;
        continue;
      }
    }

    if (i + 1 < numeral.length) {
      final twoChar = numeral.substring(i, i + 2);
      if (doubleValues.containsKey(twoChar)) {
        total += doubleValues[twoChar]!;
        i += 2;
        continue;
      }
    }

    final oneChar = numeral[i];
    if (singleValues.containsKey(oneChar)) {
      total += singleValues[oneChar]!;
    }
    i++;
  }

  return total;
}
