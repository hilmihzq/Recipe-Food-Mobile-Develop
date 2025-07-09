import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateResepPage extends StatefulWidget {
  final DocumentSnapshot? data; // Untuk mode edit

  const CreateResepPage({super.key, this.data});

  @override
  State<CreateResepPage> createState() => _CreateResepPageState();
}

class _CreateResepPageState extends State<CreateResepPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _bahanController = TextEditingController();
  final TextEditingController _caraController = TextEditingController();
  final TextEditingController _tipsController = TextEditingController();

  String username = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsernameAndFillForm();
  }

  Future<void> fetchUsernameAndFillForm() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        username = doc.exists ? (doc['username'] ?? 'User') : 'User';
      });
    }

    // Jika mode edit, isi field
    if (widget.data != null) {
      final data = widget.data!;
      _titleController.text = data['title'] ?? '';
      _imageController.text = data['imageUrl'] ?? '';
      _descController.text = data['description'] ?? '';
      _bahanController.text = data['bahan'] ?? '';
      _caraController.text = data['cara'] ?? '';
      _tipsController.text = data['tips'] ?? '';
    }

    setState(() => isLoading = false);
  }

  void _publishResep() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_formKey.currentState!.validate() && uid != null) {
      await FirebaseFirestore.instance.collection('resep').add({
        'title': _titleController.text,
        'chef': username,
        'uid': uid,
        'imageUrl': _imageController.text,
        'description': _descController.text,
        'bahan': _bahanController.text,
        'cara': _caraController.text,
        'tips': _tipsController.text,
        'createdAt': Timestamp.now(),
      });
      Navigator.pop(context);
    }
  }

  void _updateResep() async {
    if (_formKey.currentState!.validate() && widget.data != null) {
      await FirebaseFirestore.instance
          .collection('resep')
          .doc(widget.data!.id)
          .update({
        'title': _titleController.text,
        'imageUrl': _imageController.text,
        'description': _descController.text,
        'bahan': _bahanController.text,
        'cara': _caraController.text,
        'tips': _tipsController.text,
        'updatedAt': Timestamp.now(),
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    _descController.dispose();
    _bahanController.dispose();
    _caraController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.data != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Resep" : "Buat Resep"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _inputField("Judul Resep", _titleController),
              _inputField("URL Gambar", _imageController),
              _inputField("Deskripsi", _descController, maxLines: 3),
              _inputField("Bahan-bahan", _bahanController, maxLines: 4),
              _inputField("Cara Memasak", _caraController, maxLines: 5),
              _inputField("Tips", _tipsController, maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isEditMode ? _updateResep : _publishResep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditMode ? "Update" : "Publish"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? 'Bagian "$label" wajib diisi' : null,
      ),
    );
  }
}
