import 'package:flutter/material.dart';
import 'package:twende/l10n/l10n.dart';
import 'package:twende/main.dart';
import 'package:twende/screen/bottomTab.dart';
import 'package:twende/screen/bottomTabRole6.dart';
import 'package:twende/screen/forgetPassword.dart';
import 'package:twende/screen/registeraccount.dart';
import 'package:twende/screendriver/bottomNavigationdriver.dart';
import 'package:twende/services/auth_service.dart';
import 'package:twende/services/storage_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      // Data is already saved in AuthService.login(), no need to save again
      final userData = result['data']['user'];
      final userRole = userData['role'].toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['data']['message'] ?? 'Login successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Check user role and navigate accordingly
      if (userRole == '3') {
        // Navigate to driver screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationDriver(),
          ),
        );
      } else if (userRole == '6') {
        // Navigate to role 6 screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationRole6(),
          ),
        );
      } else {
        // Navigate to regular bottom navigation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigation(),
          ),
        );
      }
    } else {
      setState(() {
        errorMessage = result['message'];
      });
    }
  }

  // Add a new method to handle guest login
  Future<void> _continueAsGuest() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Set up guest user session
      await StorageService.saveGuestSession();

      setState(() {
        isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Continuing as guest user'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to client-only features
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavigation(isGuestMode: true),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to continue as guest';
      });
    }
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(),
      ),
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'fr':
        return '🇫🇷';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final locale = Localizations.localeOf(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(s.appName,
            style: const TextStyle(
              color: Colors.white,
            )),
        backgroundColor: const Color(0xFF07723D),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0), // Adjust as needed
            child: DropdownButton<Locale>(
              value: locale,
              icon: const Icon(Icons.language, color: Colors.white),
              underline: Container(),
              dropdownColor: const Color(0xFF07723D),
              items: S.supportedLocales
                  .map<DropdownMenuItem<Locale>>((Locale locale) {
                final flag = _getFlag(locale.languageCode);
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        locale.languageCode.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  localeProvider.setLocale(newLocale);
                }
              },
            ), // IconButton(
            //   icon: const Icon(Icons.notifications),
            //   onPressed: () {
            //     if (_isGuestMode) {
            //       _showLoginPrompt();
            //     } else {
            //       // Handle notifications
            //     }
            //   },
            // ),
            // if (_isGuestMode)
            //   Padding(
            //     padding: const EdgeInsets.only(right: 8.0),
            //     child: Chip(
            //       label: Text(l10n.guestMode),
            //       backgroundColor: Colors.amber.shade100,
            //       labelStyle: const TextStyle(fontSize: 12),
            //     ),
            //   )
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      s.signIn,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: s.emailAddress,
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        errorStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                        prefixIcon: const Icon(
                          Icons.email,
                          size: 20,
                        ),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w300),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return s.enterEmail;
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return s.enterValidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password input field with visibility toggle
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: s.enterPassword,
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1),
                        ),
                        errorStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                        prefixIcon: const Icon(
                          Icons.lock,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          tooltip: _passwordVisible
                              ? s.hidePassword
                              : s.showPassword,
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return s.enterPassword;
                        }
                        return null;
                      },
                    ),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _navigateToForgotPassword,
                        child: Text(
                          s.forgotPassword,
                          style: const TextStyle(
                            color: Color(0xFF07723D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Login button
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF07723D))
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF07723D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 90, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(s.signIn),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // Continue without login button
                    TextButton(
                      onPressed: isLoading ? null : _continueAsGuest,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.explore_outlined,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.continueWithoutLogin,
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Create account row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s.dontHaveAccount),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationNewAccount(),
                              ),
                            );
                          },
                          child: Text(
                            s.createAccount,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
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
      ),
    );
  }
}
