import 'package:flutter/material.dart';
import 'news_section.dart'; // 추가
import 'soccer_teams/soccer_teams_page.dart'; // 통합된 페이지 import
import 'search_section.dart'; // 추가
import 'highlight_section.dart';

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
            title: Text('하이라이트'),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  height: 200, // 높이를 설정하여 하나의 이미지가 크게 보이도록 설정
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      _buildPromotionCard(context, 'assets/images/spotvnow.png'),
                      _buildPromotionCard(context, 'assets/images/spotvnow1.jpg'),
                    ],
                  ),
                ),
                HighlightSection(),
                // SizedBox(height: 20), // 구분을 위한 여백
                Container(
                  height: 500, // 섹션 높이 설정
                  child: NewsSection(),
                ),
                // 뉴스 섹션 추가
                // SizedBox(height: 20), // 구분을 위한 여백
                SearchSection(), // 검색 섹션 추가
                // SizedBox(height: 20), // 구분을 위한 여백
                SoccerTeamsPage(), // 통합된 축구팀 페이지 추가
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PromotionDetailScreen(imagePath: imagePath)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width, // 화면 너비에 맞게 설정
        margin: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

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
        child: Image.asset(imagePath),
      ),
    );
  }
 }
