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
  final List<String> overseasPlaceholders = [
    'assets/images/placeholder/overseasplaceholder1.jpg',
    'assets/images/placeholder/overseasplaceholder2.jpg',
    'assets/images/placeholder/overseasplaceholder3.jpg'
  ];
  final List<String> localPlaceholders = [
    'assets/images/placeholder/localplaceholder1.jpg',
    'assets/images/placeholder/localplaceholder2.jpg',
    'assets/images/placeholder/localplaceholder3.jpg'
  ];

  int overseasPlaceholderIndex = 0;
  int localPlaceholderIndex = 0;

  @override
  void initState() {
    super.initState();
    overseasNews = fetchNewsWithImages('유로 우승', 'overseas');
    localNews = fetchNewsWithImages('국가대표 축구대표팀', 'local');
  }

  Future<List<dynamic>> fetchNewsWithImages(String query, String type) async {
    NewsService newsService = NewsService();
    List<dynamic> newsArticles;

    try {
      newsArticles = await newsService.fetchNews(query);

      for (var article in newsArticles) {
        String title = article['title'];
        print('Original title: $title');
        String cleanTitle = newsService.cleanTitle(title);
        print('Cleaned title: $cleanTitle');
        article['thumbnail'] = await newsService.fetchImage(cleanTitle) ?? _getSequentialPlaceholder(type);
      }
    } catch (e) {
      print('Error fetching news with images: $e');
      throw Exception('Failed to load news');
    }

    return newsArticles;
  }

  String _getSequentialPlaceholder(String type) {
    if (type == 'overseas') {
      String placeholder = overseasPlaceholders[overseasPlaceholderIndex];
      overseasPlaceholderIndex = (overseasPlaceholderIndex + 1) % overseasPlaceholders.length;
      return placeholder;
    } else {
      String placeholder = localPlaceholders[localPlaceholderIndex];
      localPlaceholderIndex = (localPlaceholderIndex + 1) % localPlaceholders.length;
      return placeholder;
    }
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
                final overseasArticles = snapshot.data![0].take(3).toList();
                final localArticles = snapshot.data![1].take(3).toList();
                return Column(
                  children: [
                    _buildNewsRow(overseasArticles, 'overseas'),
                    _buildNewsRow(localArticles, 'local'),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsRow(List<dynamic> articles, String type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: articles.map((article) => _buildNewsItem(article, type)).toList(),
    );
  }

  Widget _buildNewsItem(dynamic article, String type) {
    final String rawTitle = article['title']?.replaceAll('<b>', '')?.replaceAll('</b>', '') ?? 'No Title';
    final String title = rawTitle.replaceAll('&quot;', '"');
    final String thumbnail = article['thumbnail'] ?? _getSequentialPlaceholder(type);
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
        width: MediaQuery.of(context).size.width / 3.3,
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
                  _getSequentialPlaceholder(type),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 100,
                );
              },
            ),
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
                '날짜: $pubDate',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
