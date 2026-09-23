import 'package:flutter/material.dart';
import 'package:tasknote/Other/theme.dart';

class SetPasswordDialog extends StatefulWidget {
  const 
  SetPasswordDialog({super.key});

  @override
  State<SetPasswordDialog> createState() => _SetPasswordDialogState();
}

class _SetPasswordDialogState extends State<SetPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final focusedBorderColor = theme.colorScheme.primary;
    final enabledBorderColor = isDark
        ? AppColors.dSecondColor
        : AppColors.lSecondColor;

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Set Notes Password",
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create a password to access your protected notes.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              keyboardType: TextInputType.visiblePassword,
              style: theme.textTheme.bodyMedium,
              decoration:
                  AppTheme.inputDecoration(
                    fBColor: focusedBorderColor,
                    eBColor: enabledBorderColor,
                  ).copyWith(
                    labelText: "Password",
                    hintText: "Enter secure password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                  ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Password cannot be empty";
                }
                if (value.trim().length < 4) {
                  return "Password must be at least 4 characters";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _passwordController.text.trim());
            }
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
