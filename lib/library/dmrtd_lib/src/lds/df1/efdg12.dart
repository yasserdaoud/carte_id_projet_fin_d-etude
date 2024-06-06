// Created by Crt Vavros, copyright © 2022 ZeroPass. All rights reserved.
// ignore_for_file: constant_identifier_names

import 'dart:core';
import 'dart:convert';
import 'dart:typed_data';
import 'package:id_card_example/library/dmrtd_lib/extensions.dart';
import '../ef.dart';
import '../tlv.dart';
import 'dg.dart';

class EfDG12 extends DataGroup {
  static const FID = 0x010C;
  static const SFI = 0x0C;
  static const TAG = DgTag(0x6C);

  static const ISSUING_AUTHORITY_TAG = 0x5F19;
  static const DATE_OF_ISSUE_TAG = 0x5F18;
  //static const NAME_OF_OTHER_PERSON_TAG = 0x5F1A;
  //static const ENDORSEMENTS_AND_OBSERVATIONS_TAG = 0x5F1B;
  //static const TAX_OR_EXIT_REQUIREMENTS_TAG = 0x5F1C;
  //static const IMAGE_OF_FRONT_TAG = 0x5F1D;
  //static const IMAGE_OF_REAR_TAG = 0x5F1E;
  //static const DATE_AND_TIME_OF_PERSONALIZATION = 0x5F55;
 // static const PERSONALIZATION_SYSTEM_SERIAL_NUMBER_TAG = 0x5F56;
  static const TAG_LIST_TAG = 0x5C;

  DateTime? _dateOfIssue;
  String? _issuingAuthority;

  DateTime? get dateOfIssue => _dateOfIssue;
  String? get issuingAuthority => _issuingAuthority;

  EfDG12.fromBytes(Uint8List data) : super.fromBytes(data);

  @override
  int get fid => FID;

  @override
  int get sfi => SFI;

  @override
  int get tag => TAG.value;

  @override
  void parse(final Uint8List content) {
    final tlv = TLV.fromBytes(content);
    if (tlv.tag != tag) {
      throw EfParseError(
          "Invalid DG12 tag=${tlv.tag.hex()}, expected tag=${TAG.value.hex()}");
    }

    final data = tlv.value;
    final tagListTag = TLV.decode(data);
    if (tagListTag.tag.value != TAG_LIST_TAG) {
      throw EfParseError(
          "Invalid version object tag=${tagListTag.tag.value.hex()}, expected version object with tag=5c");
    }
    var tagListLength = tlv.value.length;
    int tagListBytesRead = tagListTag.encodedLen;

    while (tagListBytesRead < tagListLength) {
      try {
        final uvtv = TLV.decode(data.sublist(tagListBytesRead));
        tagListBytesRead += uvtv.encodedLen;

        switch (uvtv.tag.value) {
          case ISSUING_AUTHORITY_TAG:
            _issuingAuthority = utf8.decode(uvtv.value);
            break;
          case DATE_OF_ISSUE_TAG:
            _dateOfIssue = String.fromCharCodes(uvtv.value).parseDate();
            break;
          default:
          // Ignorer les tags inconnus pour éviter les erreurs d'offset
            break;
        }
      } catch (e) {
        // Ignorer les erreurs pour éviter les interruptions du traitement
        tagListBytesRead++;
      }
    }
  }
}
