import 'package:intl/intl.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg12.dart';

String formatDG12(final EfDG12 dg12) {
  return
      "-Issuing Authority: ${dg12.issuingAuthority}\n" +
      "-Date of Issue: ${dg12.dateOfIssue != null ? DateFormat.yMd().format(dg12.dateOfIssue!) : 'N/A'}";
}
