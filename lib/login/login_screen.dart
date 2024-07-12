import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakaoUser;
import 'package:provider/provider.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart'; // Import ProfileViewModel
import 'package:soccer_app/main.dart'; // Import MyHomePage
import 'register_screen.dart'; // Import RegisterScreen
import 'package:soccer_app/server/service/user_service.dart'; // Import UserService
import 'kakao_login.dart'; // Import KakaoLogin
import 'package:soccer_app/server/model/User.dart'; // Import User class
import 'package:soccer_app/drawer/profile/profile_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService(); // UserService 인스턴스 생성
  final KakaoLogin _kakaoLogin = KakaoLogin();

  void _login() async {
    final id = _idController.text;
    final password = _passwordController.text;

    try {
      // 로그인 함수 호출 및 User 객체 반환
      final user = await _userService.login(id, password);

      // User 객체가 null인 경우를 대비한 체크
      if (user == null) {
        throw Exception('User not found.');
      }

      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);

      // User 객체를 MyProfile 객체로 변환하여 저장
      final profile = MyProfile(
        nickname: user.nickname,
        id: user.id,
        favoriteLeagues: user.favoriteLeagues,
        favoriteTeams: user.favoriteTeams,
        favoritePlayers: user.favoritePlayers,
        city: user.city ?? '',
        isKakaoLinked: user.kakaoId != null,
      );

      await profileViewModel.saveProfile(profile); // Save User as Profile

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _loginWithKakao() async {
    bool loginSuccess = await _kakaoLogin.login();
    if (loginSuccess) {
      kakaoUser.User user = await kakaoUser.UserApi.instance.me();
      String kakaoId = user.id.toString() ?? '';
      String nickname = user.kakaoAccount?.profile?.nickname ?? '';
      String email = user.kakaoAccount?.email ?? '';

      bool userExists = await _userService.isUserExists(kakaoId);
      if (userExists) {
        final existingUser = await _userService.getUserByKakaoId(kakaoId);
        if (existingUser != null) {
          final profile = MyProfile(
            nickname: existingUser.nickname,
            id: existingUser.id,
            favoriteLeagues: existingUser.favoriteLeagues,
            favoriteTeams: existingUser.favoriteTeams,
            favoritePlayers: existingUser.favoritePlayers,
            city: existingUser.city ?? '',
            isKakaoLinked: existingUser.kakaoId != null,
          );

          final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
          await profileViewModel.saveProfile(profile); // Save existing User as Profile

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
              prefilledNickname: nickname,
              prefilledEmail: email,
              kakaoId: kakaoId,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kakao login failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _loginWithKakao,
              child: Image.asset(
                'assets/images/kakao_login_medium_narrow.png',
                height: 50, // 원하는 높이로 설정
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}