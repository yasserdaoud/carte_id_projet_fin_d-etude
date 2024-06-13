// Created by Crt Vavros, copyright © 2022 ZeroPass. All rights reserved.
import 'dart:typed_data';

abstract class SMCipher {
  /// Encrypts [profile1] to be used in Secure Messaging.
  /// [profile1] must be padded (if needed) before calling this function.
  Uint8List encrypt(final Uint8List data);

  /// Decrypts [edata] from Secure Messaging.
  /// [edata] must be unpadded after calling this function.
  Uint8List decrypt(final Uint8List edata);


  /// Calculates MAC of [profile1].
  /// [profile1] must be padded (if needed) before calling this function.
  Uint8List mac(final Uint8List data);
}