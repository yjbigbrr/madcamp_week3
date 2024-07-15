import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'team.dart';
import 'teams_view_model.dart';

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


class TeamDetailPage extends StatefulWidget {
  final Team team;

  TeamDetailPage({required this.team});

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('스타팅 11'),
    Text('선수 통계'),
    Text('클럽 정보'),
  ];

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
            isSelected: [_selectedIndex == 0, _selectedIndex == 1, _selectedIndex == 2],
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
              child: _widgetOptions.elementAt(_selectedIndex),
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
}
