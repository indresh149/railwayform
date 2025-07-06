import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:typed_data';
import '../models/score_paramter.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';

class ScoreCardController extends GetxController {
  final formKey = GlobalKey<FormState>();
  
 
  final stationName = ''.obs;
  final inspectionDate = ''.obs;
  final inspectorName = ''.obs;
  

  final platformCleanliness = ScoreParameter().obs;
  final urinals = ScoreParameter().obs;
  final waterBooths = ScoreParameter().obs;
  final waitingHall = ScoreParameter().obs;
  final circulating = ScoreParameter().obs;
  final drains = ScoreParameter().obs;
  final vendorStalls = ScoreParameter().obs;
  final bookStalls = ScoreParameter().obs;
  final enquiryOffice = ScoreParameter().obs;
  final parkingArea = ScoreParameter().obs;
  final approachRoad = ScoreParameter().obs;
  final dustbins = ScoreParameter().obs;
  final advertisement = ScoreParameter().obs;
  final cleanliness = ScoreParameter().obs;
  final maintenance = ScoreParameter().obs;
  
  final isSubmitting = false.obs;
  final isOnline = true.obs;
  final pendingSubmissions = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _checkConnectivity();
    _loadAutoSavedData();
    _loadPendingSubmissions();
    
    
    ever(stationName, (_) => _autoSave());
    ever(inspectorName, (_) => _autoSave());
    ever(inspectionDate, (_) => _autoSave());
  }
  

  int get totalScore {
    final params = [
      platformCleanliness.value,
      urinals.value,
      waterBooths.value,
      waitingHall.value,
      circulating.value,
      drains.value,
      vendorStalls.value,
      bookStalls.value,
      enquiryOffice.value,
      parkingArea.value,
      approachRoad.value,
      dustbins.value,
      advertisement.value,
      cleanliness.value,
      maintenance.value,
    ];
    
    return params.fold(0, (sum, param) => sum + param.marks);
  }
  
  double get scorePercentage => (totalScore / 150) * 100;
  
  String get scoreGrade {
    if (scorePercentage >= 90) return 'A+';
    if (scorePercentage >= 80) return 'A';
    if (scorePercentage >= 70) return 'B+';
    if (scorePercentage >= 60) return 'B';
    if (scorePercentage >= 50) return 'C';
    return 'D';
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
    final data = _generateFormData();
    await StorageService.saveFormData(data);
  }
  
  void _loadAutoSavedData() async {
    final data = await StorageService.loadFormData();
    if (data != null) {
      _populateFormFromData(data);
    }
  }
  
  void _loadPendingSubmissions() async {
    final data = await StorageService.loadPendingSubmissions();
    pendingSubmissions.value = data;
  }
  
  Future<void> submitPendingData() async {
    if (pendingSubmissions.isEmpty) return;
    
    final submissions = List<Map<String, dynamic>>.from(pendingSubmissions);
    
    for (final submission in submissions) {
      try {
        final success = await ApiService.submitScoreCard(submission);
        if (success) {
          await StorageService.removePendingSubmission(submission);
          pendingSubmissions.remove(submission);
        }
      } catch (e) {
        print('Failed to submit pending data: $e');
        break;
      }
    }
    
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
      'station_name': stationName.value,
      'inspection_date': inspectionDate.value,
      'inspector_name': inspectorName.value,
      'parameters': {
        'platform_cleanliness': platformCleanliness.value.toJson(),
        'urinals': urinals.value.toJson(),
        'water_booths': waterBooths.value.toJson(),
        'waiting_hall': waitingHall.value.toJson(),
        'circulating': circulating.value.toJson(),
        'drains': drains.value.toJson(),
        'vendor_stalls': vendorStalls.value.toJson(),
        'book_stalls': bookStalls.value.toJson(),
        'enquiry_office': enquiryOffice.value.toJson(),
        'parking_area': parkingArea.value.toJson(),
        'approach_road': approachRoad.value.toJson(),
        'dustbins': dustbins.value.toJson(),
        'advertisement': advertisement.value.toJson(),
        'cleanliness': cleanliness.value.toJson(),
        'maintenance': maintenance.value.toJson(),
      },
      'total_score': totalScore,
      'score_percentage': scorePercentage,
      'grade': scoreGrade,
      'submitted_at': DateTime.now().toIso8601String(),
    };
  }
  
  void _populateFormFromData(Map<String, dynamic> data) {
    stationName.value = data['station_name'] ?? '';
    inspectionDate.value = data['inspection_date'] ?? '';
    inspectorName.value = data['inspector_name'] ?? '';
    
    final params = data['parameters'] ?? {};
    if (params['platform_cleanliness'] != null) {
      platformCleanliness.value = ScoreParameter.fromJson(params['platform_cleanliness']);
    }
    if (params['urinals'] != null) {
      urinals.value = ScoreParameter.fromJson(params['urinals']);
    }
    if (params['water_booths'] != null) {
      waterBooths.value = ScoreParameter.fromJson(params['water_booths']);
    }
    if (params['waiting_hall'] != null) {
      waitingHall.value = ScoreParameter.fromJson(params['waiting_hall']);
    }
    if (params['circulating'] != null) {
      circulating.value = ScoreParameter.fromJson(params['circulating']);
    }
    if (params['drains'] != null) {
      drains.value = ScoreParameter.fromJson(params['drains']);
    }
    if (params['vendor_stalls'] != null) {
      vendorStalls.value = ScoreParameter.fromJson(params['vendor_stalls']);
    }
    if (params['book_stalls'] != null) {
      bookStalls.value = ScoreParameter.fromJson(params['book_stalls']);
    }
    if (params['enquiry_office'] != null) {
      enquiryOffice.value = ScoreParameter.fromJson(params['enquiry_office']);
    }
    if (params['parking_area'] != null) {
      parkingArea.value = ScoreParameter.fromJson(params['parking_area']);
    }
    if (params['approach_road'] != null) {
      approachRoad.value = ScoreParameter.fromJson(params['approach_road']);
    }
    if (params['dustbins'] != null) {
      dustbins.value = ScoreParameter.fromJson(params['dustbins']);
    }
    if (params['advertisement'] != null) {
      advertisement.value = ScoreParameter.fromJson(params['advertisement']);
    }
    if (params['cleanliness'] != null) {
      cleanliness.value = ScoreParameter.fromJson(params['cleanliness']);
    }
    if (params['maintenance'] != null) {
      maintenance.value = ScoreParameter.fromJson(params['maintenance']);
    }
  }
  
  bool validateForm() {
    if (stationName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter station name');
      return false;
    }
    if (inspectionDate.value.isEmpty) {
      Get.snackbar('Error', 'Please select inspection date');
      return false;
    }
    if (inspectorName.value.isEmpty) {
      Get.snackbar('Error', 'Please enter inspector name');
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
        final success = await ApiService.submitScoreCard(data);
        if (success) {
          Get.snackbar(
            'Success',
            'Score card submitted successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await StorageService.clearAutoSavedData();
          _resetForm();
        } else {
          throw Exception('Failed to submit');
        }
      } else {
        await StorageService.savePendingSubmission(data);
        _loadPendingSubmissions();
        Get.snackbar(
          'Offline',
          'Score card saved for offline submission!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        _resetForm();
      }
    } catch (e) {
      if (!isOnline.value) {
        final data = _generateFormData();
        await StorageService.savePendingSubmission(data);
        _loadPendingSubmissions();
        Get.snackbar(
          'Offline',
          'Score card saved for offline submission!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        _resetForm();
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
    final parameters = {
      'platform_cleanliness': platformCleanliness.value,
      'urinals': urinals.value,
      'water_booths': waterBooths.value,
      'waiting_hall': waitingHall.value,
      'circulating': circulating.value,
      'drains': drains.value,
      'vendor_stalls': vendorStalls.value,
      'book_stalls': bookStalls.value,
      'enquiry_office': enquiryOffice.value,
      'parking_area': parkingArea.value,
      'approach_road': approachRoad.value,
      'dustbins': dustbins.value,
      'advertisement': advertisement.value,
      'cleanliness': cleanliness.value,
      'maintenance': maintenance.value,
    };
    
    return await PDFService.generateScoreCardPDF(
      stationName: stationName.value,
      inspectorName: inspectorName.value,
      inspectionDate: inspectionDate.value,
      parameters: parameters,
      totalScore: totalScore,
      scorePercentage: scorePercentage,
      scoreGrade: scoreGrade,
    );
  }
  
  void _resetForm() {
    stationName.value = '';
    inspectionDate.value = '';
    inspectorName.value = '';
    
    platformCleanliness.value = ScoreParameter();
    urinals.value = ScoreParameter();
    waterBooths.value = ScoreParameter();
    waitingHall.value = ScoreParameter();
    circulating.value = ScoreParameter();
    drains.value = ScoreParameter();
    vendorStalls.value = ScoreParameter();
    bookStalls.value = ScoreParameter();
    enquiryOffice.value = ScoreParameter();
    parkingArea.value = ScoreParameter();
    approachRoad.value = ScoreParameter();
    dustbins.value = ScoreParameter();
    advertisement.value = ScoreParameter();
    cleanliness.value = ScoreParameter();
    maintenance.value = ScoreParameter();
  }
}