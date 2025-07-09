import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  String username = '';
  String profileUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(
            user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            username = data['username'] ?? 'User';
            profileUrl = data['profileUrl'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            username = 'User';
            profileUrl = '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        username = 'User';
        profileUrl = '';
        isLoading = false;
      });
    }
  }

  Future<void> deleteNotification(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notifikasi')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus notifikasi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
              "Notifikasi", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(
          child: Text(
              "Anda belum login.", style: TextStyle(color: Colors.black)),
        ),
      );
    }

    final notifStream = FirebaseFirestore.instance
        .collection('notifikasi')
        .where('userId', isEqualTo: user.uid)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
              child: Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: notifStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Terjadi kesalahan saat memuat notifikasi."),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("Belum ada notifikasi."),
                    );
                  }

                  final sortedDocs = docs.toList()
                    ..sort((a, b) {
                      final aTimestamp = (a['timestamp'] as Timestamp?)
                          ?.toDate();
                      final bTimestamp = (b['timestamp'] as Timestamp?)
                          ?.toDate();
                      if (aTimestamp == null || bTimestamp == null) return 0;
                      return bTimestamp.compareTo(aTimestamp);
                    });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sortedDocs.length,
                    itemBuilder: (context, index) {
                      final docSnapshot = sortedDocs[index];
                      final data = docSnapshot.data() as Map<String, dynamic>?;

                      if (data == null) return const SizedBox();

                      final message = data['message'] ?? "Pesan kosong";
                      final timestamp = (data['timestamp'] as Timestamp?)
                          ?.toDate();
                      final formattedTime = timestamp != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
                          : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                                Icons.notifications, color: Colors.blueAccent),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  if (formattedTime.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        formattedTime,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) =>
                                        AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                              'Yakin ingin menghapus notifikasi ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    await deleteNotification(docSnapshot.id);
                                  }
                                }
                              },
                              itemBuilder: (context) =>
                              [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.black87),
                                      SizedBox(width: 8),
                                      Text("Hapus"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          profileUrl.isNotEmpty
              ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(profileUrl))
              : Container(
            width: 40,
            height: 40,
            decoration:
            BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text('Hallo, $username',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.notifications, color: Colors.black),
        ],
      ),
    );
  }
}
