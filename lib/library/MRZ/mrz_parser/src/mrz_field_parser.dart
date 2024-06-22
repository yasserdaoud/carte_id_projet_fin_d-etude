part of mrz_parser;

class MRZFieldParser {
  MRZFieldParser._();

  static String parseDocumentNumber(String input) => _trimAndReplace(input);

  static String parseDocumentType(String input) => _trimAndReplace(input);

  static String parseCountryCode(String input) => _trimAndReplace(input);

  static String parseNationality(String input) => _trimAndReplace(input);

  static String parseOptionalData(String input) => _trimAndReplace(input);

  static List<String> parseNames(String input) {
    final parts = input.trimChar('<').split('<<');
    return [
      parts.isNotEmpty ? _trimAndReplace(parts[0]) : '',
      parts.length > 1 ? _trimAndReplace(parts[1]) : '',
    ];
  }

  static DateTime parseBirthDate(String input) => _parseDate(_trimAndReplace(input), 2000);

  static DateTime parseExpiryDate(String input) => _parseDate(_trimAndReplace(input), 70);

  static Sex parseSex(String input) {
    switch (input) {
      case 'M':
        return Sex.male;
      case 'F':
        return Sex.female;
      default:
        return Sex.none;
    }
  }

  static String _trimAndReplace(String input) =>
      input.replaceAngleBracketsWithSpaces().trim();

  static DateTime _parseDate(String input, int milestoneYear) {
    if (input.length != 6) {
      throw FormatException("Invalid date format");
    }

    final year = int.parse(input.substring(0, 2));
    final month = int.parse(input.substring(2, 4));
    final day = int.parse(input.substring(4, 6));

    final currentYear = DateTime.now().year % 100; // last two digits of current year
    final century = (year > currentYear) ? '19' : '20';

    final fullYear = int.parse('$century$year');
    return DateTime(fullYear, month, day);
  }
}
