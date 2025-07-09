import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'login.dart';
import 'create_resep.dart';
import 'detail_resep.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String status = '';
  String profileUrl = '';
  String backgroundUrl = '';
  List<DocumentSnapshot> userRecipes = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserRecipes();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          username = doc['username'] ?? 'Username';
          status = doc['status'] ?? 'Mahasiswa FTUI';
          profileUrl = doc['profileUrl'] ?? '';
          backgroundUrl = doc['backgroundUrl'] ?? '';
        });
      }
    }
  }

  Future<void> fetchUserRecipes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('resep')
          .where('uid', isEqualTo: user.uid)
          .get();

      setState(() {
        userRecipes = snapshot.docs;
      });
    }
  }

  Future<void> deleteRecipe(String id) async {
    await FirebaseFirestore.instance.collection('resep').doc(id).delete();
    fetchUserRecipes();
  }

  Future<void> editRecipe(DocumentSnapshot resepData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateResepPage(data: resepData),
      ),
    );
    if (result == true) {
      fetchUserRecipes();
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentUsername: username,
          currentStatus: status,
          currentProfileUrl: profileUrl,
          currentBackgroundUrl: backgroundUrl,
        ),
      ),
    );

    if (result == true) {
      fetchUserData();
    }
  }

  void openDetailRecipe(DocumentSnapshot resepDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailResepPage(data: resepDoc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              image: backgroundUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(backgroundUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: Stack(
              children: [
                if (backgroundUrl.isNotEmpty)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: PopupMenuButton<int>(
                    iconSize: 28,
                    color: Colors.white,
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                    onSelected: (value) async {
                      if (value == 1) {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black54),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          image: profileUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(profileUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: profileUrl.isEmpty
                            ? const Center(
                          child: Icon(Icons.person, color: Colors.white, size: 40),
                        )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5,
                                    color: Colors.black54,
                                    offset: Offset(0, 1),
                                  )
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // EDIT PROFILE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _navigateToEditProfile,
                child: const Text('Edit Profile'),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // RECIPE LIST
          Expanded(
            child: userRecipes.isEmpty
                ? const Center(
              child: Text(
                "Belum ada resep milik kamu.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: userRecipes.length,
              itemBuilder: (context, index) {
                final resepDoc = userRecipes[index];
                final resep = resepDoc.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () => openDetailRecipe(resepDoc),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Resep
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: profileUrl.isNotEmpty
                                      ? NetworkImage(profileUrl)
                                      : null,
                                  child: profileUrl.isEmpty
                                      ? const Icon(Icons.person, size: 18, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      resep['createdAt'] != null
                                          ? (resep['createdAt'] as Timestamp)
                                          .toDate()
                                          .toString()
                                          .split(' ')[0]
                                          : '-',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  editRecipe(resepDoc);
                                } else if (value == 'delete') {
                                  deleteRecipe(resepDoc.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Gambar resep
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: resep['imageUrl'] == null ? Colors.grey[300] : null,
                            image: resep['imageUrl'] != null
                                ? DecorationImage(
                              image: NetworkImage(resep['imageUrl']),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: resep['imageUrl'] == null
                              ? const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white70,
                              size: 50,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          resep['title'] ?? '-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
