import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailResepPage extends StatefulWidget {
  final DocumentSnapshot data;

  const DetailResepPage({super.key, required this.data});

  @override
  State<DetailResepPage> createState() => _DetailResepPageState();
}

class _DetailResepPageState extends State<DetailResepPage> {
  late Future<DocumentSnapshot?> userProfileFuture;

  @override
  void initState() {
    super.initState();
    // Ambil user profile pembuat resep berdasarkan uid resep
    userProfileFuture = getUserProfile(widget.data['uid'] ?? '');
  }

  // Fungsi untuk dapatkan user profile berdasarkan UID user
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc;
      } else {
        debugPrint('User document not found for uid: $uid');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Fungsi untuk dapatkan profile user saat ini berdasarkan email (pakai query)
  Future<DocumentSnapshot?> getCurrentUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first;
      } else {
        debugPrint('User document not found for email: ${currentUser.email}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final String title = data['title'] ?? '';
    final String imageUrl = data['imageUrl'] ?? '';
    final String description = data['description'] ?? '';
    final String bahan = data['bahan'] ?? '';
    final String cara = data['cara'] ?? '';
    final String tips = data['tips'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 300,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<DocumentSnapshot?>(
                future: userProfileFuture,
                builder: (context, snapshot) {
                  String username = 'Unknown';
                  String profilePic = '';

                  if (snapshot.hasData && snapshot.data != null) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    username = userData['username'] ?? 'Unknown';
                    profilePic = userData['profileUrl'] ?? '';
                  }

                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (profilePic.isNotEmpty)
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(profilePic),
                              )
                            else
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            const SizedBox(width: 10),
                            Text(
                              'By $username',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomExpansionTile(title: "Deskripsi", content: description),
                        CustomExpansionTile(title: "Bahan-bahan", content: bahan),
                        CustomExpansionTile(title: "Cara Memasak", content: cara),
                        CustomExpansionTile(title: "Tips", content: tips),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CommentSection(
                          recipeDoc: data.reference,
                          getCurrentUserProfile: getCurrentUserProfile,
                        ),
                      ],
                    ),
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

class CommentSection extends StatefulWidget {
  final DocumentReference recipeDoc;
  final Future<DocumentSnapshot?> Function() getCurrentUserProfile;

  const CommentSection({
    super.key,
    required this.recipeDoc,
    required this.getCurrentUserProfile,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = await widget.getCurrentUserProfile();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak ditemukan')),
      );
      return;
    }

    final userData = currentUser.data() as Map<String, dynamic>? ?? {};

    final commentData = {
      'username': userData['username'] ?? 'Unknown',
      'profileUrl': userData['profileUrl'] ?? '',
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    await widget.recipeDoc.collection('comments').add(commentData);

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: widget.recipeDoc
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading comments');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data?.docs ?? [];

            if (comments.isEmpty) {
              return const Text('Belum ada komentar, jadilah yang pertama!');
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: comments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                final username = comment['username'] ?? 'Unknown';
                final profileUrl = comment['profileUrl'] ?? '';
                final commentText = comment['comment'] ?? '';
                Timestamp? ts = comment['timestamp'];
                String timeStr = ts != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                    ts.millisecondsSinceEpoch)
                    .toLocal()
                    .toString()
                    : 'Baru saja';

                return ListTile(
                  leading: profileUrl.isNotEmpty
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(profileUrl),
                  )
                      : const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(username),
                  subtitle: Text(commentText),
                  trailing: Text(
                    timeStr.split('.')[0], // tampilkan tanggal dan jam tanpa millisecond
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final String title;
  final String content;

  const CustomExpansionTile({super.key, required this.title, required this.content});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: false,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.content,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
    );
  }
}
