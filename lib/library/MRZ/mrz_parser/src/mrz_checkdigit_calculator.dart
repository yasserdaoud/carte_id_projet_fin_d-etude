part of mrz_parser;
class MRZCheckDigitCalculator {
  MRZCheckDigitCalculator._();

  static const List<int> _weights = [7, 3, 1];
  static const int _A = 65;
  static const int _Z = 90;
  static const int _0 = 48;
  static const int _9 = 57;

  static int getCheckDigit(String input) {
    final checkSum = input.codeUnits
        .map(_calculateValue)
        .toList()
        .asMap()
        .entries
        .map((entry) => entry.value * _weights[entry.key % _weights.length])
        .reduce((value, element) => value + element);

    return checkSum % 10;
  }

  static int _calculateValue(int codeUnit) {
    if (_isCapitalLetter(codeUnit)) {
      return codeUnit - _A + 10;
    } else if (_isDigit(codeUnit)) {
      return codeUnit - _0;
    } else {
      return 0;
    }
  }

  static bool _isCapitalLetter(int codeUnit) => codeUnit >= _A && codeUnit <= _Z;

  static bool _isDigit(int codeUnit) => codeUnit >= _0 && codeUnit <= _9;
}
