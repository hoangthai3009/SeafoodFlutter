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
        title: Text('Profile'),
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isAuthenticated) {
            User? currentUser = authProvider.currentUser;
            return ListView(
              children: [
                _buildProfileHeader(context, currentUser),
                Divider(),
                _buildProfileSection(
                    'Email', currentUser?.email ?? 'Not available'),
                _buildProfileSection(
                    'Username', currentUser?.username ?? 'Not available'),
                // Add more sections as needed
                Divider(),
                _buildLogoutButton(context),
              ],
            );
          } else {
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  onPrimary: Colors.white,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 40,
          //   backgroundImage: NetworkImage(user?.profilePicture ?? 'default_profile_pic_url'),
          // ),
          //SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? 'Username',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  user?.email ?? 'Email',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
        icon: Icon(Icons.logout),
        label: Text('Logout'),
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          onPrimary: Colors.white,
        ),
      ),
    );
  }

  // Hàm thực hiện logout
  Future<void> _logout(BuildContext context) async {
    try {
      final String apiUrl = '$baseUrl/api/auth/logout';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        Provider.of<AuthProvider>(context, listen: false)
            .setAuthenticated(false);
        Provider.of<AuthProvider>(context, listen: false).setCurrentUser(null);
      }
    } catch (error) {
      print('Logout failed: $error');
    }
  }
}
