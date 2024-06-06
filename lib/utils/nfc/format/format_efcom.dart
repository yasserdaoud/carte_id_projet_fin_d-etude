import '../../../library/dmrtd_lib/src/lds/df1/efcom.dart';
import '/utils/nfc/format/mrtd_data.dart';


String formatEfCom(final EfCOM efCom) {
  var str = "-version: ${efCom.version}\n"
            "-unicode version: ${efCom.unicodeVersion}\n"
            "-DG tags:"
            ""
  ;

  for (final t in efCom.dgTags) {
    try {
      str += " ${dgTagToString[t]!}";
    } catch (e) {
      str += " 0x${t.value.toRadixString(16)}";
    }
  }
  return str;
}