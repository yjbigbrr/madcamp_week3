import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              Text(
                '축구도 보고 술도 마시고',
                style: TextStyle(
                  fontFamily: 'CuteFont', // 추가한 글꼴 사용
                  fontSize: 24,
                ),
              ),
              SizedBox(width: 8),
              Text('🍺'), // 맥주 이모티콘 추가
            ],
          ),
        ),
        body: KakaoMapView(),
      ),
    );
  }
}

class KakaoMapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'https://map.kakao.com/',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}