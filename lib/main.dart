import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // 추가
import 'package:soccer_app/drawer/friend/friend_page.dart';
import 'package:soccer_app/drawer/meeting/meeting_page.dart';
import 'package:soccer_app/drawer/myplayer/myplayer_view_model.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';
import 'package:soccer_app/main_view_model.dart';
import 'package:soccer_app/login/login_screen.dart';
import 'package:soccer_app/drawer/profile/profile_page.dart';
import 'package:soccer_app/drawer/myplayer/myplayer_page.dart';
import 'package:soccer_app/schedule/schedule_page.dart';
import 'package:soccer_app/schedule/schedule_view_model.dart';
import 'package:soccer_app/server/service/match_service.dart';
import 'package:soccer_app/server/service/meetings_service.dart';
import 'package:soccer_app/tab1/home_screen.dart';
import 'package:soccer_app/tab3/tab3_kakao_map.dart';

import 'drawer/meeting/meeting_view_model.dart'; // 추가

void main() {
  KakaoSdk.init(nativeAppKey: '6cf381adbd9cf31b14c1db80c010a446');  // 실제 네이티브 앱 키로 대체하세요.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(),
        ),
        ChangeNotifierProxyProvider<ProfileViewModel, ScheduleViewModel>(
          create: (context) => ScheduleViewModel(MatchService(), ""),
          update: (context, profileViewModel, scheduleViewModel) {
            if (profileViewModel.profile != null) {
              return ScheduleViewModel(MatchService(), profileViewModel.profile!.id);
            }
            return ScheduleViewModel(MatchService(), "");
          },
        ),
        ChangeNotifierProvider(create: (context) => MeetingViewModel(MeetingService(), Provider.of<ProfileViewModel>(context, listen: false))),
        ChangeNotifierProxyProvider<ProfileViewModel, MyPlayerViewModel>(
          create: (context) => MyPlayerViewModel(
            profileViewModel: Provider.of<ProfileViewModel>(context, listen: false),
          ),
          update: (context, profileViewModel, myPlayerViewModel) {
            return MyPlayerViewModel(profileViewModel: profileViewModel);
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '레츠볼',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Colors.teal,
          primaryContainer: Colors.teal.shade700,
          secondary: Colors.blueGrey,
          secondaryContainer: Colors.blueGrey.shade700,
          surface: Colors.white,
          background: Colors.grey.shade200,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white, // 앱바의 텍스트 및 아이콘 색상
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white, // 선택된 탭의 텍스트 색상
          unselectedLabelColor: Colors.blueGrey, // 선택되지 않은 탭의 텍스트 색상
          indicator: BoxDecoration(
            color: Colors.blueGrey, // 선택된 탭의 배경 색상
          ),
        ),
        scaffoldBackgroundColor: Colors.grey.shade200, // 스캐폴드 배경 색상
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // 기본 본문 텍스트 색상
          bodyMedium: TextStyle(color: Colors.black), // 기본 본문 텍스트 색상
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.teal, // 버튼 배경 색상
          textTheme: ButtonTextTheme.primary, // 버튼 텍스트 색상
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playMusic();
    _navigateToHome();
  }

  Future<void> _playMusic() async {
    await _audioPlayer.play(AssetSource('audio/ch.mp3'));
  }

  void _navigateToHome() {
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/splash/menaldo.png', fit: BoxFit.cover),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 탭의 수를 설정합니다.
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레츠볼'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _tabController.index = index;
            });
          },
          tabs: const [
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.trending_up), text: '경기일정'),
            Tab(icon: Icon(Icons.person), text: '펍'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Consumer<ProfileViewModel>(
          builder: (context, profileViewModel, child) {
            if (profileViewModel.profile == null) {
              profileViewModel.loadProfile();
              return Center(child: CircularProgressIndicator());
            }

            final profile = profileViewModel.profile;
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(profile?.nickname ?? 'User Nickname'),
                  accountEmail: Text(profile?.id ?? 'User ID'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(profile?.nickname.substring(0, 1) ?? 'U'),
                  ),
                ),
                ListTile(
                  title: const Text('프로필'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('나만의 선수'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPlayerPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('친구'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendPage(userId: profile?.id ?? ''),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('내 예약'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MeetingPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Logout'),
                  onTap: () async {
                    await profileViewModel.clearProfile();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(), // 손가락 제스처로 탭 전환을 막음
        children: <Widget>[
          HomeScreen(), // 추가된 부분
          SchedulePage(),
          KakaoMapScreen(), // "펍" 탭에 KakaoMapScreen 추가
        ],
      ),
    );
  }
}