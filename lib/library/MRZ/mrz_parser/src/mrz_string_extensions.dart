part of mrz_parser;

extension _MRZStringExtensions on String {
  static final _validInput = RegExp(r'^[A-Z0-9<]+$');

  bool get isValidMRZInput => _validInput.hasMatch(this);

  String trimChar(String char) {
    if (isEmpty || char.isEmpty) {
      return this;
    }

    int start = 0, end = length - 1;
    while (start < length && this[start] == char) {
      start++;
    }
    while (end >= 0 && this[end] == char) {
      end--;
    }
    return start <= end ? substring(start, end + 1) : '';
  }

  String replaceSimilarDigitsWithLetters() {
    final replacements = {
      '0': 'O',
      '1': 'I',
      '2': 'Z',
      '5': 'S',
      '8': 'B',
    };
    return _replaceCharacters(replacements);
  }

  String replaceSimilarLettersWithDigits() {
    final replacements = {
      'O': '0',
      'Q': '0',
      'U': '0',
      'D': '0',
      'I': '1',
      'Z': '2',
      'B': '8',
    };
    return _replaceCharacters(replacements);
  }

  String replaceAngleBracketsWithSpaces() => replaceAll('<', ' ');

  String _replaceCharacters(Map<String, String> replacements) {
    return split('').map((char) => replacements[char] ?? char).join();
  }
}
