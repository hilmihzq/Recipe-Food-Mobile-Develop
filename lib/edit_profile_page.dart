import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentStatus;
  final String currentProfileUrl;
  final String currentBackgroundUrl;

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    required this.currentStatus,
    required this.currentProfileUrl,
    required this.currentBackgroundUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController statusController;
  late TextEditingController profileUrlController;
  late TextEditingController backgroundUrlController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.currentUsername);
    statusController = TextEditingController(text: widget.currentStatus);
    profileUrlController = TextEditingController(text: widget.currentProfileUrl);
    backgroundUrlController = TextEditingController(text: widget.currentBackgroundUrl);
  }

  @override
  void dispose() {
    usernameController.dispose();
    statusController.dispose();
    profileUrlController.dispose();
    backgroundUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'username': usernameController.text.trim(),
          'status': statusController.text.trim(),
          'profileUrl': profileUrlController.text.trim(),
          'backgroundUrl': backgroundUrlController.text.trim(),
        });

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data profile')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard on tap outside
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration('Username'),
                  validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Username tidak boleh kosong' : null,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),

                // Status
                TextFormField(
                  controller: statusController,
                  decoration: _inputDecoration('Status', 'Contoh: Mahasiswa FTUI'),
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),

                // Profile Picture URL
                TextFormField(
                  controller: profileUrlController,
                  decoration: _inputDecoration('Profile Picture URL', 'Masukkan URL gambar profile'),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 20),

                // Background Image URL
                TextFormField(
                  controller: backgroundUrlController,
                  decoration: _inputDecoration('Background Image URL', 'Masukkan URL gambar background'),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSaving
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : Text(
                      'Save',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
