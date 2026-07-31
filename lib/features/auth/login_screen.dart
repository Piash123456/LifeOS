import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_screen.dart';
import '../dashboard/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // খুব হালকা একটা ব্যাকগ্রাউন্ড
      body: Stack(
        children: [
          // 🎯 ব্যাকগ্রাউন্ডের ভাসমান কালারফুল বল (Glassmorphism Effect)
          Positioned(top: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade300.withOpacity(0.5)))),
          Positioned(bottom: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade300.withOpacity(0.4)))),
          Positioned(top: 200, right: -100, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pink.shade200.withOpacity(0.3)))),
          
          // 🎯 ব্লার ইফেক্ট (Blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.2)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInAnimation(
                      delay: 100,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
                        child: Icon(Icons.fingerprint_rounded, size: 70, color: Colors.deepPurple.shade600),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    FadeInAnimation(
                      delay: 200,
                      child: Text('Welcome Back', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1), textAlign: TextAlign.center),
                    ),
                    FadeInAnimation(
                      delay: 300,
                      child: Text('Enter your details to access your dashboard', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade700), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 40),

                    FadeInAnimation(delay: 400, child: _buildTextField(controller: _emailController, hint: 'Email Address', icon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress)),
                    const SizedBox(height: 16),
                    FadeInAnimation(
                      delay: 500,
                      child: _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline_rounded, isPassword: true, isVisible: _isPasswordVisible, onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                    ),
                    const SizedBox(height: 32),

                    FadeInAnimation(
                      delay: 600,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.deepPurple.shade500, Colors.indigo.shade600]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Log In', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FadeInAnimation(
                      delay: 700,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 15)),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                            child: Text("Sign Up", style: GoogleFonts.poppins(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool isVisible = false, TextInputType keyboardType = TextInputType.text, VoidCallback? onVisibilityToggle}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
      child: TextField(
        controller: controller, obscureText: isPassword && !isVisible, keyboardType: keyboardType, style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
          suffixIcon: isPassword ? IconButton(icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade400), onPressed: onVisibilityToggle) : null,
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }
}

// 🎯 কাস্টম অ্যানিমেশন উইজেট (Slide up and Fade in)
class FadeInAnimation extends StatelessWidget {
  final int delay;
  final Widget child;

  const FadeInAnimation({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)), // নিচ থেকে উপরে উঠবে
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}