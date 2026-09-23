import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Service/s_pdf.dart';

class VPdfPreviewPage extends StatefulWidget {
  final String initialText;
  final String fileName;

  const VPdfPreviewPage({
    super.key,
    required this.initialText,
    required this.fileName,
  });

  @override
  State<VPdfPreviewPage> createState() => _VPdfPreviewPageState();
}

class _VPdfPreviewPageState extends State<VPdfPreviewPage> {
  late TextEditingController _textController;
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _isEditingMode = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _compilePdfAsset();
  }

  Future<void> _compilePdfAsset() async {
    setState(() => _isLoading = true);
    try {
      final bytes = await PdfService.createPdfFromText(_textController.text);
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        scaffoldMessenger("Error rebuilding layout pipeline: $e");
        logger.e("Error rebuilding layout pipeline: $e");
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.dThirdColor
        : AppColors.lThirdColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditingMode ? "Edit Document Source" : "PDF Preview",
          style:
              theme.appBarTheme.titleTextStyle?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(
                fontFamily: 'average',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
        ),
        actions: [
          // Mode Toggle Switch Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            key: const ValueKey("toggle_mode_key"),
            child: IconButton(
              icon: Icon(
                _isEditingMode
                    ? Icons.picture_as_pdf_rounded
                    : Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _isEditingMode = !_isEditingMode;
                });
                if (!_isEditingMode) {
                  _compilePdfAsset(); // Automatically re-compiles on return to preview mode
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Divider(
              thickness: 1.0,
              color: Colors.white.withValues(alpha: 0.12),
            ),

            // Core Display Module
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _isEditingMode
                  ? _buildTextEditor(theme)
                  : _buildPdfPreviewContainer(),
            ),

            // Bottom Floating Operational Control Panel
            _buildBottomActionBar(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreviewContainer() {
    if (_pdfBytes == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SfPdfViewer.memory(
        _pdfBytes!,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }

  Widget _buildTextEditor(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style:
            theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontFamily: 'poppins',
              height: 1.5,
            ) ??
            const TextStyle(
              fontFamily: 'poppins',
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter note markup content...",
          hintStyle: TextStyle(
            fontFamily: 'poppins',
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            if (_isEditingMode) {
              _compilePdfAsset();
              setState(() => _isEditingMode = false);
            } else {
              Navigator.pop(context, _pdfBytes);
            }
          },
          icon: Icon(
            _isEditingMode
                ? Icons.refresh_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
          ),
          label: Text(
            _isEditingMode ? "Regenerate Preview" : "Confirm & Use PDF",
            style:
                theme.elevatedButtonTheme.style?.textStyle
                    ?.resolve({})
                    ?.copyWith(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      letterSpacing: 1.2,
                    ) ??
                const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditingMode
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors
                      .primary, 
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _isEditingMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
