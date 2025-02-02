import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_view_model.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final profile = profileViewModel.profile;

    // 프로필 데이터가 로드되지 않았을 때 로딩 인디케이터를 보여줌
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

    // 프로필 페이지 UI
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          // 프로필 편집 페이지로 이동하는 아이콘 버튼
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditPage(profile: profile)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // ListView를 사용하여 overflow 문제를 해결함
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profile.profilePictureUrl.isNotEmpty
                    ? FileImage(File(profile.profilePictureUrl))
                    : AssetImage('assets/images/default_profile_picture.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                profile.nickname,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      title: Text(
                        'ID',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        profile.id,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Favorite Leagues',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        profile.favoriteLeagues.join(', '),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Favorite Teams',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        profile.favoriteTeams.join(', '),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'Favorite Players',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        profile.favoritePlayers.join(', '),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        'City',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        profile.city,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
