import 'package:isar_community/isar.dart';

part 'm_user.g.dart';
// dart run build_runner build -> Command to generate above file

// User model class
@collection
class MUser {
  Id id = Isar.autoIncrement;

  // Unique index on Firebase UID to ensure data integrity and fast queries
  @Index(unique: true, replace: true)
  String? uid;

  String email;

  String fullName;

  // Matches Firestore field: login_method
  String loginMethod;

  // Matches the formatted String generated during signup
  String joined;

  // ------------------------------------------------------------
  // Note security
  // ------------------------------------------------------------

  // SHA-256 hash of the user's password.
  //
  // Used only to verify that the entered password is correct.
  // It is NOT used to encrypt notes.
  String? passwordHash;

  // Master Key encrypted using the password-derived key.
  String? encryptedMasterKey;

  // Master Key encrypted using the recovery-key-derived key.
  String? encryptedRecoveryMasterKey;

  // SHA-256 hash of the recovery key.
  String? recoveryKeyHash;

  // Allows us to change the encryption scheme in the future.
  int securityVersion;

  // Constructor
  MUser({
    this.uid,
    required this.email,
    required this.fullName,
    required this.loginMethod,
    required this.joined,
    this.passwordHash,
    this.encryptedMasterKey,
    this.encryptedRecoveryMasterKey,
    this.recoveryKeyHash,
    this.securityVersion = 1,
  });

  // Convert MUser instance into a Map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'login_method': loginMethod,
      'joined': joined,

      // Note security
      'passwordHash': passwordHash,
      'encryptedMasterKey': encryptedMasterKey,
      'encryptedRecoveryMasterKey': encryptedRecoveryMasterKey,
      'recoveryKeyHash': recoveryKeyHash,
      'securityVersion': securityVersion,
    };
  }

  // Create an MUser instance from a Firestore Map
  factory MUser.fromMap(Map<String, dynamic> map) {
    return MUser(
      uid: map['uid'] as String?,
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      loginMethod: map['login_method'] as String? ?? '',
      joined: map['joined'] as String? ?? '',

      passwordHash: map['passwordHash'] as String?,

      encryptedMasterKey: map['encryptedMasterKey'] as String?,

      encryptedRecoveryMasterKey: map['encryptedRecoveryMasterKey'] as String?,

      recoveryKeyHash: map['recoveryKeyHash'] as String?,

      securityVersion: map['securityVersion'] as int? ?? 1,
    );
  }
}
