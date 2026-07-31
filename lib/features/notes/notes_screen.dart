import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  
  void _showAddNoteSheet(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Write a Note 📝', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  _buildTextField(controller: titleController, hint: 'Note Title', icon: Icons.title_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(controller: contentController, hint: 'What\'s on your mind?', icon: Icons.notes_rounded, isMultiline: true),
                  const SizedBox(height: 32),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.green.shade600]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                        setModalState(() => isSaving = true);
                        try {
                          await FirebaseFirestore.instance.collection('notes').add({
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'title': titleController.text.trim(),
                            'content': contentController.text.trim(),
                            'date': DateTime.now(),
                          });
                          if (context.mounted) Navigator.pop(context);
                        } finally {
                          setModalState(() => isSaving = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text('Save Note', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isMultiline = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller, maxLines: isMultiline ? 4 : 1, style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500), prefixIcon: isMultiline ? Padding(padding: const EdgeInsets.only(bottom: 60), child: Icon(icon, color: Colors.teal.shade300)) : Icon(icon, color: Colors.teal.shade300), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16)),
      ),
    );
  }

  Future<void> _deleteNote(String docId) async {
    await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: Text('My Notes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))]),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddNoteSheet(context),
          backgroundColor: Colors.teal.shade600, elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white), 
          label: Text('Add Note', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notes').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No notes yet.', style: GoogleFonts.poppins(color: Colors.grey)));

                  final docs = snapshot.data!.docs;
                  docs.sort((a, b) => (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final docId = docs[index].id; 
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['date'] as Timestamp?;
                      final dateString = timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : '';

                      final colors = [Colors.teal.shade50, Colors.amber.shade50, Colors.blue.shade50, Colors.pink.shade50];
                      final bgColor = colors[index % colors.length];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bgColor, borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(data['title'] ?? 'No Title', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87))),
                                
                                // 🎯 ডিলিট বাটন এবং কনফার্মেশন ডায়ালগ
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: Text('Wait! 🛑', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
                                        content: Text('Are you sure you want to delete this note? This action cannot be undone.', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _deleteNote(docId); 
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
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                                    child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(dateString, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 12),
                            Text(data['content'] ?? '', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, height: 1.5)),
                          ],
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