import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const String apiKey = 'AIzaSyCwRDmP9LNqPPAS8dgkCWpko105FTwS6Ac';

  static Future<String?> fetchVideoId(String query) async {
    final Uri url = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      {
        'part': 'snippet',
        'q': query,
        'key': apiKey,
        'type': 'video',
        'maxResults': '1',
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        final videoId = data['items'][0]['id']['videoId'];
        return videoId;
      } else {
        print('No videos found for the query.');
        return null;
      }
    } else {
      print('Failed to fetch video ID: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }
}
