import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';


import 'forgot_password_page.dart';
import 'signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _controller;
  late final Animation<double>   _opacityAnim;
  late final Animation<Offset>   _slideAnim;

  bool _isLoginPressed    = false;
  bool _isRegisterPressed = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnim   = Tween(begin: const Offset(0, .2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Error', 'Email dan password harus diisi.');
      return;
    }

    setState(() => _isLoading = true);
    print('Attempting login with email: $email');

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print('Login success: user=${userCredential.user?.email}');

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException caught: code=${e.code}, message=${e.message}');
      final msg = switch (e.code) {
        'user-not-found'     => 'Akun tidak ditemukan. Silakan daftar dulu.',
        'wrong-password'     => 'Password salah. Coba lagi.',
        'invalid-email'      => 'Format email tidak valid.',
        'user-disabled'      => 'Akun telah dinonaktifkan.',
        'invalid-credential' => 'Email atau password salah. Coba lagi.',
        _ => e.message ?? 'Kesalahan login.',
      };


      _showDialog('Error', msg);
    } catch (e, stack) {
      print('Unexpected error: $e');
      print(stack);
      _showDialog('Error', 'Terjadi kesalahan tidak terduga.\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _opacityAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                        "Welcome back! Glad to see you, Again!",
                        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 40),

                    _inputBox(_emailController, hint: 'Enter your email', keyboard: TextInputType.emailAddress, width: width),
                    const SizedBox(height: 20),
                    _inputBox(_passwordController, hint: 'Enter your password', obscure: true, width: width),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                      onTapDown: (_) => setState(() => _isLoginPressed = true),
                      onTapUp: (_)   => setState(() => _isLoginPressed = false),
                      onTapCancel:   () => setState(() => _isLoginPressed = false),
                      onTap: _tryLogin,
                      child: AnimatedScale(
                        scale: _isLoginPressed ? .95 : 1,
                        duration: const Duration(milliseconds: 100),
                        child: _buttonBox('Login', width),
                      ),
                    ),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTapDown: (_) => setState(() => _isRegisterPressed = true),
                      onTapUp: (_)   => setState(() => _isRegisterPressed = false),
                      onTapCancel:   () => setState(() => _isRegisterPressed = false),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                      child: AnimatedScale(
                        scale: _isRegisterPressed ? .95 : 1,
                        duration: const Duration(milliseconds: 100),
                        child: const Text.rich(
                          TextSpan(
                              text: "Don’t have an account? ",
                              children: [
                                TextSpan(
                                    text: "Register Now",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline
                                    )
                                )
                              ]
                          ),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBox(TextEditingController c, {required String hint, bool obscure = false, TextInputType keyboard = TextInputType.text, required double width}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buttonBox(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}



