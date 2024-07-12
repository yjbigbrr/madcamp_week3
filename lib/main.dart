import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:soccer_app/kakao_login.dart';
import 'package:soccer_app/main_view_model.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '6cf381adbd9cf31b14c1db80c010a446');  // 실제 네이티브 앱 키로 대체하세요.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (viewModel.user?.kakaoAccount?.profile?.profileImageUrl != null &&
                viewModel.user!.kakaoAccount!.profile!.profileImageUrl!.isNotEmpty)
              Image.network(viewModel.user!.kakaoAccount!.profile!.profileImageUrl!)
            else
              Icon(Icons.account_circle, size: 100), // Placeholder icon for no image
            Text(
              'Logged In: ${viewModel.isLogined}',
              style: Theme.of(context).textTheme.headlineMedium,  // Updated to headlineMedium
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.login();
                setState(() {});
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                await viewModel.logout();
                setState(() {});
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
// import 'package:soccer_app/kakao_login.dart';
// import 'package:soccer_app/main_view_model.dart';

// void main() {
//   KakaoSdk.init(nativeAppKey: '6cf381adbd9cf31b14c1db80c010a446');
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   final viewModel =MainViewModel(KakaoLogin);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final viewModel = MainViewModel(KakaoLogin());
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
            
//              Image.network(viewModel.user?.kakaoAccount?.profile?.profileImageUrl ?? ''),
//             Text(
//               '${viewModel.isLogined}',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//               ElevatedButton(onPressed: onPressed: () async {await viewModel.login(); setState(( ){});}, child: const Text('Login')),
//               ElevatedButton(onPressed: onPressed: () async {await viewModel.logout(); setState((){});}, child: const Text('Logout')),
              
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
