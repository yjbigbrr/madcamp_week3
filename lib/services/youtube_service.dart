import 'dart:convert';
import 'package:http/http.dart' as http;

// 유튜브 API를 사용하여 비디오 데이터를 가져오는 서비스 클래스
class YouTubeService {
  static const String apiKey = 'AIzaSyDA6BfrBrGTAQFI-O2r7-2z1VoAEVv2SHo'; // 새 API 키로 업데이트

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
        'maxResults': '3', // 최대 2개의 결과를 가져옴
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
