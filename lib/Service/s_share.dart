import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // The share() method requires the ShareParams object, which contains the content to share.

  // These are some of the accepted parameters of the ShareParams class:
  // text: text to share.
  // title: content or share-sheet title (if supported).
  // subject: email subject (if supported).

  static Future<ShareResult> shareText(String text) async {
    final result = await SharePlus.instance.share(ShareParams(text: text));
    return result;
  }

  /// Saves the given PDF bytes into the app's document directory.
  /// Returns the absolute file path of the saved PDF.
  static Future<String> savePdfToDocumentsDirectory({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    // 1. Ensure the filename ends with .pdf extension
    final sanitizedFileName = fileName.endsWith('.pdf')
        ? fileName
        : '$fileName.pdf';

    // 2. Get the application documents directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$sanitizedFileName';

    // 3. Create the file and write the bytes
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    // 4. Return the file path
    return file.path;
  }

  /// Shares a PDF file using its local storage path.
  /// Optional [text] or [title] can be included to accompany the file in the share sheet.
  static Future<ShareResult> sharePdf(
    String filePath, {
    String? text,
    String? title,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: text, title: title),
    );
    return result;
  }
}
