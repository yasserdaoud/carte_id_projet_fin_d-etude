import 'package:intl/intl.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg11.dart';

String formatDG11(final EfDG11 dg11) {
  return
      //"Full Name: ${dg11.nameOfHolder}\n" +
      "-National identification number: ${dg11.personalNumber}\n" +
      "-Full Date of Birth: ${dg11.fullDateOfBirth != null ? DateFormat.yMd().format(dg11.fullDateOfBirth!) : 'N/A'}\n" +
     // "Place of Birth: ${dg11.placeOfBirth}\n" +
     // "Permanent Address: ${dg11.permanentAddress}\n" +
     // "Telephone: ${dg11.telephone}\n" +
     // "Profession: ${dg11.profession}\n" +
     // "Title: ${dg11.title}\n" +
      //"Personal Summary: ${dg11.personalSummary}\n" +
      "-Proof of Citizenship: ${dg11.proofOfCitizenship != null ? 'Available' : 'Not Available'}\n" ;
     // "Other Valid TD Numbers: ${dg11.otherValidTDNumbers}\n" +
      //"Blood Type: ${dg11.custodyInformation}";
}
