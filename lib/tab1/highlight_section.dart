import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:soccer_app/services/youtube_service.dart';

class HighlightSection extends StatefulWidget {
  @override
  _HighlightSectionState createState() => _HighlightSectionState();
}

class _HighlightSectionState extends State<HighlightSection> {
  List<Map<String, String>> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    final videos = await YouTubeService.fetchVideos('축구 하이라이트');
    setState(() {
      _videos = videos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _buildPromotionCard(context, video['thumbnail']!, video['videoId']!);
        },
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, String thumbnailUrl, String videoId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoDetailScreen(videoId: videoId)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final String videoId;

  VideoDetailScreen({required this.videoId});

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Highlight'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _youtubeController,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
