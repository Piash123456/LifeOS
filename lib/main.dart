import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// আপনার তৈরি করা পেজগুলো ইম্পোর্ট করা হলো
import 'features/auth/login_screen.dart';
import 'features/dashboard/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ফায়ারবেস চালু করা
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false, // ডানদিকের কোণার Debug লেখাটি মুছে ফেলার জন্য
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ), // পুরো অ্যাপের ডিফল্ট ফন্ট Poppins করে দেওয়া হলো
      ),
      
      // 🎯 ম্যাজিকটা এখানে! অ্যাপ ওপেন হলেই এই StreamBuilder চেক করবে ইউজার আছে কি না
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // চেক করার সময় একটু লোডিং দেখাবে (খুবই দ্রুত হয়ে যায়)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              ),
            );
          }
          
          // যদি ইউজারের ডেটা পাওয়া যায় (তার মানে সে আগেই লগইন করেছিল)
          if (snapshot.hasData) {
            return const MainLayout(); // সরাসরি ড্যাশবোর্ডে নিয়ে যাবে!
          }
          
          // আর যদি ডেটা না থাকে (লগআউট করা থাকে বা নতুন ইউজার হয়)
          return const LoginScreen(); // লগইন পেজ দেখাবে
        },
      ),
    );
  }
}