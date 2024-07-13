import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/drawer/myplayer/myplayer_view_model.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';
import 'package:soccer_app/main_view_model.dart';
import 'package:soccer_app/login/login_screen.dart';
import 'package:soccer_app/drawer/profile/profile_page.dart';
import 'package:soccer_app/drawer/myplayer/myplayer_page.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '6cf381adbd9cf31b14c1db80c010a446');  // 실제 네이티브 앱 키로 대체하세요.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(),
        ),
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

  Future<Widget> _getInitialPage(BuildContext context) async {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    await profileViewModel.loadProfile();

    if (profileViewModel.profile != null) {
      return MyHomePage(); // 홈 페이지로 이동
    } else {
      return LoginScreen(); // 로그인 페이지로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: 'Flutter Drawer and Tabs Example',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            title: 'Flutter Drawer and Tabs Example',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: snapshot.data,
          );
        }
      },
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
        title: Text('Flutter Drawer and Tabs Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: '홈'),
            Tab(icon: Icon(Icons.trending_up), text: '경기일정'),
            Tab(icon: Icon(Icons.person), text: '펍'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Consumer<ProfileViewModel>(
          builder: (context, profileViewModel, child) {
            // Ensure that the profile is loaded before building the drawer
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
                // Other Drawer items here
                ListTile(
                  title: Text('프로필'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('나만의 선수'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPlayerPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('친구'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPlayerPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('내 예약'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPlayerPage()),
                    );
                  },
                ),
                ListTile(
                  title: Text('Logout'),
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
        children: <Widget>[
          Center(child: Text('Home Page Content')),
          Center(child: Text('Ranking Page Content')),
          Center(child: Text('Profile Page Content')),
        ],
      ),
    );
  }
}