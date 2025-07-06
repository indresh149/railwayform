import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/coach_score_screen.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = true.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoggedIn = false.obs;
  var loginLoading = false.obs;
  var signupLoading = false.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    if (_prefs != null) {
      isLoggedIn.value = _prefs!.getBool('isLoggedIn') ?? false;
      isLoading.value = false;

      if (isLoggedIn.value) {
        Get.offAll(() => CoachScoreScreen());
      }
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    loginLoading.value = true;

    await Future.delayed(Duration(seconds: 2));

    String? savedEmail = _prefs?.getString('user_email');
    String? savedPassword = _prefs?.getString('user_password');

    if (savedEmail == emailController.text &&
        savedPassword == passwordController.text) {
      await _prefs?.setBool('isLoggedIn', true);
      await _prefs?.setString('current_user_email', emailController.text);

      isLoggedIn.value = true;

      Get.snackbar(
        'Success',
        'Login successful!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
      );

      emailController.clear();
      passwordController.clear();

      Get.offAll(() => CoachScoreScreen());
    } else {
      Get.snackbar(
        'Error',
        'Invalid email or password',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
    }

    loginLoading.value = false;
  }

  Future<void> signup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters long',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    signupLoading.value = true;

    await Future.delayed(Duration(seconds: 2));

    String? existingEmail = _prefs?.getString('user_email');
    if (existingEmail == emailController.text) {
      Get.snackbar(
        'Error',
        'An account with this email already exists',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      signupLoading.value = false;
      return;
    }

    await _prefs?.setString('user_name', nameController.text);
    await _prefs?.setString('user_email', emailController.text);
    await _prefs?.setString('user_password', passwordController.text);
    await _prefs?.setBool('isLoggedIn', true);
    await _prefs?.setString('current_user_email', emailController.text);

    isLoggedIn.value = true;

    Get.snackbar(
      'Success',
      'Account created successfully!',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      snackPosition: SnackPosition.TOP,
    );

    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    Get.offAll(() => CoachScoreScreen());

    signupLoading.value = false;
  }

  Future<void> logout() async {
    await _prefs?.setBool('isLoggedIn', false);
    await _prefs?.remove('current_user_email');
    isLoggedIn.value = false;

    Get.snackbar(
      'Success',
      'Logged out successfully!',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      snackPosition: SnackPosition.TOP,
    );
  }

  String? getCurrentUserEmail() {
    return _prefs?.getString('current_user_email');
  }

  String? getCurrentUserName() {
    return _prefs?.getString('user_name');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
