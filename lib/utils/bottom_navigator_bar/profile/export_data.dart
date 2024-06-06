import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> exportDatabaseToTxt() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'profile.db');
  final database = await openDatabase(path);

  final List<Map<String, dynamic>> results = await database.query('profiles');

  StringBuffer buffer = StringBuffer();

  for (var row in results) {
    buffer.writeln('Document Number: ${row['documentNumber']}');
    buffer.writeln('First Name: ${row['firstName']}');
    buffer.writeln('Last Name: ${row['lastName']}');
    buffer.writeln('Date of Birth: ${row['dateOfBirth']}');
    buffer.writeln('Nationality: ${row['nationality']}');
    buffer.writeln('Date of Expiry: ${row['dateOfExpiry']}');
    buffer.writeln('Image Data: ${row['imageData']}');
    buffer.writeln('Signature Data: ${row['signatureData']}');
    buffer.writeln(''); // Empty line between records
  }

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/profiles.txt');

  await file.writeAsString(buffer.toString());

  print('Database exported to ${file.path}');
}
