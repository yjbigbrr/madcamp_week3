import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_view_model.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final profile = profileViewModel.profile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nickname: ${profile.nickname}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('ID: ${profile.id}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Favorite Leagues: ${profile.favoriteLeagues.join(', ')}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Favorite Teams: ${profile.favoriteTeams.join(', ')}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Favorite Players: ${profile.favoritePlayers.join(', ')}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('City: ${profile.city}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileEditPage(profile: profile)),
                  );
                },
                child: Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}