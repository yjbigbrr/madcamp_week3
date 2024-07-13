import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/drawer/profile/profile_model.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';

class ProfileEditPage extends StatefulWidget {
  final MyProfile profile;

  ProfileEditPage({required this.profile});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nicknameController;
  late TextEditingController _favoriteLeaguesController;
  late TextEditingController _favoriteTeamsController;
  late TextEditingController _favoritePlayersController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _favoriteLeaguesController = TextEditingController(text: widget.profile.favoriteLeagues.join(', '));
    _favoriteTeamsController = TextEditingController(text: widget.profile.favoriteTeams.join(', '));
    _favoritePlayersController = TextEditingController(text: widget.profile.favoritePlayers.join(', '));
    _cityController = TextEditingController(text: widget.profile.city);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _favoriteLeaguesController.dispose();
    _favoriteTeamsController.dispose();
    _favoritePlayersController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Text('Do you want to save the changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Save'),
              ),
            ],
          );
        },
      );

      if (shouldSave ?? false) {
        final updatedProfile = MyProfile(
          id: widget.profile.id,
          nickname: _nicknameController.text,
          favoriteLeagues: _favoriteLeaguesController.text.split(',').map((e) => e.trim()).toList(),
          favoriteTeams: _favoriteTeamsController.text.split(',').map((e) => e.trim()).toList(),
          favoritePlayers: _favoritePlayersController.text.split(',').map((e) => e.trim()).toList(),
          city: _cityController.text,
          isKakaoLinked: widget.profile.isKakaoLinked,
        );

        final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
        await profileViewModel.updateProfile(
          nickname: updatedProfile.nickname,
          favoriteLeagues: updatedProfile.favoriteLeagues,
          favoriteTeams: updatedProfile.favoriteTeams,
          favoritePlayers: updatedProfile.favoritePlayers,
          city: updatedProfile.city,
          isKakaoLinked: updatedProfile.isKakaoLinked,
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Nickname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _favoriteLeaguesController,
                decoration: InputDecoration(labelText: 'Favorite Leagues'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter favorite leagues';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _favoriteTeamsController,
                decoration: InputDecoration(labelText: 'Favorite Teams'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter favorite teams';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _favoritePlayersController,
                decoration: InputDecoration(labelText: 'Favorite Players'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter favorite players';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}