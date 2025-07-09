import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_resep.dart';
import 'notifikasi_page.dart';
import 'resep.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      } else {
        setState(() {
          username = 'User';
          profileUrl = '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        username = 'User';
        profileUrl = '';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ResepPage()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProfilePage()));
    }
    else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (
          _) => const NotifikasiPage())); // <-- Tambahan untuk notifikasi
    }

    // Tambahkan handler lain jika dibutuhkan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: ListView(
          children: [
            _buildHeader(),
            _buildSectionTitle("Featured"),
            _buildFeaturedList(),
            _buildSectionTitle("Popular Recipes", showAll: true),
            _buildPopularList(),
            _buildSectionTitle("Category", showAll: true),
            _buildCategoryRow(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            child: profileUrl.isNotEmpty
                ? CircleAvatar(
                radius: 20, backgroundImage: NetworkImage(profileUrl))
                : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('Hallo, $username',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotifikasiPage()),
              );
            },
            child: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (showAll)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResepPage()),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(color: Colors.blueAccent, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildFeaturedList() {
    return SizedBox(
      height: 170,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('iklan')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No featured ads'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final author = data['author'] ?? '';
              final duration = data['duration'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';
              return _featuredCard(
                title: title,
                author: author,
                duration: duration,
                imageUrl: imageUrl,
              );
            },
          );
        },
      ),
    );
  }

  Widget _featuredCard({
    required String title,
    required String author,
    required String duration,
    String? imageUrl,
  }) {
    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[300],
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(author,
                          style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                      const Spacer(),
                      const Icon(
                          Icons.schedule, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(duration,
                          style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  Widget _buildPopularList() {
    return SizedBox(
      height: 250,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('popular_recipes')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No popular recipes'));
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final subtitle = data['subtitle'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';
              return _popularCard(
                title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
              );
            },
          );
        },
      ),
    );
  }

  Widget _popularCard({
    required String title,
    required String subtitle,
    String? imageUrl,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.7),
              child: const Icon(Icons.favorite_border, size: 18),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCategoryRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resep')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Belum ada resep yang tersedia'),
          );
        }

        final resepDocs = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: resepDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _categoryCard(
                  data: doc, // Kirim seluruh doc supaya bisa akses data lengkap
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _categoryCard({
    required DocumentSnapshot data,
  }) {
    final recipeData = data.data() as Map<String, dynamic>? ?? {};
    final title = recipeData['title'] ?? 'Tanpa Judul';
    final imageUrl = recipeData['imageUrl'] ?? '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailResepPage(data: data), // Ganti dengan halaman tujuanmu
          ),
        );
      },
      child: Container(
        width: 185,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: 140,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      width: 140,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(
                          Icons.image_not_supported, color: Colors.grey),
                    ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.local_fire_department, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('120 Kcal',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                SizedBox(width: 10),
                Icon(Icons.schedule, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('20 Min',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
