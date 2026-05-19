import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../features/calculator/data/models/history_item_model.dart';

/// Elite local coordinator for compiling history logs into PDF and CSV formats and sharing them.
/// Runs 100% locally and completely free of server subscriptions or cloud services.
class ExportService {
  /// Compiles mathematical history logs into a stunning corporate PDF report and shares it
  Future<void> exportHistoryToPdf(List<HistoryItemModel> logs) async {
    if (logs.isEmpty) return;

    final pdf = pw.Document();

    // Setup beautiful PDF styles
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Branded Corporate Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "VOXCALC REPORT",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "AI-Powered Smart Calculation Log Summary",
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 16),

            // Logs Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Timestamp
                1: const pw.FlexColumnWidth(1.5), // Input Method
                2: const pw.FlexColumnWidth(4), // Formula Equation
                3: const pw.FlexColumnWidth(2.5), // Math Result
              },
              children: [
                // Table Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.indigo50),
                  children: [
                    _buildCell("Timestamp", isHeader: true),
                    _buildCell("Method", isHeader: true),
                    _buildCell("Formula Equation", isHeader: true),
                    _buildCell("Math Result", isHeader: true),
                  ],
                ),
                // Data Rows
                ...logs.map((log) {
                  final timeStr = DateFormat('yyyy-MM-dd HH:mm').format(log.timestamp);
                  return pw.TableRow(
                    children: [
                      _buildCell(timeStr),
                      _buildCell(log.inputMethod.toUpperCase()),
                      _buildCell(log.expression),
                      _buildCell(log.result),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Branded Corporate Footer
            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                "Compiled automatically by VoxCalc. 100% Secure, Local, and Offline-Enabled.",
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ),
          ];
        },
      ),
    );

    // Save and Share the compiled PDF
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/VoxCalc_Export_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the platform native sharing panel
      await Share.shareXFiles([XFile(file.path)], text: 'Exported VoxCalc Math History Report');
    } catch (_) {}
  }

  /// Compiles mathematical history logs into a CSV spreadsheet file and shares it
  Future<void> exportHistoryToCsv(List<HistoryItemModel> logs) async {
    if (logs.isEmpty) return;

    // Compile rows of text separated by commas
    final buffer = StringBuffer();
    
    // CSV Header row
    buffer.writeln("ID,Timestamp,InputMethod,Expression,Result");

    for (var log in logs) {
      final timeStr = log.timestamp.toIso8601String();
      // Escape quotes in expressions to prevent CSV breaking
      final sanitizedExpr = log.expression.replaceAll('"', '""');
      final sanitizedRes = log.result.replaceAll('"', '""');
      
      buffer.writeln('${log.id},"$timeStr","${log.inputMethod}","${sanitizedExpr}","${sanitizedRes}"');
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/VoxCalc_Export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      // Open the platform native sharing panel
      await Share.shareXFiles([XFile(file.path)], text: 'Exported VoxCalc Math History Spreadsheet');
    } catch (_) {}
  }

  /// Helper to build formatted cell grids in the PDF Table layout
  static pw.Widget _buildCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.indigo900 : PdfColors.black,
        ),
      ),
    );
  }
}
