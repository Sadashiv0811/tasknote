import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:tasknote/Note/Protected/v_set_password.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Service/s_note_security.dart';
import 'package:tasknote/User/Model/m_user.dart';
import 'package:tasknote/Other_Views/v_splash.dart';

class NoteAuth extends StatefulWidget {
  const NoteAuth({super.key});

  @override
  State<NoteAuth> createState() => _NoteAuthState();
}

class _NoteAuthState extends State<NoteAuth> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  bool _obscureText = true;

  Future<void> _verifyPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final isar = userController.isar;

      final localUser = await isar.mUsers.where().findFirst();

      if (localUser == null) {
        if (!mounted) return;

        scaffoldMessenger("Authentication error. User not found.");
        return;
      }

      final encryptedMasterKey = localUser.encryptedMasterKey;

      if (encryptedMasterKey == null || encryptedMasterKey.trim().isEmpty) {
        if (!mounted) return;

        scaffoldMessenger("Password protection is not configured.");
        return;
      }

      final securityService = NoteSecurityService.instance;

      // Password is used only here.
      // This attempts to decrypt the Master Key.
      // If the password is wrong, decryptMasterKey()
      // throws an exception.
      final masterKey = securityService.decryptMasterKey(
        encryptedMasterKey,
        _passwordController.text.trim(),
      );

      // Password was correct.
      // Keep the Master Key in memory for the protected-note session.
      securityService.setMasterKey(masterKey);

      if (!mounted) return;

      // Tell authenticateNoteSecurity() that authentication succeeded.
      Navigator.pop(context, true);
    } catch (e) {
      logger.d("Incorrect password: $e");

      if (!mounted) return;

      setState(() {
        errorMessage = "Incorrect Password. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final focusedBorderColor = theme.colorScheme.primary;
    final enabledBorderColor = isDarkMode
        ? AppColors.dSecondColor
        : AppColors.lSecondColor;
    final iconColor = isDarkMode ? AppColors.accent : AppColors.secondary;

    return Dialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_person_outlined,
                  size: 70,
                  color: isDarkMode
                      ? AppColors.primary
                      : theme.colorScheme.secondary,
                ),
                const SizedBox(height: 16),

                Text(
                  "Secure Vault",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Enter your password to view protected notes",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 16),
                  decoration:
                      AppTheme.inputDecoration(
                        fBColor: focusedBorderColor,
                        eBColor: enabledBorderColor,
                      ).copyWith(
                        hintText: "Enter PIN / Password",
                        prefixIcon: Icon(
                          Icons.password,
                          color: isDarkMode
                              ? AppColors.accent
                              : AppColors.secondary,
                        ),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: iconColor,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "Password cannot be empty"
                      : null,
                  onChanged: (_) {
                    if (errorMessage != "") {
                      setState(() {
                        errorMessage = "";
                      });
                    }
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: _forgotPassword,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Forgot Password",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.lFirstColor
                              : AppColors.dFirstColor,
                        ),
                      ),
                    ),
                  ),
                ),

                if (errorMessage != "") ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      textAlign: .center,
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: .w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),

                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _verifyPassword,
                      child: const Text("Unlock"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _forgotPassword() async {
    try {
      // Ask for Recovery Key
      final String? recoveryKey = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _RecoveryKeyInputDialog();
        },
      );

      if (recoveryKey == null || recoveryKey.trim().isEmpty) {
        return;
      }

      // Get current user
      final isar = userController.isar;

      final MUser? user = await isar.mUsers.where().findFirst();

      if (user == null || user.uid == null) {
        if (!mounted) return;

        scaffoldMessenger("User profile could not be found.");

        return;
      }

      // Make sure recovery data exists
      final encryptedRecoveryMasterKey = user.encryptedRecoveryMasterKey;

      final storedRecoveryKeyHash = user.recoveryKeyHash;

      if (encryptedRecoveryMasterKey == null ||
          encryptedRecoveryMasterKey.isEmpty ||
          storedRecoveryKeyHash == null ||
          storedRecoveryKeyHash.isEmpty) {
        if (!mounted) return;

        scaffoldMessenger("Recovery information is not available.");

        return;
      }

      final securityService = NoteSecurityService.instance;

      final cleanRecoveryKey = recoveryKey.trim();

      // Verify Recovery Key
      final enteredRecoveryKeyHash = securityService.hashRecoveryKey(
        cleanRecoveryKey,
      );

      if (enteredRecoveryKeyHash != storedRecoveryKeyHash) {
        if (!mounted) return;

        scaffoldMessenger("Invalid recovery key.");

        return;
      }

      // Decrypt Master Key using Recovery Key
      final encrypt.Key masterKey;

      try {
        masterKey = securityService.decryptMasterKeyWithRecoveryKey(
          encryptedRecoveryMasterKey,
          cleanRecoveryKey,
        );
      } catch (e) {
        logger.e("Failed to decrypt master key using recovery key", error: e);

        if (!mounted) return;

        scaffoldMessenger("Invalid recovery key or corrupted security data.");

        return;
      }

      // Ask user for NEW password
      if (!mounted) return;

      final String? newPassword = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SetPasswordDialog(),
      );

      if (newPassword == null || newPassword.trim().isEmpty) {
        return;
      }

      final cleanPassword = newPassword.trim();

      // Encrypt the SAME Master Key with NEW password
      final newEncryptedMasterKey = securityService.encryptMasterKey(
        masterKey,
        cleanPassword,
      );

      // Generate new password hash
      final newPasswordHash = sha256
          .convert(utf8.encode(cleanPassword))
          .toString();

      // Update local user
      user.passwordHash = newPasswordHash;

      user.encryptedMasterKey = newEncryptedMasterKey;

      // IMPORTANT:
      // encryptedRecoveryMasterKey does NOT change.
      // It still contains the SAME Master Key encrypted with the recovery key.
      // recoveryKeyHash also does NOT change.

      // Update Firestore
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.uid)
          .update({
            "passwordHash": newPasswordHash,
            "encryptedMasterKey": newEncryptedMasterKey,
          });

      // Update Isar
      await userController.update(user);

      // Keep recovered Master Key in memory
      securityService.setMasterKey(masterKey);

      // Success
      if (!mounted) return;

      scaffoldMessenger("Password reset successfully.");
    } catch (e, stackTrace) {
      logger.e("Forgot password failed", error: e, stackTrace: stackTrace);

      if (!mounted) return;

      scaffoldMessenger("Failed to reset password.");
    }
  }
}

class _RecoveryKeyInputDialog extends StatelessWidget {
  const _RecoveryKeyInputDialog();

  @override
  Widget build(BuildContext context) {
    final recoveryKeyController = TextEditingController();
    String errorMessage = "";

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const CDialogTitle(text: "Forgot Password"),
          content: Column(
            mainAxisSize: .min,
            children: [
              const CDialogContent(
                text1: "Enter your recovery key to reset your password.",
              ),

              const SizedBox(height: 12),
              CTextFormField(
                controller: recoveryKeyController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                label: "Recovery Key",
                hint: "XXXX-XXXX-XXXX-XXXX-XXXX",
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[ABCDEFGHJKLMNPQRSTUVWXYZ23456789-]'),
                  ),
                  LengthLimitingTextInputFormatter(24),
                ],
                onChanged: (_) {
                  if (errorMessage != "") {
                    setState(() {
                      errorMessage = "";
                    });
                  }
                },
              ),

              if (errorMessage != "") ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: .w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final recoveryKey = recoveryKeyController.text.trim();

                if (recoveryKey.isEmpty) {
                  setState(() {
                    errorMessage = "Please enter your recovery key.";
                  });
                  return;
                }

                if (!isValidRecoveryKey(recoveryKey)) {
                  setState(() {
                    errorMessage =
                        "Invalid recovery key format. "
                        "Expected XXXX-XXXX-XXXX-XXXX-XXXX.";
                  });
                  return;
                }

                Navigator.pop(context, recoveryKey);
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  bool isValidRecoveryKey(String value) {
    final recoveryKeyPattern = RegExp(
      r'^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}-'
      r'[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}-'
      r'[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}-'
      r'[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}-'
      r'[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{4}$',
    );

    return recoveryKeyPattern.hasMatch(value);
  }
}
