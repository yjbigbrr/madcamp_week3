import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const String apiKey = 'AIzaSyDbSymv-c1W9vxvcZOxh4nldK7xtoSDbGg';

  static Future<List<Map<String, String>>> fetchVideos(String query) async {
    final Uri url = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'snippet',
        'q': query,
        'key': apiKey,
        'type': 'video',
        'maxResults': '2',
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> videos = [];
      if (data['items'].isNotEmpty) {
        for (var item in data['items']) {
          videos.add({
            'videoId': item['id']['videoId'],
            'thumbnail': item['snippet']['thumbnails']['high']['url'],
          });
        }
        return videos;
      } else {
        print('No videos found for the query.');
        return [];
      }
    } else {
      print('Failed to fetch video ID: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }
}
