import 'package:flutter/material.dart';
import 'package:soccer_app/server/service/user_service.dart'; // UserService 임포트
import 'package:soccer_app/server/model/User.dart';

class RegisterScreen extends StatefulWidget {
  final String? prefilledNickname;
  final String? prefilledEmail;
  final String? kakaoId;

  RegisterScreen({this.prefilledNickname, this.prefilledEmail, this.kakaoId});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _favoriteLeaguesController = TextEditingController();
  final TextEditingController _favoriteTeamsController = TextEditingController();
  final TextEditingController _favoritePlayersController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final UserService _userService = UserService(); // UserService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    if (widget.prefilledNickname != null) {
      _nicknameController.text = widget.prefilledNickname!;
    }
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
  }

  void _register() async {
    final id = _idController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final nickname = _nicknameController.text;
    final favoriteLeagues = _favoriteLeaguesController.text.split(',').map((s) => s.trim()).toList();
    final favoriteTeams = _favoriteTeamsController.text.split(',').map((s) => s.trim()).toList();
    final favoritePlayers = _favoritePlayersController.text.split(',').map((s) => s.trim()).toList();
    final city = _cityController.text;
    final email = _emailController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    User newUser = User(
      id: id,
      password: password,
      nickname: nickname,
      favoriteLeagues: favoriteLeagues,
      favoriteTeams: favoriteTeams,
      favoritePlayers: favoritePlayers,
      city: city,
      email: email,
      kakaoId: widget.kakaoId
    );

    bool isCreated = await _userService.createUser(newUser);

    if (isCreated) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully'),
      ));
      Navigator.pop(context); // 회원가입 완료 후 로그인 화면으로 돌아감
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error registering user'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: 'ID'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(labelText: 'Nickname'),
              ),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: _favoriteLeaguesController,
                decoration: InputDecoration(labelText: 'Favorite Leagues (comma separated)'),
              ),
              TextField(
                controller: _favoriteTeamsController,
                decoration: InputDecoration(labelText: 'Favorite Teams (comma separated)'),
              ),
              TextField(
                controller: _favoritePlayersController,
                decoration: InputDecoration(labelText: 'Favorite Players (comma separated)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
