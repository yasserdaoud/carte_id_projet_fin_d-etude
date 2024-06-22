part of mrz_parser;

class MRZFieldRecognitionDefectsFixer {
  MRZFieldRecognitionDefectsFixer._();

  static String fixDocumentType(String input) =>
      _replaceSimilarDigitsWithLetters(input);

  static String fixCheckDigit(String input) =>
      _replaceSimilarLettersWithDigits(input);

  static String fixDate(String input) =>
      _replaceSimilarLettersWithDigits(input);

  static String fixSex(String input) =>
      input.replaceAll('P', 'F').replaceAll('M', 'M');

  static String fixCountryCode(String input) =>
      _replaceSimilarDigitsWithLetters(input);

  static String fixNames(String input) =>
      _replaceSimilarDigitsWithLetters(input);

  static String fixNationality(String input) =>
      _replaceSimilarDigitsWithLetters(input);

  static String _replaceSimilarDigitsWithLetters(String input) {
    // Map of similar digits to letters
    final replacements = {
      '0': 'O',
      '1': 'I',
      '2': 'Z',
      '5': 'S',
      '8': 'B',
    };
    return _replaceCharacters(input, replacements);
  }

  static String _replaceSimilarLettersWithDigits(String input) {
    // Map of similar letters to digits
    final replacements = {
      'O': '0',
      'I': '1',
      'Z': '2',
      'S': '5',
      'B': '8',
    };
    return _replaceCharacters(input, replacements);
  }

  static String _replaceCharacters(String input, Map<String, String> replacements) {
    return input.split('').map((char) => replacements[char] ?? char).join();
  }
}
