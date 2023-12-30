import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/User.dart';
import '../Provider/AuthProvider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/User.dart';
import '../Provider/AuthProvider.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isAuthenticated) {
              User? user = authProvider.currentUser;
              return _buildUserProfile(context, user);
            } else {
              return _buildLoginPrompt(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User? user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60.0,
              backgroundColor: Colors.deepPurple.shade100,
              child: CircleAvatar(
                radius: 55.0,
                backgroundImage: NetworkImage(user?.avatarUrl ??
                    'https://media.istockphoto.com/id/1223671392/vi/vec-to/%E1%BA%A3nh-h%E1%BB%93-s%C6%A1-m%E1%BA%B7c-%C4%91%E1%BB%8Bnh-h%C3%ACnh-%C4%91%E1%BA%A1i-di%E1%BB%87n-ch%E1%BB%97-d%C3%A0nh-s%E1%BA%B5n-cho-%E1%BA%A3nh-minh-h%E1%BB%8Da-vect%C6%A1.jpg?s=612x612&w=0&k=20&c=l9x3h9RMD16-z4kNjo3z7DXVEORzkxKCMn2IVwn9liI='),
                onBackgroundImageError: (exception, stackTrace) =>
                    Image.asset('assets/default_avatar.png'),
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              user?.fullname ?? 'Unknown User',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'No Email',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 20.0),
            _buildDetailButton(context, 'View User Details', Icons.person, () {
              //Navigator.pushNamed(context, '/userDetail');
            }),
            _buildDetailButton(context, 'View Order Details', Icons.receipt,
                () {
              Navigator.pushNamed(context, '/bill');
            }),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _userInfoCard(String title, String value) {
    return Card(
      elevation: 4.0,
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        leading: const Icon(Icons.account_circle, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildDetailButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(label),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _logout(context),
      icon: const Icon(Icons.exit_to_app, color: Colors.white),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        child: const Text('Login'),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      const String apiUrl = '$baseUrl/api/auth/logout';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        Provider.of<AuthProvider>(context, listen: false)
            .setAuthenticated(false);
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Logout failed')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error during logout')));
    }
  }
}
