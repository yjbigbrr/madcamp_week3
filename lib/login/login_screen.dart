import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:soccer_app/login/register_screen.dart'; // 회원가입 페이지로의 네비게이션을 위해 필요한 임포트
import 'package:soccer_app/server/service/user_service.dart';
import 'package:soccer_app/main.dart';
import 'package:soccer_app/login/kakao_login.dart';

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
      final success = await _userService.login(id, password);
      if (success) {
        // 로그인 성공 시 Home 페이지로 네비게이션
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // 로그인 실패 시 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      // 예외 발생 시 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _loginWithKakao() async {
    bool loginSuccess = await _kakaoLogin.login();
    if (loginSuccess) {
      User user = await UserApi.instance.me();
      String kakaoId = user.id.toString();
      String nickname = user.kakaoAccount?.profile?.nickname ?? '';
      String email = user.kakaoAccount?.email ?? '';

      bool userExists = await _userService.isUserExists(kakaoId);
      if (userExists) {
        debugPrint("*******************user exists*******************");
        final user = await _userService.getUserByKakaoId(kakaoId);
        if (user != null) {
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