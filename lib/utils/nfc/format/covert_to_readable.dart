String convertToReadableFormat(String input) {
  if (input.isEmpty) {
    return input;
  }

  String readableText = input.replaceAll('_', ' ');

  return readableText;
}
