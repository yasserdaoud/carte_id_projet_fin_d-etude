import 'package:intl/intl.dart';
import '../../../library/dmrtd_lib/src/lds/mrz.dart';



String formatMRZ(final MRZ mrz) {
  return
      "-Version: ${mrz.version}\n" +
      "-Document Type: ${mrz.documentCode}\n" +
      "-Document Number: ${mrz.documentNumber}\n" +
      "-Country: ${mrz.country}\n" +
      "-Nationality: ${mrz.nationality}\n" +
      "-Name: ${mrz.firstName}\n" +
      "-Surname: ${mrz.lastName}\n" +
      "-Gender: ${mrz.gender}\n" +
      "-Date of Birth: ${DateFormat.yMd().format(mrz.dateOfBirth)}\n" +
      "-Date of Expiry: ${DateFormat.yMd().format(mrz.dateOfExpiry)}\n";
}
// "Additional profile 1: ${mrz.optionalData}\n" +
// "Additional profile 2: ${mrz.optionalData2 ?? 'None'}";

