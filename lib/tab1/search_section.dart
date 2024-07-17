import 'package:flutter/material.dart';
import 'package:soccer_app/services/naver_search_service.dart';
import 'package:soccer_app/tab1/soccer_teams/soccer_teams_page.dart';
import 'package:soccer_app/tab1/soccer_teams/team.dart';

import 'package:soccer_app/tab1/soccer_teams/teams_view.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_view_model.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_data/national_teams_data.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_data/kleague_teams_data.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_data/premierleague_teams_data.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_data/laliga_teams_data.dart';
import 'package:soccer_app/tab1/soccer_teams/teams_data/bundesliga_teams_data.dart';
import 'package:url_launcher/url_launcher.dart';


class SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        focusNode: FocusNode(canRequestFocus: false),
        readOnly: true,
        decoration: InputDecoration(
          hintText: '당신의 최애 축구선수, 축구팀은?',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  //검색 결과 페이지로 이동
  void _navigateToSearchResult(BuildContext context, String query) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultPage(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메시는 신이야'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '손흥민 렛츠고',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _navigateToSearchResult(context, _controller.text);
                  },
                ),
              ),
              onSubmitted: (query) {
                _navigateToSearchResult(context, query);
              },
            ),
    //섹션3, 섹션4 연결성
    SizedBox(height: 20), // 구분을 위한 여백
    Text('당신의 꿈의 리그는?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 10),
    Container(
    height: 100,
    child: ListView(
    scrollDirection: Axis.horizontal,
    children: <Widget>[
    _buildLeagueIcon(context, 'K리그', 'assets/images/kleague/kleague.png', kleagueTeams),
    _buildLeagueIcon(context, '프리미어리그', 'assets/images/premierleague/epl.png', premierLeagueTeams),
    _buildLeagueIcon(context, '라리가', 'assets/images/laliga/laliga.png', laLigaTeams),
    _buildLeagueIcon(context, '분데스리가', 'assets/images/bundeseliga/bundeseliga.png', bundesligaTeams),
    _buildLeagueIcon(context, '국가대표팀', 'assets/images/national/wcup.png', nationalTeams),
          ],
        ),
      ),
    ],
    ),
      ),
    );

}
  Widget _buildLeagueIcon(BuildContext context, String title, String imagePath, List<Team> teams) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamsView(
              viewModel: TeamsViewModel(teams: teams),
              title: title,
              iconPath: imagePath,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 50,
              height: 50,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// 검색 결과 표시
class SearchResultPage extends StatefulWidget {
  final String query;

  SearchResultPage({required this.query});

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late Future<List<dynamic>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = NaverSearchService().search(widget.query);
  }

//검색 결과 리스트
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('검색 결과를 불러오지 못했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('검색 결과가 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Text(item['title'].replaceAll('<b>', '').replaceAll(
                      '</b>', '')),
                  subtitle: Text(
                      item['description'].replaceAll('<b>', '').replaceAll(
                          '</b>', '')),
                  onTap: () {
                    // 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchResultDetailPage(
                              title: item['title']
                                  .replaceAll('<b>', '')
                                  .replaceAll('</b>', ''),
                              description: item['description'].replaceAll(
                                  '<b>', '').replaceAll('</b>', ''),
                              link: item['link'], // 링크 추가
                              thumbnail: item['thumbnail'] ?? '', // 썸네일 추가
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
//검색결과 상세페이지
class SearchResultDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String link; // 링크 추가
  final String thumbnail; // 썸네일 추가

  SearchResultDetailPage({required this.title, required this.description, required this.link,
    required this.thumbnail,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (thumbnail.isNotEmpty)
              Image.network(thumbnail),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '더보기:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () async {
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  throw 'Could not launch $link';
                }
              },
              child: Text(
                link,
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
