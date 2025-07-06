import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class CoachScoreController extends GetxController {
  final formKey1 = GlobalKey<FormState>();
  
  final workOrderNo = ''.obs;
  final inspectionDate = ''.obs;
  final nameOfWork = ''.obs;
  final nameOfContractor = ''.obs;
  final supervisorName = ''.obs;
  final designation = ''.obs;
  final trainNo = ''.obs;
  final arrivalTime = ''.obs;
  final departureTime = ''.obs;
  final coachesAttended = ''.obs;
  final totalCoaches = ''.obs;
  var isTableView = false.obs;
  
  final RxMap<String, Map<String, int>> coachScores = <String, Map<String, int>>{}.obs;
  
  final isSubmitting = false.obs;
  final isOnline = true.obs;
  final pendingSubmissions = <Map<String, dynamic>>[].obs;
  
  final List<String> activities = [
    'T1', 'T2', 'T3', 'T4', 
    'cleaning_wiping', 
    'B1', 'B2', 'D1', 'D2', 
    'disposal_waste', 
  ];
  
  final List<String> coaches = [
    'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13'
  ];
  
  @override
  void onInit() {
    super.onInit();
    _initializeScores();
    _checkConnectivity();
    _loadAutoSavedData();
    _loadPendingSubmissions();
    
    ever(workOrderNo, (_) => _autoSave());
    ever(supervisorName, (_) => _autoSave());
    ever(trainNo, (_) => _autoSave());
  }
  
  void _initializeScores() {
    for (String coach in coaches) {
      coachScores[coach] = {};
      for (String activity in activities) {
        coachScores[coach]![activity] = 0;
      }
    }
  }
  
  void updateScore(String coach, String activity, int score) {
    if (coachScores[coach] == null) {
      coachScores[coach] = {};
    }
    coachScores[coach]![activity] = score;
    coachScores.refresh();
  }
  
  int getScore(String coach, String activity) {
    return coachScores[coach]?[activity] ?? 0;
  }
  
  int getTotalScoreForCoach(String coach) {
    int total = 0;
    if (coachScores[coach] != null) {
      coachScores[coach]!.forEach((activity, score) {
        total += score;
      });
    }
    return total;
  }
  
  int get totalScore {
    int total = 0;
    coachScores.forEach((coach, activities) {
      activities.forEach((activity, score) {
        total += score;
      });
    });
    return total;
  }
  
  int get maxScore {
    return coaches.length * activities.length * 1;
  }
  
  double get scorePercentage => maxScore > 0 ? (totalScore / maxScore) * 100 : 0;
  
  int get inaccessibleCount {
    int count = 0;
    coachScores.forEach((coach, activities) {
      activities.forEach((activity, score) {
        if (score == 0) count++; 
      });
    });
    return count;
  }

  
  
  void _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    isOnline.value = result != ConnectivityResult.none;
    
    connectivity.onConnectivityChanged.listen((result) {
      isOnline.value = result != ConnectivityResult.none;
      if (isOnline.value) {
        submitPendingData();
      }
    });
  }
  
  void _autoSave() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _generateFormData();
    await prefs.setString('auto_saved_form', json.encode(data));
  }
  
  void _loadAutoSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('auto_saved_form');
    if (savedData != null) {
      final data = json.decode(savedData);
      _populateFormFromData(data);
    }
  }
  
  void _loadPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingData = prefs.getStringList('pending_submissions') ?? [];
    pendingSubmissions.value = pendingData.map((e) => json.decode(e)).toList().cast<Map<String, dynamic>>();
  }
  
  void _savePendingSubmission(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    pendingSubmissions.add(data);
    final stringList = pendingSubmissions.map((e) => json.encode(e)).toList();
    await prefs.setStringList('pending_submissions', stringList);
  }
  
  void submitPendingData() async {
    if (pendingSubmissions.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final submissions = List<Map<String, dynamic>>.from(pendingSubmissions);
    
    for (final submission in submissions) {
      try {
        final response = await http.post(
          Uri.parse('https://httpbin.org/post'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(submission),
        );
        
        if (response.statusCode == 200) {
          pendingSubmissions.remove(submission);
        }
      } catch (e) {
        print('Failed to submit pending data: $e');
        break;
      }
    }
    
    final stringList = pendingSubmissions.map((e) => json.encode(e)).toList();
    await prefs.setStringList('pending_submissions', stringList);
    
    if (pendingSubmissions.isEmpty) {
      Get.snackbar(
        'Success',
        'All pending submissions uploaded successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
  
  Map<String, dynamic> _generateFormData() {
    return {
      'work_order_no': workOrderNo.value,
      'inspection_date': inspectionDate.value,
      'name_of_work': nameOfWork.value,
      'name_of_contractor': nameOfContractor.value,
      'supervisor_name': supervisorName.value,
      'designation': designation.value,
      'train_no': trainNo.value,
      'arrival_time': arrivalTime.value,
      'departure_time': departureTime.value,
      'coaches_attended': coachesAttended.value,
      'total_coaches': totalCoaches.value,
      'coach_scores': coachScores.toJson(),
      'total_score': totalScore,
      'score_percentage': scorePercentage,
      'inaccessible_count': inaccessibleCount,
      'submitted_at': DateTime.now().toIso8601String(),
    };
  }
  
  void _populateFormFromData(Map<String, dynamic> data) {
    workOrderNo.value = data['work_order_no'] ?? '';
    inspectionDate.value = data['inspection_date'] ?? '';
    nameOfWork.value = data['name_of_work'] ?? '';
    nameOfContractor.value = data['name_of_contractor'] ?? '';
    supervisorName.value = data['supervisor_name'] ?? '';
    designation.value = data['designation'] ?? '';
    trainNo.value = data['train_no'] ?? '';
    arrivalTime.value = data['arrival_time'] ?? '';
    departureTime.value = data['departure_time'] ?? '';
    coachesAttended.value = data['coaches_attended'] ?? '';
    totalCoaches.value = data['total_coaches'] ?? '';
    
    final scores = data['coach_scores'] ?? {};
    if (scores is Map) {
      coachScores.value = Map<String, Map<String, int>>.from(
        scores.map((coach, activities) => MapEntry(
          coach.toString(),
          Map<String, int>.from(activities),
        )),
      );
    }
  }
  
  bool validateForm() {
    if (workOrderNo.value.isEmpty) {
      Get.snackbar('Error', 'Please enter Work Order Number');
      return false;
    }
    if (trainNo.value.isEmpty) {
      Get.snackbar('Error', 'Please enter Train Number');
      return false;
    }
    if (supervisorName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter Supervisor Name');
      return false;
    }
    if (inspectionDate.value.isEmpty) {
      Get.snackbar('Error', 'Please select inspection date');
      return false;
    }
    return true;
  }
  
  Future<void> submitForm() async {
    if (!validateForm()) return;
    
    isSubmitting.value = true;
    
    try {
      final data = _generateFormData();
      
      if (isOnline.value) {
        final response = await http.post(
          Uri.parse('https://httpbin.org/post'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        
        if (response.statusCode == 200) {
          Get.snackbar(
            'Success',
            'Score card submitted successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          _clearAutoSavedData();
          resetForm();
        } else {
          throw Exception('Failed to submit');
        }
      } else {
        _savePendingSubmission(data);
        Get.snackbar(
          'Offline',
          'Score card saved for offline submission!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        resetForm();
      }
    } catch (e) {
      if (!isOnline.value) {
        final data = _generateFormData();
        _savePendingSubmission(data);
        Get.snackbar(
          'Offline',
          'Score card saved for offline submission!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        resetForm();
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit score card: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }
  
  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('... RAILWAY'),
                  pw.Text('"CLEAN TRAIN STATION"'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text('FOR THROUGH PASSED TRAINS'),
              pw.SizedBox(height: 10),
              pw.Text('SCORE CARD (TO BE FILLED BY THE RAILWAY SUPERVISOR / CTS INSPECTOR)', 
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('W.O.No: ${workOrderNo.value}'),
                  pw.Text('Date: ${inspectionDate.value}'),
                  pw.Text('Name of Work: ${nameOfWork.value}'),
                  pw.Text('Name of Contractor: ${nameOfContractor.value}'),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Name of Supervisor: ${supervisorName.value}'),
                  pw.Text('Designation: ${designation.value}'),
                  pw.Text('Date of Inspection: ${inspectionDate.value}'),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Train No: ${trainNo.value}'),
                  pw.Text('Arrival Time: ${arrivalTime.value}'),
                  pw.Text('Dep.Time: ${departureTime.value}'),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No. of Coaches attended by contractor: ${coachesAttended.value}'),
                  pw.Text('Total No. of Coaches in the train: ${totalCoaches.value}'),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Scores obtained: ${totalScore}'),
                  pw.Text('${scorePercentage.toStringAsFixed(1)}%'),
                  pw.Text('Inaccessible: ${inaccessibleCount}'),
                ],
              ),
              pw.SizedBox(height: 20),
              
              
              pw.Text('CLEAN TRAIN STATION ACTIVITIES', 
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
            
              _buildScoreTable(),
              
              pw.SizedBox(height: 20),
              pw.Text('Note: Please give marks for each item on a scale 0 or 1. All items as above which are inaccessible should be marked "x" and shall not be counted in total score. Item not available should be marked "."',
                style: pw.TextStyle(fontSize: 10)),
              pw.Text('No column should be left blank.', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
  
  pw.Widget _buildScoreTable() {
    List<List<String>> tableData = [];
    
    List<String> headerRow = ['S.No', 'Itemized Description of work', 'T/et'];
    headerRow.addAll(coaches);
    tableData.add(headerRow);
    
    List<String> activityDescriptions = [
      'Toilet cleaning complete including pan with High Pressure Jet machine, cleaning wiping of wash basin, mirror & shelves, Spraying of Air Freshener & Mosquito Repellant',
      'Cleaning & wiping of outside washbasin, mirror & shelves in door way area',
      'Vestibule area, Doorway area, area between two toilets and footsteps',
      'Disposal of collected waste from Coaches & AC Bins.',
    ];
    
    for (int i = 0; i < 4; i++) {
      List<String> row = ['1', activityDescriptions[0], 'T${i+1}'];
      for (String coach in coaches) {
        row.add(getScore(coach, 'T${i+1}').toString());
      }
      tableData.add(row);
    }
    
    List<String> row2 = ['2', activityDescriptions[1], ''];
    for (String coach in coaches) {
      row2.add(getScore(coach, 'cleaning_wiping').toString());
    }
    tableData.add(row2);
    
    List<String> subActivities = ['B1', 'B2', 'D1', 'D2'];
    for (String sub in subActivities) {
      List<String> row = ['3', activityDescriptions[2], sub];
      for (String coach in coaches) {
        row.add(getScore(coach, sub).toString());
      }
      tableData.add(row);
    }
    
    List<String> row4 = ['4', activityDescriptions[3], ''];
    for (String coach in coaches) {
      row4.add(getScore(coach, 'disposal_waste').toString());
    }
    tableData.add(row4);
    
    return pw.Table.fromTextArray(
      data: tableData,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
      cellStyle: pw.TextStyle(fontSize: 7),
      columnWidths: {
        0: pw.FixedColumnWidth(30),
        1: pw.FixedColumnWidth(120),
        2: pw.FixedColumnWidth(30),
      },
    );
  }
  
  void _clearAutoSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auto_saved_form');
  }
  
  void resetForm() {
    workOrderNo.value = '';
    inspectionDate.value = '';
    nameOfWork.value = '';
    nameOfContractor.value = '';
    supervisorName.value = '';
    designation.value = '';
    trainNo.value = '';
    arrivalTime.value = '';
    departureTime.value = '';
    coachesAttended.value = '';
    totalCoaches.value = '';
    
    _initializeScores();
  }
  
  String getActivityDisplayName(String activity) {
    switch (activity) {
      case 'T1':
      case 'T2':
      case 'T3':
      case 'T4':
        return 'Toilet $activity cleaning complete';
      case 'cleaning_wiping':
        return 'Cleaning & wiping of outside washbasin';
      case 'B1':
        return 'Vestibule area B1';
      case 'B2':
        return 'Vestibule area B2';
      case 'D1':
        return 'Doorway area D1';
      case 'D2':
        return 'Doorway area D2';
      case 'disposal_waste':
        return 'Disposal of collected waste';
      default:
        return activity;
    }
  }
}