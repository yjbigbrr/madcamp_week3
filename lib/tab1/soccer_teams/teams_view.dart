import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'team.dart';
import 'teams_view_model.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart'; // TapGestureRecognizer를 사용하기 위해 추가

class TeamsView extends StatelessWidget {
  final TeamsViewModel viewModel;
  final String title;
  final String iconPath;

  TeamsView({required this.viewModel, required this.title, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildIcon(iconPath, 24, 24),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.teams.length,
            itemBuilder: (context, index) {
              return _buildTeamCard(context, viewModel.teams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(String imagePath, double width, double height) {
    if (imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        width: width,
        height: height,
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
      );
    }
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeamDetailPage(team: team)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            _buildImage(team.imagePath),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: 150,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 150,
      );
    }
  }
}

class TeamDetailPage extends StatefulWidget {
  final Team team;

  TeamDetailPage({required this.team});

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  int _selectedIndex = 0;
  String _clubInfo = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadClubInfo();
  }

  void _loadClubInfo() async {
    String info = await widget.team.getClubInfo();
    setState(() {
      _clubInfo = info;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: _buildImage(widget.team.imagePath),
          ),
          ToggleButtons(
            isSelected: [
              _selectedIndex == 0,
              _selectedIndex == 1,
              _selectedIndex == 2
            ],
            onPressed: (int index) {
              _onItemTapped(index);
            },
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('스타팅 11'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('선수 통계'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('클럽 정보'),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: _buildContent(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.endsWith('.svg')) {
      return SvgPicture.asset(
        imagePath,
        fit: BoxFit.contain,
        height: 200, // 적절한 높이 설정
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        height: 200, // 적절한 높이 설정
      );
    }
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildScrollableImage(widget.team.starting11ImagePath), // 스크롤 가능한 이미지를 반환
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildScrollableImage(widget.team.playerStatsImagePath), // 스크롤 가능한 이미지를 반환
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _buildFormattedText(_clubInfo),
          ),
        );
      default:
        return Container(); // 기본적으로 빈 컨테이너를 반환
    }
  }

  Widget _buildScrollableImage(String imagePath) {
    // 이미지가 화면 너비에 맞게 확대되고 스크롤 가능하도록 설정하는 위젯
    return Container(
      width: MediaQuery.of(context).size.width, // 화면 너비에 맞춤
      child: InteractiveViewer(
        panEnabled: true, // 스크롤 가능하게 설정
        scaleEnabled: true, // 확대 가능하게 설정
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical, // 수평 스크롤 설정
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover, // 이미지를 확대하여 화면 너비에 맞춤
          ), // 이미지를 확대하여 화면 너비에 맞춤
        ),
      ),
    );
  }


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildFormattedText(String text) {
    List<TextSpan> spans = [];
    text.split('\n').forEach((line) {
      if (line.startsWith('###')) {
        spans.add(TextSpan(
          text: line.replaceFirst('### ', '') + '\n',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontStyle: FontStyle.italic,
              fontWeight:FontWeight.w900,
            decoration: TextDecoration.combine([
            TextDecoration.underline, // 밑줄
            TextDecoration.overline, // 윗줄
          ])),
        ));
      } else if (line.startsWith('##')) {
        spans.add(TextSpan(
          text: line.replaceFirst('## ', '') + '\n',
          style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w800),
        ));
      } else if (line.contains('www.')) {
        // 텍스트 줄을 공백으로 분리하여 두 번째 부분이 있는지 확인
        List<String> parts = line.split(' ');
        if (parts.length > 1) {
          String url = parts.last.startsWith('http') ? parts.last : 'https://' + parts.last;
          spans.add(
            TextSpan(
              text: line + '\n',
              style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURL(url);
                },
            ),
          );
        } else {
          // 두 번째 부분이 없는 경우 기본 텍스트 스타일로 추가
          spans.add(TextSpan(
            text: line + '\n',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ));
        }
      } else {
        spans.add(TextSpan(
          text: line + '\n',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ));
      }
    });

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 16), // 기본 스타일 설정
        children: spans,
      ),
    );
  }
}