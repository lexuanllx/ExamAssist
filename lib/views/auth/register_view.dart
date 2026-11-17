
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final contact = TextEditingController();
  final password = TextEditingController();

  // Validate Malaysian mobile phone numbers
  String? validateMalaysianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your contact number';
    }

    final phoneRegex = RegExp(
      r'^(?:01[0-9]{8,9}|\+?601[0-9]{8,9})$',
    );

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid Malaysian mobile number';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    contact.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> register() async {
    // Validate all Form fields first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields.'),
        ),
      );
      return;
    }

    final success = await context.read<AuthViewModel>().register(
      name: name.text.trim(),
      email: email.text.trim(),
      password: password.text,
      contact: contact.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthViewModel>().errorMessage ??
                'Registration failed.',
          ),
        ),
      );
    }
  }

  Widget input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              input('Full Name', name),
              input('Email',
                    email,
                    validator: validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
              input(
                'Contact Number',
                contact,
                validator: validateMalaysianPhone,
                keyboardType: TextInputType.phone,
              ),
              input(
                'Password',
                password,
                obscure: true,
              ),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Default role: Assistant Invigilator',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : register,
                  child: vm.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
