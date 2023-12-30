import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../Models/User.dart';
import '../constants.dart';
import '../Provider/AuthProvider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String apiUrl = '$baseUrl/api/auth/login';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'usernameOrEmail': _usernameController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      final User user = User(
        id: responseData['id'],
        fullname: responseData['fullname'],
        username: responseData['username'],
        email: responseData['email'],
        address: responseData['address'],
        phone: responseData['phone'],
      );

      Provider.of<AuthProvider>(context, listen: false).setAuthenticated(true);
      Provider.of<AuthProvider>(context, listen: false).setCurrentUser(user);

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }

      _usernameController.clear();
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildInputField(
      TextEditingController controller, String labelText, bool obscureText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInputField(_usernameController, 'Username or Email', false),
              const SizedBox(height: 20),
              _buildInputField(_passwordController, 'Password', true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
