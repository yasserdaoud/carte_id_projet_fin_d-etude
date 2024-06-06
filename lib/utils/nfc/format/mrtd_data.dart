import 'package:flutter/services.dart';
import 'dart:typed_data';
import '../../../library/dmrtd_lib/src/lds/df1/dg.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efcom.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg1.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg11.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg12.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg15.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg2.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efdg7.dart';
import '../../../library/dmrtd_lib/src/lds/df1/efsod.dart';
import '../../../library/dmrtd_lib/src/lds/efcard_access.dart';
import '../../../library/dmrtd_lib/src/lds/efcard_security.dart';


class MrtdData {
  EfCardAccess? cardAccess;
  EfCardSecurity? cardSecurity;
  EfCOM? com;
  EfSOD? sod;
  EfDG1? dg1;
  EfDG2? dg2;
 /* EfDG3? dg3;
  EfDG4? dg4;
  EfDG5? dg5;
  EfDG6? dg6;*/
  EfDG7? dg7;
 /* EfDG8? dg8;
  EfDG9? dg9;
  EfDG10? dg10;*/
  EfDG11? dg11;
  EfDG12? dg12;
 /* EfDG13? dg13;
  EfDG14? dg14;*/
  EfDG15? dg15;
 // EfDG16? dg16;
  Uint8List? aaSig;
}

final Map<DgTag, String> dgTagToString = {
  EfDG1.TAG: 'EF.DG1',
  EfDG2.TAG: 'EF.DG2',
 /* EfDG3.TAG: 'EF.DG3',
  EfDG4.TAG: 'EF.DG4',
  EfDG5.TAG: 'EF.DG5',
  EfDG6.TAG: 'EF.DG6',*/
  EfDG7.TAG: 'EF.DG7',
 /* EfDG8.TAG: 'EF.DG8',
  EfDG9.TAG: 'EF.DG9',
  EfDG10.TAG: 'EF.DG10',*/
  EfDG11.TAG: 'EF.DG11',
  EfDG12.TAG: 'EF.DG12',
 /* EfDG13.TAG: 'EF.DG13',
  EfDG14.TAG: 'EF.DG14',*/
  EfDG15.TAG: 'EF.DG15',
 // EfDG16.TAG: 'EF.DG16'
};
