import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class NewsService {
  final String clientId = 'cKil9__Y2czQPHieSeCJ';
  final String clientSecret = '2NOuehbmut';

  // 뉴스 검색
  Future<List<dynamic>> fetchNews(String query) async {
    final response = await http.get(
      Uri.parse('https://openapi.naver.com/v1/search/news.json?query=$query'),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'];

      // 필터링 로직 추가: ' 또는 " 가 존재하는 기사는 제외
      final filteredItems = items.where((item) {
        String title = item['title'];
        return !title.contains("'") && !title.contains('"');
      }).toList();

      return filteredItems;
    } else {
      print('Failed to load news: ${response.statusCode}');
      throw Exception('Failed to load news');
    }
  }

  // 이미지 검색
  Future<String> fetchImage(String query) async {
    await Future.delayed(Duration(milliseconds: 500));

    final response = await http.get(
      Uri.parse('https://openapi.naver.com/v1/search/image.json?query=$query'),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        return data['items'][0]['thumbnail'];
      } else {
        return 'assets/images/placeholder.jpg';
      }
    } else {
      print('Failed to load image: ${response.statusCode}');
      throw Exception('Failed to load image');
    }
  }

  // 기사 제목에서 특수 문자를 제거하고 HTML 엔티티를 디코딩하는 함수
  String cleanTitle(String title) {
    final unescape = HtmlUnescape();
    String cleaned = unescape.convert(title) // HTML 엔티티 디코딩
        .replaceAll(RegExp(r'[^\s가-힣]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim().isEmpty ? '뉴스' : cleaned.trim(); // 제목이 비어있는 경우 기본값 설정
  }
}
