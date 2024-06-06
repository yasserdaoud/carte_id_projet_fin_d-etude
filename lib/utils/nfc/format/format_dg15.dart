import 'package:id_card_example/library/dmrtd_lib/extensions.dart';
import '../../../library/dmrtd_lib/src/crypto/aa_pubkey.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg15.dart';
import '../../../library/dmrtd_lib/src/lds/tlv.dart';

String formatDG15(final EfDG15 dg15) {
  var str = "EF.DG15\n"
      "AAPublicKey\n"
      "type: ";

  final rawSubPubKey = dg15.aaPublicKey.rawSubjectPublicKey();
  if (dg15.aaPublicKey.type == AAPublicKeyType.RSA) {
    final tvSubPubKey = TLV.fromBytes(rawSubPubKey);
    var rawSeq = tvSubPubKey.value;
    if (rawSeq[0] == 0x00) {
      rawSeq = rawSeq.sublist(1);
    }

    final tvKeySeq = TLV.decode(rawSeq);
    final modulusLength = tvKeySeq.value[1];  // Length of the modulus
   // final modulus = tvKeySeq.value.sublist(2, 2 + modulusLength);
    final exponent = tvKeySeq.value.sublist(2 + modulusLength + 2);  // Skip length and start of exponent

    str += "RSA\n"
        "exponent: ${exponent.hex()}";
     //   "modulus: ${modulus.hex()}";
  } else {
    str += "EC\n    SubjectPublicKey: ${rawSubPubKey.hex()}";
  }
  return str;
}
