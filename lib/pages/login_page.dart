import 'package:flutter/material.dart';
import '../services/authentication_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              Text(
                'Log In',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField
              (onChanged: (value) {
                password = value;
              },
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                   onPressed: () {
                    AuthenticationService().login(email, password).then((success) {
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to login, Something wrong.')),
                        );
                      }
                    });
                   },
                   style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                   ),
                   child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                   ),
                   ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFDBE2EF),
                    foregroundColor: const Color(0xFF3F72AF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Register'),
              ),
              ),
            ]
          )
        )
      )
    );
  }
}