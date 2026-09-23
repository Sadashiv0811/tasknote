import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Note/note_functions.dart';
import 'package:tasknote/Other/routes.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Note/Model/m_note.dart';
import 'package:tasknote/Service/s_share.dart';

enum SharedStatus { shared, error, cancel, closed }

class VShare extends StatelessWidget {
  final Note note;

  const VShare({super.key, required this.note});

  Future<SharedStatus> shareNoteAsText() async {
    String content = note.content;
    if (note.isCheckList) {
      content = NoteFunctions.formatContentToShare(content) ?? "";
    }

    final result = await ShareService.shareText("${note.title}\n$content");

    if (result.status == ShareResultStatus.success) {
      return SharedStatus.shared;
    } else {
      return SharedStatus.error;
    }
  }

  /// Handles the complete PDF generation, user live-preview/edit,
  /// local disk compilation, and native system file sharing.
  Future<SharedStatus> shareNoteAsPDF(BuildContext context) async {
    String content = note.content;
    if (note.isCheckList) {
      content = NoteFunctions.formatContentToShare(content) ?? "";
    }

    try {
      // 1. Route user to the PDF Live Preview & Editor screen
      final resultPDF = await Navigator.pushNamed(
        context,
        Routes.pdfPreview,
        arguments: {
          'initialText': "${note.title}\n\n$content",
          'fileName': note.title.isEmpty ? "Untitled Note" : note.title,
        },
      );

      // Explicitly safely cast the result
      final Uint8List? compiledPdfBytes = resultPDF is Uint8List
          ? resultPDF
          : null;

      // 2. If the user backed out or canceled the preview, exit gracefully
      if (compiledPdfBytes == null) {
        return SharedStatus.error;
      }

      // 3. Write compiled bytes down to the application's secure documents directory
      final String savedPath = await ShareService.savePdfToDocumentsDirectory(
        pdfBytes: compiledPdfBytes,
        fileName: note.title.isEmpty ? "Note_${note.uid}" : note.title,
      );

      // 4. Pass file path pointer off into native platform share sheets
      final result = await ShareService.sharePdf(
        savedPath,
        title: note.title.isEmpty ? "Shared Note PDF" : note.title,
      );

      // 5. Verify transaction completions
      if (result.status == ShareResultStatus.success) {
        return SharedStatus.shared;
      } else {
        return SharedStatus.error;
      }
    } catch (e) {
      logger.e('Failed to process or share PDF: $e');
      return SharedStatus.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: isDark ? AppColors.dThirdColor : AppColors.lThirdColor,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab/Drag Handle for Bottom Sheet
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Section
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Share Note",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pop(context, SharedStatus.closed.name),
                  icon: Icon(
                    Icons.cancel,
                    color: isDark
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              thickness: 1.0,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),

            // Option 1: Direct Text
            _ShareOptionCard(
              title: "Direct Text",
              subtitle: "Copy raw text or share directly via chat apps",
              icon: Icons.text_snippet_outlined,
              onTap: () async {
                final result = await shareNoteAsText();

                if (result == SharedStatus.shared) {
                  logger.d('Sent as text');

                  if (context.mounted) {
                    Navigator.pop(context, SharedStatus.shared.name);
                  }
                }
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Text PDF
            _ShareOptionCard(
              title: "Text PDF",
              subtitle: "Compile note into a clean, portable PDF document",
              icon: Icons.picture_as_pdf_outlined,
              onTap: () async {
                final result = await shareNoteAsPDF(context);

                if (result == SharedStatus.shared) {
                  logger.d('Sent as PDF');

                  if (context.mounted) {
                    Navigator.pop(context, SharedStatus.shared.name);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ShareOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),

              // Text Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Subtle Navigation indicator caret
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.25),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
