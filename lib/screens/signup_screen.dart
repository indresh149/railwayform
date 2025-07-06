import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue[100]!,
              Colors.white,
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 30),

                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    'Sign up to get started',
                    style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                  ),

                  SizedBox(height: 40),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: TextFormField(
                              controller: authController.nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.blue[600],
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                                labelStyle: TextStyle(color: Colors.blue[600]),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: TextFormField(
                              controller: authController.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.blue[600],
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(20),
                                labelStyle: TextStyle(color: Colors.blue[600]),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.blue[100]!),
                              ),
                              child: TextFormField(
                                controller: authController.passwordController,
                                obscureText:
                                    authController.isPasswordHidden.value,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.blue[600],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.isPasswordHidden.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue[600],
                                    ),
                                    onPressed: () {
                                      authController.togglePasswordVisibility();
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20),
                                  labelStyle: TextStyle(
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.blue[100]!),
                              ),
                              child: TextFormField(
                                controller:
                                    authController.confirmPasswordController,
                                obscureText: authController
                                    .isConfirmPasswordHidden
                                    .value,
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.blue[600],
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController
                                              .isConfirmPasswordHidden
                                              .value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.blue[600],
                                    ),
                                    onPressed: () {
                                      authController
                                          .toggleConfirmPasswordVisibility();
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20),
                                  labelStyle: TextStyle(
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          Obx(
                            () => Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[600]!,
                                    Colors.blue[800]!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authController.signupLoading.value
                                    ? null
                                    : () {
                                        authController.signup();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: authController.signupLoading.value
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            'By signing up, you agree to our Terms of Service and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.blue[600], fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
