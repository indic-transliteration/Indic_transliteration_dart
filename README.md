# indic_transliteration_dart

**Version: 2.3.79**

A Dart library for transliterating Indic scripts and romanizations. This is a Dart port of the [indic_transliteration_py](https://github.com/indic-transliteration/indic_transliteration_py) library.

## License

This library is licensed under the [GNU General Public License v3.0](LICENSE).

## Supported Platforms

This package works on all Dart platforms:
- **Dart VM** (standalone Dart applications)
- **Flutter** (iOS, Android, Web, Desktop)
- **Web** (browser-based Dart applications)

## Features

- Transliterate between various Indic scripts (Devanagari, Bengali, Gujarati, Gurmukhi, Kannada, Malayalam, Oriya, Tamil, Telugu, etc.)
- Convert between romanization schemes (IAST, Harvard-Kyoto, ITRANS, SLP1, Velthuis, WX, etc.)
- Automatic script detection
- Support for toggles and suspended sections in text
- Works on all Dart platforms (Web, Flutter, VM)

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  indic_transliteration_dart: ^2.3.79
```

Or reference it from git:

```yaml
dependencies:
  indic_transliteration_dart:
    git:
      url: https://github.com/indic-transliteration/indic_transliteration_dart.git
```

## Quick Start

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  // Initialize the scheme data (required before first use)
  initializeSchemes();
  
  // Transliterate from IAST to Devanagari
  final result = transliterate('rāma', fromScheme: iast, toScheme: devanagari);
  print(result); // राम
}
```

## API Documentation

### Initialization

Before using any transliteration functions, you must initialize the scheme data:

```dart
initializeSchemes();
```

### Main Functions

#### `transliterate`

The primary function for transliterating text between scripts.

```dart
String transliterate(
  String data, {
  String? fromScheme,
  String? toScheme,
  SchemeMap? schemeMap,
  Map<String, String> togglers = const {},
  Set<String> suspendOn = const {},
  Set<String> suspendOff = const {},
  String maybeUseDravidianVariant = 'no',
})
```

**Parameters:**
- `data` (String): The text to transliterate
- `fromScheme` (String?, optional): Source scheme name. If not provided, auto-detected
- `toScheme` (String?, required if schemeMap not provided): Target scheme name
- `schemeMap` (SchemeMap?, optional): Pre-computed SchemeMap for better performance
- `togglers` (Map<String, String>, optional): Token pairs that toggle transliteration on/off
- `suspendOn` (Set<String>, optional): Tokens that suspend transliteration
- `suspendOff` (Set<String>, optional): Tokens that resume transliteration after suspend
- `maybeUseDravidianVariant` (String, optional): 'no', 'yes', or 'force' for Dravidian variants

**Returns:** The transliterated string

#### `detect`

Automatically detects the script or romanization scheme of a given text.

```dart
String detect(String text)
```

**Parameters:**
- `text` (String): The text to analyze

**Returns:** The detected scheme name (e.g., 'devanagari', 'iast', 'hk')

#### `getScheme`

Gets a Scheme object by name.

```dart
Scheme getScheme(String name)
```

#### `getSchemeMap`

Creates a SchemeMap for transliteration between two schemes.

```dart
SchemeMap getSchemeMap(String fromName, String toName)
```

### Scheme Constants

#### Brahmic Scripts

| Constant | Value |
|----------|-------|
| `devanagari` | 'devanagari' |
| `bengali` | 'bengali' |
| `gujarati` | 'gujarati' |
| `gurmukhi` | 'gurmukhi' |
| `kannada` | 'kannada' |
| `malayalam` | 'malayalam' |
| `oriya` | 'oriya' |
| `tamil` | 'tamil' |
| `tamilSup` | 'tamil_superscripted' |
| `tamilSub` | 'tamil_subscripted' |
| `grantha` | 'grantha' |
| `telugu` | 'telugu' |

#### Roman Schemes

| Constant | Value |
|----------|-------|
| `hk` | 'hk' |
| `hkDravidian` | 'hk_dravidian' |
| `iast` | 'iast' |
| `iso` | 'iso' |
| `isoVedic` | 'iso_vedic' |
| `itrans` | 'itrans' |
| `itransDravidian` | 'itrans_dravidian' |
| `titus` | 'titus' |
| `optitrans` | 'optitrans' |
| `optitransDravidian` | 'optitrans_dravidian' |
| `kolkata` | 'kolkata_v2' |
| `slp1` | 'slp1' |
| `velthuis` | 'velthuis' |
| `wx` | 'wx' |

## Usage Examples

### Basic Transliteration

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Roman to Devanagari
  print(transliterate('rāma', fromScheme: iast, toScheme: devanagari)); // राम
  print(transliterate('rAma', fromScheme: hk, toScheme: devanagari));   // राम
  print(transliterate('raama', fromScheme: itrans, toScheme: devanagari)); // राम
  print(transliterate('rAma', fromScheme: slp1, toScheme: devanagari)); // राम
  
  // Devanagari to Roman
  print(transliterate('राम', fromScheme: devanagari, toScheme: iast)); // rāma
  print(transliterate('राम', fromScheme: devanagari, toScheme: hk));    // rAma
  
  // Brahmic to Brahmic
  print(transliterate('রাম', fromScheme: bengali, toScheme: devanagari)); // राम
}
```

### Auto-Detection

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Auto-detect the script
  print(detect('राम'));    // devanagari
  print(detect('রাম'));    // bengali
  print(detect('rāma'));   // iast
  print(detect('rAma'));   // hk
  print(detect('raama'));  // itrans
  
  // Auto-detect source scheme
  final result = transliterate('rAma', toScheme: devanagari);
  print(result); // राम (auto-detected as HK)
}
```

### Using Toggles

Toggles allow you to preserve text without transliteration.

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Use ## as toggle marker
  final result = transliterate(
    'akSa##kSa##ra',
    fromScheme: hk,
    toScheme: devanagari,
    togglers: {'##': '##'},
  );
  print(result); // अक्षkSaर
}
```

### Using Suspend

Suspend allows you to mark sections that should not be transliterated.

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Use < and > as suspend markers
  final result = transliterate(
    '<p>nara iti</p>',
    fromScheme: hk,
    toScheme: devanagari,
    suspendOn: {'<'},
    suspendOff: {'>'},
  );
  print(result); // <p>नर इसि</p>
}
```

### Pre-computed SchemeMap

For better performance when transliterating multiple times:

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Create scheme map once
  final schemeMap = getSchemeMap(hk, devanagari);
  
  // Reuse the scheme map
  print(transliterate('rAma', schemeMap: schemeMap)); // राम
  print(transliterate('kRShNa', schemeMap: schemeMap)); // कृष्ण
}
```

### Dravidian Variants

Some schemes have Dravidian-specific variants:

```dart
import 'package:indic_transliteration_dart/indic_transliteration_dart.dart';

void main() {
  initializeSchemes();
  
  // Use Dravidian variant when detected or forced
  final result = transliterate(
    'nada',
    fromScheme: itrans,
    toScheme: kannada,
    maybeUseDravidianVariant: 'yes',
  );
}
```

## Additional Information

- This package is a Dart port of [indic_transliteration_py](https://github.com/indic-transliteration/indic_transliteration_py)
- Scheme data is auto-generated from TOML files in the [common_maps](../common_maps/) directory
- The package works on all Dart platforms: Web, Flutter, and VM
- No file I/O or asset bundles required - all data is generated at compile time
