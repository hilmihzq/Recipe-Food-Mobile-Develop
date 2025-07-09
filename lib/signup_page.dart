import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart'; // pastikan file ini ada dan sesuai

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpPage(),
  ));
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePw = true, _hidePw2 = true;
  bool _isLoading = false;

  final first = TextEditingController(),
      last = TextEditingController(),
      user = TextEditingController(),
      mail = TextEditingController(),
      phone = TextEditingController(),
      pass = TextEditingController(),
      pass2 = TextEditingController();

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    user.dispose();
    mail.dispose();
    phone.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (pass.text != pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: mail.text.trim(), password: pass.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'first_name': first.text.trim(),
        'last_name': last.text.trim(),
        'username': user.text.trim(),
        'email': mail.text.trim(),
        'phone': phone.text.trim(),
        'created_at': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuat!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password terlalu lemah';
      } else {
        message = e.message ?? message;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Hello! Register to get started",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _field("First name", first,
                            validator: _onlyLetters),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _field("Last name", last,
                            validator: _onlyLetters),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _field("Username", user, validator: _usernameValidator),
                  const SizedBox(height: 20),

                  _field("Email", mail,
                      keyboardType: TextInputType.emailAddress,
                      validator: _gmailOnly),
                  const SizedBox(height: 20),

                  _field("Phone number", phone,
                      keyboardType: TextInputType.phone,
                      validator: _indoPhoneValidator),
                  const SizedBox(height: 20),

                  _field("Password", pass,
                      obscure: _hidePw,
                      keyboardType: TextInputType.visiblePassword,
                      suffix: IconButton(
                        icon: Icon(_hidePw
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _hidePw = !_hidePw),
                      ),
                      validator: _pwMin6),
                  const SizedBox(height: 20),

                  _field("Confirm password", pass2,
                      obscure: _hidePw2,
                      keyboardType: TextInputType.visiblePassword,
                      suffix: IconButton(
                        icon: Icon(_hidePw2
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _hidePw2 = !_hidePw2),
                      ),
                      validator: _pwMin6),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _register,
                      child: const Text("Register",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text.rich(TextSpan(
                        text: "Already have an account? ",
                        children: [
                          TextSpan(
                              text: "Login Now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue))
                        ])),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Widget Builder ----------
  Widget _field(String hint, TextEditingController c,
      {bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        Widget? suffix,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: suffix,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  // ---------- Validators ----------
  String? _onlyLetters(String? v, {int min = 1}) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^[A-Za-z]+$').hasMatch(v)) return 'Hanya huruf';
    if (v.length < min) return 'Min. $min huruf';
    return null;
  }

  String? _usernameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    if (v.length < 4) return 'Min. 4 karakter';
    if (!RegExp(r'^[A-Za-z0-9._]+$').hasMatch(v)) {
      return 'Hanya huruf, angka, titik, dan underscore';
    }
    return null;
  }

  String? _gmailOnly(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(v)) {
      return 'Gunakan email @gmail.com yang valid';
    }
    return null;
  }

  String? _indoPhoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    if (!RegExp(r'^08\d{8,}$').hasMatch(v)) {
      return 'Harus dimulai dengan 08 dan min. 10 digit';
    }
    return null;
  }

  String? _pwMin6(String? v) =>
      (v == null || v.length < 6) ? 'Min. 6 karakter' : null;
}
