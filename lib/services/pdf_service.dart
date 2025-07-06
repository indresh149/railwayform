import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../models/score_paramter.dart';

class PDFService {
  static Future<Uint8List> generateScoreCardPDF({
    required String stationName,
    required String inspectorName,
    required String inspectionDate,
    required Map<String, ScoreParameter> parameters,
    required int totalScore,
    required double scorePercentage,
    required String scoreGrade,
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Station Score Card Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Station: $stationName'),
                      pw.Text('Inspector: $inspectorName'),
                      pw.Text('Date: $inspectionDate'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Total Score: $totalScore/150'),
                      pw.Text('Percentage: ${scorePercentage.toStringAsFixed(1)}%'),
                      pw.Text('Grade: $scoreGrade'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Parameter', 'Score', 'Remarks'],
                data: _buildTableData(parameters),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  static List<List<String>> _buildTableData(Map<String, ScoreParameter> parameters) {
    return [
      ['Platform Cleanliness', '${parameters['platform_cleanliness']?.marks ?? 0}', parameters['platform_cleanliness']?.remarks ?? ''],
      ['Urinals', '${parameters['urinals']?.marks ?? 0}', parameters['urinals']?.remarks ?? ''],
      ['Water Booths', '${parameters['water_booths']?.marks ?? 0}', parameters['water_booths']?.remarks ?? ''],
      ['Waiting Hall', '${parameters['waiting_hall']?.marks ?? 0}', parameters['waiting_hall']?.remarks ?? ''],
      ['Circulating Area', '${parameters['circulating']?.marks ?? 0}', parameters['circulating']?.remarks ?? ''],
      ['Drains', '${parameters['drains']?.marks ?? 0}', parameters['drains']?.remarks ?? ''],
      ['Vendor Stalls', '${parameters['vendor_stalls']?.marks ?? 0}', parameters['vendor_stalls']?.remarks ?? ''],
      ['Book Stalls', '${parameters['book_stalls']?.marks ?? 0}', parameters['book_stalls']?.remarks ?? ''],
      ['Enquiry Office', '${parameters['enquiry_office']?.marks ?? 0}', parameters['enquiry_office']?.remarks ?? ''],
      ['Parking Area', '${parameters['parking_area']?.marks ?? 0}', parameters['parking_area']?.remarks ?? ''],
      ['Approach Road', '${parameters['approach_road']?.marks ?? 0}', parameters['approach_road']?.remarks ?? ''],
      ['Dustbins', '${parameters['dustbins']?.marks ?? 0}', parameters['dustbins']?.remarks ?? ''],
      ['Advertisement', '${parameters['advertisement']?.marks ?? 0}', parameters['advertisement']?.remarks ?? ''],
      ['General Cleanliness', '${parameters['cleanliness']?.marks ?? 0}', parameters['cleanliness']?.remarks ?? ''],
      ['Maintenance', '${parameters['maintenance']?.marks ?? 0}', parameters['maintenance']?.remarks ?? ''],
    ];
  }
  
  static Future<void> shareScoreCardPDF(Uint8List pdfData, String stationName) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'station_scorecard_${stationName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}