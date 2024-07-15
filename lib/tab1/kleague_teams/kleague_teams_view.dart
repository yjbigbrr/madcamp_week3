import 'package:flutter/material.dart';
import 'kleague_team.dart';
import 'kleague_teams_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';


class KleagueTeamsView extends StatelessWidget {
  final KleagueTeamsViewModel viewModel = KleagueTeamsViewModel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/kleague/kleague.png',
                width: 24, // 글자 크기와 동일하게 설정
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                'K리그',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.kleagueTeams.length,
            itemBuilder: (context, index) {
              return _buildKleagueTeamCard(context, viewModel.kleagueTeams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKleagueTeamCard(BuildContext context, KleagueTeam team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KleagueTeamDetailPage(team: team)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
        Expanded(
        child: Container(
        padding: EdgeInsets.all(8.0),
        child:
            SvgPicture.asset(
              team.imagePath,
              fit: BoxFit.contain, // BoxFit.cover -> BoxFit.contain으로 변경
              width: double.infinity,
              height: 150,
            ),
      ),
        ),
          ],
        ),
      ),
    );
  }
}

class KleagueTeamDetailPage extends StatelessWidget {
  final KleagueTeam team;

  KleagueTeamDetailPage({required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Center(
        child: SvgPicture.asset(
            team.imagePath,
          fit: BoxFit.contain, // BoxFit.cover -> BoxFit.contain으로 변경
        ),
      ),
    );
  }
}
