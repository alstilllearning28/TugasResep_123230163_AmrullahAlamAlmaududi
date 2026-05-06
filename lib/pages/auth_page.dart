import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _authService = AuthService();

  // Status untuk menentukan form mana yang ditampilkan
  bool _isLogin = true;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginUsernameCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginObscure = true;
  bool _loginLoading = false;

  // Register controllers
  final _regFormKey = GlobalKey<FormState>();
  final _regUsernameCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _regObscurePass = true;
  bool _regObscureConfirm = true;
  bool _regLoading = false;

  @override
  void dispose() {
    _loginUsernameCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    final success = await _authService.login(
      _loginUsernameCtrl.text.trim(),
      _loginPasswordCtrl.text,
    );
    setState(() => _loginLoading = false);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _regLoading = true);
    final success = await _authService.register(
      _regUsernameCtrl.text.trim(),
      _regPasswordCtrl.text,
    );
    setState(() => _regLoading = false);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      // Pindah ke tampilan login & bersihkan form
      setState(() => _isLogin = true);
      _regUsernameCtrl.clear();
      _regPasswordCtrl.clear();
      _regConfirmCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username sudah digunakan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE9), // Latar bernuansa coklat terang
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & judul
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      12), // Opsional: untuk membuat sudut gambar sedikit membulat
                  child: Image.asset(
                    'assets/image_9547ac.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLogin ? 'Selamat Datang' : 'Buat Akun Baru',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  _isLogin
                      ? 'Silakan login ke akun ResepKu Anda'
                      : 'Daftar untuk menjelajahi ribuan resep masakan',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 32),

                // Menampilkan form sesuai state (tanpa slider tab)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── LOGIN FORM ────────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Username'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginUsernameCtrl,
            decoration:
                _inputDecoration('Masukkan username', Icons.person_outline),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Username wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          _label('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _loginObscure,
            decoration: _inputDecoration(
              'Masukkan password',
              Icons.lock_outline,
              suffix: _eyeButton(
                _loginObscure,
                () => setState(() => _loginObscure = !_loginObscure),
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Password wajib diisi' : null,
          ),
          const SizedBox(height: 28),
          _submitButton('Login', _loginLoading, _login),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = false),
              child: const Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                  TextSpan(
                    text: 'Daftar',
                    style: TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REGISTER FORM ─────────────────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Username'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _regUsernameCtrl,
            decoration:
                _inputDecoration('Masukkan username', Icons.person_outline),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Username wajib diisi';
              if (v.trim().length < 3) return 'Minimal 3 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _label('Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _regPasswordCtrl,
            obscureText: _regObscurePass,
            decoration: _inputDecoration(
              'Masukkan password',
              Icons.lock_outline,
              suffix: _eyeButton(
                _regObscurePass,
                () => setState(() => _regObscurePass = !_regObscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password wajib diisi';
              if (v.length < 6) return 'Minimal 6 karakter';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _label('Konfirmasi Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _regConfirmCtrl,
            obscureText: _regObscureConfirm,
            decoration: _inputDecoration(
              'Ulangi password',
              Icons.lock_outline,
              suffix: _eyeButton(
                _regObscureConfirm,
                () => setState(() => _regObscureConfirm = !_regObscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty)
                return 'Konfirmasi password wajib diisi';
              if (v != _regPasswordCtrl.text) return 'Password tidak cocok';
              return null;
            },
          ),
          const SizedBox(height: 28),
          _submitButton('Daftar', _regLoading, _register),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = true),
              child: const Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(color: Color(0xFF888888)),
                  ),
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: Color(0xFF4E342E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF555555),
        ),
      );

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF4E342E)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF888888),
        ),
        onPressed: onTap,
      );

  Widget _submitButton(String label, bool loading, VoidCallback onTap) =>
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E342E),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
}
