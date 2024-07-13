import 'package:flutter/material.dart';
import 'package:soccer_app/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsSection extends StatefulWidget {
  @override
  _NewsSectionState createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  late Future<List<dynamic>> overseasNews;
  late Future<List<dynamic>> localNews;

  @override
  void initState() {
    super.initState();
    overseasNews = fetchNewsWithImages('유로 우승');
    localNews = fetchNewsWithImages('국가대표 축구대표팀');
  }

  Future<List<dynamic>> fetchNewsWithImages(String query) async {
    NewsService newsService = NewsService();
    List<dynamic> newsArticles;

    try {
      newsArticles = await newsService.fetchNews(query);

      for (var article in newsArticles) {
        String title = article['title'];
        print('Original title: $title'); // 로깅 추가
        String cleanTitle = newsService.cleanTitle(title); // 특수 문자 제거
        print('Cleaned title: $cleanTitle'); // 로깅 추가
        article['thumbnail'] = await newsService.fetchImage(cleanTitle);
      }
    } catch (e) {
      print('Error fetching news with images: $e');
      throw Exception('Failed to load news');
    }

    return newsArticles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('축구뉴스', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([overseasNews, localNews]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load news'));
              } else {
                final overseasArticles = snapshot.data![0].take(3).toList(); // 상위 3개 기사만 가져오기
                final localArticles = snapshot.data![1].take(3).toList(); // 상위 3개 기사만 가져오기
                return Column(
                  children: [
                    _buildNewsRow(overseasArticles),
                    _buildNewsRow(localArticles),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsRow(List<dynamic> articles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: articles.map((article) => _buildNewsItem(article)).toList(),
    );
  }

  Widget _buildNewsItem(dynamic article) {
    final String rawTitle = article['title']?.replaceAll('<b>', '')?.replaceAll('</b>', '') ?? 'No Title';
    final String title = rawTitle.replaceAll('&quot;', '"'); // &quot;를 실제 큰따옴표로 대체
    final String thumbnail = article['thumbnail'] ?? 'assets/images/placeholder.jpg';
    final String originallink = article['originallink'] ?? '';
    final String pubDate = article['pubDate'] ?? 'Unknown Date';

    return GestureDetector(
      onTap: () async {
        if (await canLaunch(originallink)) {
          await launch(originallink);
        } else {
          throw 'Could not launch $originallink';
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3.3, // 너비 조정
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              thumbnail,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 100,
                );
              },
            ), // 에러 발생 시 placeholder 사용
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '신문사: $pubDate',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
