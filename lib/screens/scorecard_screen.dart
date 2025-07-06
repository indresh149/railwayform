import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../controllers/scorecard_controller.dart';
import '../widgets/parameter_item.dart';
import '../widgets/score_summary.dart';
import '../widgets/connection_status.dart';

class ScoreCardScreen extends StatelessWidget {
  final ScoreCardController controller = Get.put(ScoreCardController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Station Score Card'),
        centerTitle: true,
        actions: [
          Obx(() => Icon(
            controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
            color: controller.isOnline.value ? Colors.green : Colors.red,
          )),
          SizedBox(width: 8),
          Obx(() => controller.pendingSubmissions.isNotEmpty
            ? Badge(
                label: Text('${controller.pendingSubmissions.length}'),
                child: Icon(Icons.cloud_upload),
              )
            : SizedBox()),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectionStatus(),
              SizedBox(height: 16),
              _buildHeaderSection(),
              SizedBox(height: 20),
              _buildParametersSection(),
              SizedBox(height: 20),
              ScoreSummary(controller: controller),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Station Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildStationNameField(),
            SizedBox(height: 16),
            _buildInspectorNameField(),
            SizedBox(height: 16),
            _buildDateField(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Station Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.train),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (value) => controller.stationName.value = value,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter station name';
        }
        return null;
      },
    );
  }

  Widget _buildInspectorNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Inspector Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(Icons.person),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      onChanged: (value) => controller.inspectorName.value = value,
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter inspector name';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(Get.context!),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Inspection Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Obx(() => Text(
          controller.inspectionDate.value.isEmpty 
            ? 'Select Date' 
            : controller.inspectionDate.value,
          style: TextStyle(
            color: controller.inspectionDate.value.isEmpty 
              ? Colors.grey[600] 
              : Colors.black,
          ),
        )),
      ),
    );
  }
  
  Widget _buildParametersSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Inspection Parameters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildParametersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersList() {
    final parameters = [
      {'title': 'Platform Cleanliness', 'parameter': controller.platformCleanliness, 'icon': Icons.cleaning_services},
      {'title': 'Urinals', 'parameter': controller.urinals, 'icon': Icons.wc},
      {'title': 'Water Booths', 'parameter': controller.waterBooths, 'icon': Icons.water_drop},
      {'title': 'Waiting Hall', 'parameter': controller.waitingHall, 'icon': Icons.chair},
      {'title': 'Circulating Area', 'parameter': controller.circulating, 'icon': Icons.directions_walk},
      {'title': 'Drains', 'parameter': controller.drains, 'icon': Icons.water},
      {'title': 'Vendor Stalls', 'parameter': controller.vendorStalls, 'icon': Icons.store},
      {'title': 'Book Stalls', 'parameter': controller.bookStalls, 'icon': Icons.book},
      {'title': 'Enquiry Office', 'parameter': controller.enquiryOffice, 'icon': Icons.help_center},
      {'title': 'Parking Area', 'parameter': controller.parkingArea, 'icon': Icons.local_parking},
      {'title': 'Approach Road', 'parameter': controller.approachRoad, 'icon': Icons.abc_outlined},
      {'title': 'Dustbins', 'parameter': controller.dustbins, 'icon': Icons.delete},
      {'title': 'Advertisement', 'parameter': controller.advertisement, 'icon': Icons.campaign},
      {'title': 'General Cleanliness', 'parameter': controller.cleanliness, 'icon': Icons.cleaning_services},
      {'title': 'Maintenance', 'parameter': controller.maintenance, 'icon': Icons.build},
    ];

    return Column(
      children: parameters.map((param) {
        return ParameterItem(
          title: param['title'] as String,
          parameter: param['parameter'] as dynamic,
          icon: param['icon'] as IconData,
        );
      }).toList(),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _generateAndSharePDF(),
                icon: Icon(Icons.picture_as_pdf),
                label: Text('Generate PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSummaryDialog(),
                icon: Icon(Icons.preview),
                label: Text('Preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isSubmitting.value ? null : controller.submitForm,
        icon: controller.isSubmitting.value 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(controller.isOnline.value ? Icons.send : Icons.save),
        label: Text(
          controller.isSubmitting.value 
            ? 'Submitting...' 
            : controller.isOnline.value 
              ? 'Submit Score Card' 
              : 'Save Offline',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      )),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.inspectionDate.value = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
  
  Future<void> _generateAndSharePDF() async {
    if (!_validateFormForPDF()) return;
    
    try {
     
      Get.dialog(
        AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final pdfData = await controller.generatePDF();
      
      
      Get.back();
      
      await Printing.sharePdf(
        bytes: pdfData,
        filename: 'station_scorecard_${controller.stationName.value}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
       
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _validateFormForPDF() {
    if (controller.stationName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter station name before generating PDF');
      return false;
    }
    if (controller.inspectorName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter inspector name before generating PDF');
      return false;
    }
    if (controller.inspectionDate.value.isEmpty) {
      Get.snackbar('Error', 'Please select inspection date before generating PDF');
      return false;
    }
    return true;
  }
  
  void _showSummaryDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.preview, color: Colors.blue[800]),
            SizedBox(width: 8),
            Text('Score Card Summary'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummarySection(),
              SizedBox(height: 16),
              _buildParametersSummary(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _generateAndSharePDF();
            },
            child: Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text('Station: ${controller.stationName.value}'),
          Text('Inspector: ${controller.inspectorName.value}'),
          Text('Date: ${controller.inspectionDate.value}'),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 8),
          Text(
            'Score Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Score:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${controller.totalScore}/150', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Percentage:', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('${controller.scorePercentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grade:', style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getGradeColor(controller.scoreGrade),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.scoreGrade,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParametersSummary() {
    final parameters = [
      {'name': 'Platform Cleanliness', 'score': controller.platformCleanliness.value.marks},
      {'name': 'Urinals', 'score': controller.urinals.value.marks},
      {'name': 'Water Booths', 'score': controller.waterBooths.value.marks},
      {'name': 'Waiting Hall', 'score': controller.waitingHall.value.marks},
      {'name': 'Circulating Area', 'score': controller.circulating.value.marks},
      {'name': 'Drains', 'score': controller.drains.value.marks},
      {'name': 'Vendor Stalls', 'score': controller.vendorStalls.value.marks},
      {'name': 'Book Stalls', 'score': controller.bookStalls.value.marks},
      {'name': 'Enquiry Office', 'score': controller.enquiryOffice.value.marks},
      {'name': 'Parking Area', 'score': controller.parkingArea.value.marks},
      {'name': 'Approach Road', 'score': controller.approachRoad.value.marks},
      {'name': 'Dustbins', 'score': controller.dustbins.value.marks},
      {'name': 'Advertisement', 'score': controller.advertisement.value.marks},
      {'name': 'General Cleanliness', 'score': controller.cleanliness.value.marks},
      {'name': 'Maintenance', 'score': controller.maintenance.value.marks},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parameters Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 8),
        ...parameters.map((param) {
          return Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    param['name'] as String,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getScoreColor(param['score'] as int),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${param['score']}/10',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    if (score >= 4) return Colors.amber;
    return Colors.red;
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return Colors.green[600]!;
      case 'A':
        return Colors.green[500]!;
      case 'B+':
        return Colors.blue[500]!;
      case 'B':
        return Colors.orange[500]!;
      case 'C':
        return Colors.orange[600]!;
      case 'D':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}