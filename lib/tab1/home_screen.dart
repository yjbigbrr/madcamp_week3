import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// 유튜브 API를 사용하여 비디오 데이터를 가져오는 서비스 클래스
class YouTubeService {
  static const String apiKey = 'AIzaSyD6fLY9QEIa8s99jgwQ2RUm7zpPR48icXs'; // 새 API 키로 업데이트

  // "축구 하이라이트"를 검색어로 사용하여 유튜브 비디오 데이터를 가져오는 메소드
  static Future<List<Map<String, String>>> fetchVideos() async {
    final Uri url = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'snippet',
        'q': '축구 하이라이트',
        'key': apiKey,
        'type': 'video',
        'maxResults': '2', // 최대 2개의 결과를 가져옴
      },
    );

    final response = await http.get(url);

    // 요청이 성공하면
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // 응답 본문을 JSON으로 디코딩
      List<Map<String, String>> videos = [];
      if (data['items'].isNotEmpty) {
        // 응답에서 비디오 데이터 추출
        for (var item in data['items']) {
          videos.add({
            'videoId': item['id']['videoId'], // 비디오 ID
            'title': item['snippet']['title'], // 비디오 제목
            'thumbnail': item['snippet']['thumbnails']['high']['url'], // 썸네일 URL
          });
        }
        return videos; // 비디오 리스트 반환
      } else {
        print('No videos found for the query.');
        return [];
      }
    } else {
      // 요청이 실패하면 오류 메시지 출력
      print('Failed to fetch video ID: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }
}

// 홈 스크린 위젯
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: false,
            title: Text('하이라이트'), // 앱바 타이틀
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                HighlightSection(), // 하이라이트 섹션 추가
                SizedBox(height: 20), // 구분을 위한 여백
                Container(
                  height: 500, // 섹션 높이 설정
                  child: NewsSection(), // 뉴스 섹션
                ),
                SizedBox(height: 20), // 구분을 위한 여백
                SearchSection(), // 검색 섹션
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 하이라이트 섹션 위젯
class HighlightSection extends StatefulWidget {
  @override
  _HighlightSectionState createState() => _HighlightSectionState();
}

class _HighlightSectionState extends State<HighlightSection> {
  late Future<List<Map<String, String>>> _highlightVideos;

  @override
  void initState() {
    super.initState();
    // "축구 하이라이트"라는 검색어로 유튜브 비디오 데이터를 가져옴
    _highlightVideos = YouTubeService.fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _highlightVideos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 로딩 중일 때 로딩 표시
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load highlights')); // 에러 발생 시 에러 메시지 표시
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No highlights found')); // 데이터가 없을 때 메시지 표시
        } else {
          // 데이터를 성공적으로 가져왔을 때
          return Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 가로 스크롤
              itemCount: snapshot.data!.length, // 비디오 수
              itemBuilder: (context, index) {
                final video = snapshot.data![index]; // 비디오 데이터
                return GestureDetector(
                  onTap: () {
                    // 썸네일 클릭 시 Player 위젯으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Player(
                          video['videoId']!,
                          video['title']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width, // 화면 너비에 맞게 설정
                    margin: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        video['thumbnail']!, // 썸네일 이미지
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

// 유튜브 비디오 재생을 위한 Player 위젯
class Player extends StatefulWidget {
  final String _videoID;
  final String _videoTitle;

  Player(this._videoID, this._videoTitle);

  @override
  PlayerState createState() => PlayerState(_videoID, _videoTitle);
}

class PlayerState extends State<Player> {
  String _videoID;
  String _videoTitle;

  PlayerState(this._videoID, this._videoTitle);

  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // 유튜브 플레이어 컨트롤러 초기화
    _controller = YoutubePlayerController(
      initialVideoId: _videoID,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true, // 자동 재생
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true, // 자막 활성화
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$_videoTitle', // 비디오 제목 표시
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: YoutubePlayer(
        key: ObjectKey(_controller),
        controller: _controller,
        actionsPadding: const EdgeInsets.only(left: 16.0),
        bottomActions: [
          CurrentPosition(), // 현재 재생 위치 표시
          const SizedBox(width: 10.0),
          ProgressBar(isExpanded: true), // 재생 바
          const SizedBox(width: 10.0),
          RemainingDuration(), // 남은 시간 표시
        ],
      ),
    );
  }
}

// 프로모션 상세 화면 위젯
class PromotionDetailScreen extends StatelessWidget {
  final String imagePath;

  const PromotionDetailScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Highlight'),
      ),
      body: Center(
        child: Image.asset(imagePath), // 프로모션 이미지 표시
      ),
    );
  }
}

// 더미 위젯들
class NewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('News Section'));
  }
}

class SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search Section'));
  }
}