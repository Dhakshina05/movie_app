import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Helper to show SnackBar
  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Login method with improved error logging
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print("Email:$email");
    print("Password:$password");

    if (email.isEmpty || password.isEmpty) {
      showSnackBar('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Signed in: ${userCred.user?.uid}');
      showSnackBar('Logged in successfully');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Print exact code/message — paste this output if you need more help
      print('FirebaseAuthException: code=${e.code} message=${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'network-request-failed':
          errorMessage = 'No internet connection.';
          break;
        case 'invalid-credential':
        case 'invalid-verification-code':
        case 'invalid-verification-id':
          errorMessage = 'The supplied auth credential is invalid or expired.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      print('Login failed: $errorMessage');
      showSnackBar(errorMessage);
    } catch (e, st) {
      print('Other login error: $e\n$st');
      showSnackBar('An unknown error occurred');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Register helper — use this to create user for testing
  Future<void> registerEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showSnackBar('Please enter email and password to register');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      print('Registered: ${userCred.user?.uid}');
      showSnackBar('Registered successfully. You can now log in.');
    } on FirebaseAuthException catch (e) {
      print('Register FirebaseAuthException: code=${e.code} message=${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak (min 6 chars).';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }
      showSnackBar(errorMessage);
    } catch (e, st) {
      print('Other register error: $e\n$st');
      showSnackBar('An unknown error occurred during registration');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie,
                size: 80,
                color: isDark ? Colors.red : Colors.black,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      "Don't have an account? Register now",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  // For quick testing: a small Register button that uses current fields.
                  // Remove or hide in production; useful to create the test user quickly.
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => registerEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                    child: const Text('Quick Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
