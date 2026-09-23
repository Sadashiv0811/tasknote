import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:tasknote/Other/constants.dart';

class NoteSecurityService {
  NoteSecurityService._();

  static final NoteSecurityService instance = NoteSecurityService._();

  encrypt.Key? _masterKey;

  encrypt.Key? get masterKey => _masterKey;

  void setMasterKey(encrypt.Key key) {
    _masterKey = key;
  }

  void clearMasterKey() {
    _masterKey = null;
  }

  // Master Key

  encrypt.Key generateMasterKey() {
    return encrypt.Key.fromSecureRandom(32);
  }

  // Password → 32 byte key

  encrypt.Key _getPasswordKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);

    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  // Master Key encryption

  String encryptMasterKey(encrypt.Key masterKey, String password) {
    final passwordKey = _getPasswordKey(password);

    final iv = encrypt.IV.fromSecureRandom(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(passwordKey));

    final encrypted = encrypter.encrypt(base64Encode(masterKey.bytes), iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  // Master Key decryption

  encrypt.Key decryptMasterKey(String encryptedMasterKey, String password) {
    try {
      final parts = encryptedMasterKey.split(':');

      if (parts.length != 2) {
        throw Exception('Invalid encrypted master key');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);

      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

      final passwordKey = _getPasswordKey(password);

      final encrypter = encrypt.Encrypter(encrypt.AES(passwordKey));

      final decrypted = encrypter.decrypt(encryptedData, iv: iv);

      return encrypt.Key(base64Decode(decrypted));
    } catch (e) {
      throw Exception('Incorrect password or corrupted master key');
    }
  }

  // Recovery Key
  String generateRecoveryKey() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random.secure();

    final values = List.generate(
      20,
      (_) => chars[random.nextInt(chars.length)],
    );

    return '${values.sublist(0, 4).join()}-'
        '${values.sublist(4, 8).join()}-'
        '${values.sublist(8, 12).join()}-'
        '${values.sublist(12, 16).join()}-'
        '${values.sublist(16, 20).join()}';
  }

  String normalizeRecoveryKey(String recoveryKey) {
    return recoveryKey.replaceAll('-', '').trim().toUpperCase();
  }

  String hashRecoveryKey(String recoveryKey) {
    final normalized = normalizeRecoveryKey(recoveryKey);

    return sha256.convert(utf8.encode(normalized)).toString();
  }

  String encryptMasterKeyWithRecoveryKey(
    encrypt.Key masterKey,
    String recoveryKey,
  ) {
    return encryptMasterKey(masterKey, normalizeRecoveryKey(recoveryKey));
  }

  encrypt.Key decryptMasterKeyWithRecoveryKey(
    String encryptedMasterKey,
    String recoveryKey,
  ) {
    try {
      final parts = encryptedMasterKey.split(':');

      if (parts.length != 2) {
        throw Exception('Invalid encrypted recovery master key');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);

      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

      final normalizedRecoveryKey = normalizeRecoveryKey(recoveryKey);

      final recoveryKeyBytes = utf8.encode(normalizedRecoveryKey);

      final digest = sha256.convert(recoveryKeyBytes);

      final recoveryPasswordKey = encrypt.Key(Uint8List.fromList(digest.bytes));

      final encrypter = encrypt.Encrypter(encrypt.AES(recoveryPasswordKey));

      final decrypted = encrypter.decrypt(encryptedData, iv: iv);

      return encrypt.Key(base64Decode(decrypted));
    } catch (e) {
      logger.e("Failed to decrypt master key using recovery key", error: e);

      throw Exception("Incorrect recovery key or corrupted master key");
    }
  }

  // Note Encryption
  String encryptText(String plainText, encrypt.Key masterKey) {
    if (plainText.isEmpty) return plainText;

    final iv = encrypt.IV.fromSecureRandom(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(masterKey));

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  // Note Decryption
  String decryptText(String encryptedString, encrypt.Key masterKey) {
    if (encryptedString.isEmpty || !encryptedString.contains(':')) {
      return encryptedString;
    }

    try {
      final parts = encryptedString.split(':');

      if (parts.length != 2) {
        throw Exception('Invalid encrypted text');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);

      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt.Encrypter(encrypt.AES(masterKey));

      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      throw Exception('Failed to decrypt note');
    }
  }
}
