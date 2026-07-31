import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  
  void _showAddSessionSheet(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, 
                left: 24, right: 24, top: 32
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Log New Session 📚', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _buildTextField(controller: subjectController, hint: 'Subject Name (e.g. Math)', icon: Icons.menu_book_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(controller: timeController, hint: 'Time Studied (in hours)', icon: Icons.timer_outlined, isNumber: true),
                  const SizedBox(height: 32),
                  
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.indigo.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (subjectController.text.trim().isEmpty || timeController.text.trim().isEmpty) return;
                        setModalState(() => isSaving = true);
                        try {
                          await FirebaseFirestore.instance.collection('study_sessions').add({
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'subject': subjectController.text.trim(),
                            'time': double.parse(timeController.text.trim()),
                            'date': DateTime.now(),
                          });
                          if (context.mounted) Navigator.pop(context);
                        } finally {
                          setModalState(() => isSaving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Save Session', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.indigo.shade300),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  // 🎯 স্টাডি সেশন ডিলিট করার ফাংশন
  Future<void> _deleteSession(String docId) async {
    await FirebaseFirestore.instance.collection('study_sessions').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Study Tracker', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))]
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSessionSheet(context),
          backgroundColor: Colors.indigo.shade600,
          elevation: 0,
          icon: const Icon(Icons.add_task_rounded, color: Colors.white), 
          label: Text('Add Session', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text('Recent Sessions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('study_sessions').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No study sessions logged yet.', style: GoogleFonts.poppins(color: Colors.grey)));

                  final docs = snapshot.data!.docs;
                  docs.sort((a, b) => (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final docId = docs[index].id;
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['date'] as Timestamp?;
                      final dateString = timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                            child: Icon(Icons.menu_book_rounded, color: Colors.blue.shade500),
                          ),
                          title: Text(data['subject'] ?? 'Unknown', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          subtitle: Text('${data['time']} Hours  •  $dateString', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600)),
                          
                          // 🎯 ডিলিট বাটন এবং কনফার্মেশন ডায়ালগ
                          trailing: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text('Wait! 🛑', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
                                  content: Text('Are you sure you want to delete this session? This action cannot be undone.', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteSession(docId); 
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                      child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}