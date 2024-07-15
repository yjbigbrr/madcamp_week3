import 'dart:convert';
import 'package:http/http.dart' as http;

class NaverSearchService {
  final String clientId = 'cKil9__Y2czQPHieSeCJ';
  final String clientSecret = '2NOuehbmut';

  Future<List<dynamic>> search(String query) async {
    final response = await http.get(
      Uri.parse('https://openapi.naver.com/v1/search/encyc.json?query=$query'),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
