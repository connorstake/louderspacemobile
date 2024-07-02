import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:louderspacemobile/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Rive animation covering the whole screen
          Positioned.fill(
            child: RiveAnimation.asset(
              'assets/rive/treesv2.riv',
              fit: BoxFit.cover,
            ),
          ),
          // Overlay content (login form)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final username = _usernameController.text;
                    final password = _passwordController.text;
                    try {
                      await Provider.of<AuthProvider>(context, listen: false).login(username, password);
                      Navigator.pushReplacementNamed(context, '/');
                    } catch (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: ${err.toString()}'))
                      );
                    }
                  },
                  child: Text('Login'),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
