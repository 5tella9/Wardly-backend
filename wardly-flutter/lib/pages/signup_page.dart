import 'package:flutter/material.dart';
import '../auth_service.dart';
// ignore: unused_import
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback? onSigned;

  const SignupPage({super.key, this.onSigned});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _doSignup() async {
  setState(() => _loading = true);

  final err = await AuthService.signup(
    username: _userCtrl.text.trim(),
    email: _emailCtrl.text.trim(),
    password: _passCtrl.text,
  );

  if (!mounted) return;
  setState(() => _loading = false);

  if (err != null) {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err)),
    );
    return; 
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Signup successful! Please log in.')),
  );

  widget.onSigned?.call();
}


  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _doSignup,
                    child: const Text('Sign Up'),
                  ),
          ],
        ),
      ),
    );
  }
}
