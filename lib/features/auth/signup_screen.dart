import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match!')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(), password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Created Successfully! 🎉')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup Failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo.shade300.withOpacity(0.5)))),
          Positioned(bottom: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.teal.shade300.withOpacity(0.4)))),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.2)),
          ),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
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
                              child: Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.indigo.shade600),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          FadeInAnimation(delay: 200, child: Text('Join LifeOS', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1), textAlign: TextAlign.center)),
                          FadeInAnimation(delay: 300, child: Text('Create an account to start your journey', style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade700), textAlign: TextAlign.center)),
                          const SizedBox(height: 40),

                          FadeInAnimation(delay: 400, child: _buildTextField(controller: _emailController, hint: 'Email Address', icon: Icons.alternate_email_rounded, keyboardType: TextInputType.emailAddress)),
                          const SizedBox(height: 16),
                          FadeInAnimation(delay: 500, child: _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline_rounded, isPassword: true, isVisible: _isPasswordVisible, onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible))),
                          const SizedBox(height: 16),
                          FadeInAnimation(delay: 600, child: _buildTextField(controller: _confirmPasswordController, hint: 'Confirm Password', icon: Icons.lock_reset_rounded, isPassword: true, isVisible: _isPasswordVisible, onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible))),
                          const SizedBox(height: 32),

                          FadeInAnimation(
                            delay: 700,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.indigo.shade500, Colors.deepPurple.shade600]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signup,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign Up', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
          hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500), prefixIcon: Icon(icon, color: Colors.indigo.shade300),
          suffixIcon: isPassword ? IconButton(icon: Icon(isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.grey.shade400), onPressed: onVisibilityToggle) : null,
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }
}

// 🎯 কাস্টম অ্যানিমেশন উইজেট
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
          child: Transform.translate(offset: Offset(0, 50 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}