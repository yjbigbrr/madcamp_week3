/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ScheduleService {
  final String clientId = 'cKil9__Y2czQPHieSeCJ';
  final String clientSecret = '2NOuehbmut';

  Future<Map<String, String>> fetchSchedule(String date) async {
    final response = await http.get(
      Uri.parse('https://m.sports.naver.com/kfootball/schedule/index?date=$date'),
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body.substring(0, 1000)}'); // 첫 500자만 출력

    if (response.statusCode == 200) {
      var document = parse(response.body);

      // 경기 시간 파싱
      var matchTimes = document.querySelectorAll('ul > li > div > div > div > span.blind');
      print('Match times found: ${matchTimes.length}');
      var matchTime = matchTimes.isNotEmpty ? matchTimes.first.text : '';
      print('First match time: $matchTime');

      // 경기 팀 파싱
      var teamElements = document.querySelectorAll('ul > li > div > div > div > div > div > div > strong');
      print('Team elements found: ${teamElements.length}');
      var homeTeam = teamElements.isNotEmpty ? teamElements[0].text : '';
      var awayTeam = teamElements.length > 1 ? teamElements[1].text : '';
      print('First match teams: $homeTeam vs $awayTeam');

      // 시간 문자열 변환 (예: '19:00' 형태로 변환)
      var formattedTime = matchTime.replaceAll('.', ':');
      print('Formatted match time: $formattedTime');

      return {
        'matchTime': formattedTime,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
      };
    } else {
      print('Failed to load schedule: ${response.statusCode}');
      throw Exception('Failed to load schedule');
    }
  }
}
*/
