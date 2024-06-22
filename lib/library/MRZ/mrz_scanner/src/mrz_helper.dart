class MRZHelper {
  static const List<int> validMRZLineLengths = [44, 30, 36];
  static const List<String> supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
  static final RegExp validMRZCharRegex = RegExp(r'^[A-Za-z0-9_.]+$');

  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    if (ableToScanTextList.length < 2) {
      // La longueur minimale de tout format MRZ est de 2 lignes
      return null;
    }

    int lineLength = ableToScanTextList.first.length;
    for (var line in ableToScanTextList) {
      if (line.length != lineLength) {
        // Assurez-vous que toutes les lignes ont la même longueur
        return null;
      }
    }

    String firstChar = ableToScanTextList.first[0];
    if (supportedDocTypes.contains(firstChar)) {
      return List<String>.from(ableToScanTextList);
    }

    return null;
  }

  static String testTextLine(String text) {
    String trimmedText = text.replaceAll(' ', '');
    List<String> chars = trimmedText.split('');

    // Vérifiez si le texte appartient à un format MRZ valide
    if (!validMRZLineLengths.contains(chars.length)) {
      return '';
    }

    for (int i = 0; i < chars.length; i++) {
      if (validMRZCharRegex.hasMatch(chars[i])) {
        chars[i] = chars[i].toUpperCase();
        // Assurez-vous que chaque lettre est en majuscule
      } else if (double.tryParse(chars[i]) == null) {
        chars[i] = '<';
        // Parfois, le signe < n'est pas bien reconnu
      }
    }

    return chars.join('');
  }
}
