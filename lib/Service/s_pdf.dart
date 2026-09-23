import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  /// Compiles raw text into a standard formatted PDF document layout.
  /// Handles auto-pagination across multiple pages natively if content overflows.
  static Future<Uint8List> createPdfFromText(String text) async {
    // 1. Instantiate the PDF Document matrix
    final PdfDocument document = PdfDocument();

    // 2. Add an initial blank landing page
    final PdfPage page = document.pages.add();

    // 3. Define the typographical rules
    // Load your existing Inter font
    final ByteData fontData = await rootBundle.load(
      'assets/fonts/Inter-Regular.ttf',
    );

    final PdfFont font = PdfTrueTypeFont(fontData.buffer.asUint8List(), 14);

    // 4. Wrap text into an element framework for structural boundaries
    final PdfTextElement textElement = PdfTextElement(
      text: text,
      font: font,
      brush: PdfBrushes.black,
    );

    // 5. Enforce auto-pagination so long notes seamlessly roll over onto new pages
    final PdfLayoutFormat layoutFormat = PdfLayoutFormat(
      layoutType: PdfLayoutType.paginate,
    );

    // 6. Print structural element layout down to pages matrix with margins padding
    textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        30,
        30,
        page.getClientSize().width - 60,
        page.getClientSize().height - 60,
      ),
      format: layoutFormat,
    );

    // 7. Save binary array stream out and close instance safely
    final List<int> bytes = await document.save();
    document.dispose();

    return Uint8List.fromList(bytes);
  }
}
