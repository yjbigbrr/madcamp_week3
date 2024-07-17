import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:soccer_app/services/youtube_service.dart';

// HighlightSection 위젯: 축구 하이라이트 영상을 보여주는 섹션
class HighlightSection extends StatefulWidget {
  @override
  _HighlightSectionState createState() => _HighlightSectionState();
}

class _HighlightSectionState extends State<HighlightSection> {
  late Future<List<Map<String, String>>> _highlightVideos;

  @override
  void initState() {
    super.initState();
    _highlightVideos = YouTubeService.fetchVideos(); // 비디오 데이터를 가져옴
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
                    width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%
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
  final String videoID;
  final String videoTitle;

  Player(this.videoID, this.videoTitle);

  @override
  PlayerState createState() => PlayerState(videoID, videoTitle);
}

class PlayerState extends State<Player> {
  final String videoID;
  final String videoTitle;
  late YoutubePlayerController _controller;

  PlayerState(this.videoID, this.videoTitle);

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: videoID,
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
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          videoTitle, // 비디오 제목 표시
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
