import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../controllers/auth_controller.dart';
import '../controllers/coach_score_controller.dart';
import 'login_screen.dart';

class CoachScoreScreen extends StatelessWidget {
  final CoachScoreController controller = Get.put(CoachScoreController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clean Train Station Score Card'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                _showProfileDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue[800]),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red[600]),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          Obx(
            () => Icon(
              controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
              color: controller.isOnline.value ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 8),
          Obx(
            () => controller.pendingSubmissions.isNotEmpty
                ? Badge(
                    label: Text('${controller.pendingSubmissions.length}'),
                    child: Icon(Icons.cloud_upload),
                  )
                : SizedBox(),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            SizedBox(height: 16),
            _buildHeaderSection(),
            SizedBox(height: 20),
            _buildCoachActivitiesSection(),
            SizedBox(height: 20),
            _buildScoreSummary(),
            SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.blue[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.blue[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await authController.logout();
              Get.offAll(() => LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem(
              'Name',
              authController.getCurrentUserName() ?? 'Unknown',
            ),
            SizedBox(height: 10),
            _buildProfileItem(
              'Email',
              authController.getCurrentUserEmail() ?? 'Unknown',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.blue[600])),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Obx(
      () => controller.pendingSubmissions.isNotEmpty
          ? Card(
              color: Colors.orange[50],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${controller.pendingSubmissions.length} submission(s) pending upload',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                    if (controller.isOnline.value)
                      TextButton(
                        onPressed: () => controller.submitPendingData(),
                        child: Text('Upload Now'),
                      ),
                  ],
                ),
              ),
            )
          : SizedBox(),
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
                Icon(Icons.train, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Train Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Obx(
              () => TextFormField(
                initialValue: controller.workOrderNo.value,
                decoration: InputDecoration(
                  labelText: 'Work Order Number (W.O.No)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.numbers),
                ),
                onChanged: (value) => controller.workOrderNo.value = value,
              ),
            ),
            SizedBox(height: 12),

            InkWell(
              onTap: () => _selectDate(Get.context!),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Inspection Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Obx(
                  () => Text(
                    controller.inspectionDate.value.isEmpty
                        ? 'Select Date'
                        : controller.inspectionDate.value,
                    style: TextStyle(
                      color: controller.inspectionDate.value.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

           
            Obx(
              () => TextFormField(
                initialValue: controller.nameOfWork.value,
                decoration: InputDecoration(
                  labelText: 'Name of Work',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.work),
                ),
                onChanged: (value) => controller.nameOfWork.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.nameOfContractor.value,
                decoration: InputDecoration(
                  labelText: 'Name of Contractor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.business),
                ),
                onChanged: (value) => controller.nameOfContractor.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.supervisorName.value,
                decoration: InputDecoration(
                  labelText: 'Name of Supervisor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) => controller.supervisorName.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.designation.value,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.badge),
                ),
                onChanged: (value) => controller.designation.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.trainNo.value,
                decoration: InputDecoration(
                  labelText: 'Train Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.train),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.trainNo.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => GestureDetector(
                onTap: () async {
                  TimeOfDay initialTime = TimeOfDay.now();

                  if (controller.arrivalTime.value.isNotEmpty) {
                    try {
                      final parts = controller.arrivalTime.value
                          .split(' ')[0]
                          .split(':');
                      initialTime = TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      );
                    } catch (e) {
                      print('Error parsing arrival time: $e');
                    }
                  }

                  final TimeOfDay? picked = await showTimePicker(
                    context: Get.context!,
                    initialTime: initialTime,
                  );

                  if (picked != null) {
                    final String formattedTime = _formatTimeWithAMPM(picked);
                    controller.arrivalTime.value = formattedTime;
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.arrivalTime.value.isEmpty
                              ? 'Select Arrival Time'
                              : controller.arrivalTime.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.arrivalTime.value.isEmpty
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => GestureDetector(
                onTap: () async {
                  TimeOfDay initialTime = TimeOfDay.now();

                  if (controller.departureTime.value.isNotEmpty) {
                    try {
                      final parts = controller.departureTime.value
                          .split(' ')[0]
                          .split(':');
                      initialTime = TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      );
                    } catch (e) {
                      print('Error parsing departure time: $e');
                    }
                  }

                  final TimeOfDay? picked = await showTimePicker(
                    context: Get.context!,
                    initialTime: initialTime,
                  );

                  if (picked != null) {
                    final String formattedTime = _formatTimeWithAMPM(picked);
                    controller.departureTime.value = formattedTime;
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.grey[600]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.departureTime.value.isEmpty
                              ? 'Select Departure Time'
                              : controller.departureTime.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.departureTime.value.isEmpty
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.coachesAttended.value,
                decoration: InputDecoration(
                  labelText: 'Number of Coaches Attended by Contractor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.coachesAttended.value = value,
              ),
            ),
            SizedBox(height: 12),

            Obx(
              () => TextFormField(
                initialValue: controller.totalCoaches.value,
                decoration: InputDecoration(
                  labelText: 'Total Number of Coaches in the Train',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.totalCoaches.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeWithAMPM(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('h:mm a').format(dateTime);
  }

  Widget _buildCoachActivitiesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.green[800]),
                SizedBox(width: 8),
                Text(
                  'Clean Train Station Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Container(
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
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• T1-T4: Give marks from 1 to 9 only (no x or .)\n'
                    '• Other activities: Give marks 0 to 9, "x" for inaccessible, "." for not available\n'
                    '• No field should be left blank',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            _buildCoachActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachActivities() {
    return Column(
      children: controller.coaches.map((coach) {
        return CoachActivityItem(coachName: coach, controller: controller);
      }).toList(),
    );
  }

  Widget _buildScoreSummary() {
    return Obx(
      () => Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: Colors.purple[800]),
                  SizedBox(width: 8),
                  Text(
                    'Score Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Score',
                      controller.totalScore.toString(),
                      Colors.green,
                      Icons.score,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Max Score',
                      controller.maxScore.toString(),
                      Colors.blue,
                      Icons.emoji_events,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Percentage',
                      '${controller.scorePercentage.toStringAsFixed(1)}%',
                      Colors.orange,
                      Icons.percent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryCard(
                      'Inaccessible',
                      controller.inaccessibleCount.toString(),
                      Colors.red,
                      Icons.block,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => _generatePDF(),
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () => _resetForm(),
                  icon: Icon(Icons.refresh),
                  label: Text('Reset Form'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submitForm(),
              icon: controller.isSubmitting.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.send),
              label: Text(
                controller.isSubmitting.value ? 'Submitting...' : 'Submit',
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.inspectionDate.value = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _generatePDF() async {
    try {
      final pdfData = await controller.generatePDF();
      await Printing.layoutPdf(onLayout: (format) => pdfData);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _resetForm() {
    Get.dialog(
      AlertDialog(
        title: Text('Reset Form'),
        content: Text(
          'Are you sure you want to reset the form? All data will be lost.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.resetForm();
              Get.back();
              Get.snackbar(
                'Success',
                'Form has been reset',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class CoachActivityItem extends StatelessWidget {
  final String coachName;
  final CoachScoreController controller;

  const CoachActivityItem({
    Key? key,
    required this.coachName,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.train, color: Colors.blue[600]),
        title: Text(
          'Coach $coachName',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Obx(
          () => Chip(
            label: Text('${_getCoachTotalScore()}'),
            backgroundColor: _getScoreColor(_getCoachTotalScore()),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToiletSection(),
                SizedBox(height: 16),

                _buildSingleActivity(
                  'Cleaning & Wiping',
                  'Cleaning & wiping of outside washbasin, mirror & shelves in door way area',
                  'cleaning_wiping',
                  Icons.cleaning_services,
                  allowSpecialValues: true,
                ),
                SizedBox(height: 16),

                _buildActivityGroup(
                  'Vestibule & Doorway Activities',
                  'Vestibule area, Doorway area, area between two toilets and footsteps',
                  ['B1', 'B2', 'D1', 'D2'],
                  Icons.door_front_door,
                  allowSpecialValues: true,
                ),
                SizedBox(height: 16),

                _buildSingleActivity(
                  'Waste Disposal',
                  'Disposal of collected waste from Coaches & AC Bins',
                  'disposal_waste',
                  Icons.delete,
                  allowSpecialValues: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToiletSection() {
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
          Row(
            children: [
              Icon(Icons.wc, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Toilet Cleaning Activities (T1-T4)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Toilet cleaning complete including pan with High Pressure Jet machine, cleaning wiping of wash basin, mirror & shelves, Spraying of Air Freshener & Mosquito Repellant',
            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['T1', 'T2', 'T3', 'T4'].map((toilet) {
              return Container(
                width: (MediaQuery.of(Get.context!).size.width - 80) / 2,
                child: _buildToiletScoreSelector(toilet),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToiletScoreSelector(String toiletKey) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Toilet $toiletKey',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Score:',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.getScore(coachName, toiletKey) <= 0
                        ? '1'
                        : controller.getScore(coachName, toiletKey).toString(),
                    isExpanded: true,
                    style: TextStyle(fontSize: 11, color: Colors.black),
                    underline: Container(height: 1, color: Colors.blue[300]),
                    items: ['1', '2', '3', '4', '5', '6', '7', '8', '9']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 11)),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.updateScore(
                          coachName,
                          toiletKey,
                          int.parse(newValue),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityGroup(
    String title,
    String description,
    List<String> activities,
    IconData icon, {
    bool allowSpecialValues = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),

          // Activities Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activities.map((activity) {
              return Container(
                width: (MediaQuery.of(Get.context!).size.width - 80) / 2,
                child: _buildActivityScoreSelector(
                  activity,
                  allowSpecialValues: allowSpecialValues,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleActivity(
    String title,
    String description,
    String activityKey,
    IconData icon, {
    bool allowSpecialValues = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            child: _buildActivityScoreSelector(
              activityKey,
              allowSpecialValues: allowSpecialValues,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityScoreSelector(
    String activityKey, {
    bool allowSpecialValues = false,
  }) {
    List<String> dropdownItems = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];
    if (allowSpecialValues) {
      dropdownItems.addAll(['x', '.']);
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            activityKey,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Score:',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Obx(() {
                  int score = controller.getScore(coachName, activityKey);
                  String displayValue;
                  if (score == -1) {
                    displayValue = allowSpecialValues ? 'x' : '0';
                  } else if (score == -2) {
                    displayValue = allowSpecialValues ? '.' : '0';
                  } else {
                    displayValue = score.toString();
                  }

                  return DropdownButton<String>(
                    value: displayValue,
                    isExpanded: true,
                    style: TextStyle(fontSize: 11, color: Colors.black),
                    underline: Container(height: 1, color: Colors.grey[300]),
                    items: dropdownItems
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 11)),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        if (newValue == 'x') {
                          controller.updateScore(coachName, activityKey, -1);
                        } else if (newValue == '.') {
                          controller.updateScore(coachName, activityKey, -2);
                        } else {
                          controller.updateScore(
                            coachName,
                            activityKey,
                            int.parse(newValue),
                          );
                        }
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getCoachTotalScore() {
    int total = 0;
    List<String> activities = [
      'T1',
      'T2',
      'T3',
      'T4',
      'cleaning_wiping',
      'B1',
      'B2',
      'D1',
      'D2',
      'disposal_waste',
    ];

    for (String activity in activities) {
      int score = controller.getScore(coachName, activity);
      if (score > 0) {
        total += score;
      }
    }
    return total;
  }

  Color _getScoreColor(int score) {
    if (score >= 54) return Colors.green[100]!;
    if (score >= 36) return Colors.yellow[100]!;
    if (score >= 18) return Colors.orange[100]!;
    return Colors.red[100]!;
  }
}
