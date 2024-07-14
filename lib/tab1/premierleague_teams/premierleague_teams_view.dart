import 'package:flutter/material.dart';
import 'premierleague_team.dart';
import 'premierleague_teams_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PremierLeagueTeamsView extends StatelessWidget {
  final PremierLeagueTeamsViewModel viewModel = PremierLeagueTeamsViewModel();

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
                'assets/images/premierleague/epl.png',
                width: 24, // 글자 크기와 동일하게 설정
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                '프리미어리그',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.premierLeagueTeams.length,
            itemBuilder: (context, index) {
              return _buildPremierLeagueTeamCard(context, viewModel.premierLeagueTeams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremierLeagueTeamCard(BuildContext context, PremierLeagueTeam team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PremierLeagueTeamDetailPage(team: team)),
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
                child: SvgPicture.asset(
                  team.imagePath,
                  fit: BoxFit.contain,
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

class PremierLeagueTeamDetailPage extends StatelessWidget {
  final PremierLeagueTeam team;

  PremierLeagueTeamDetailPage({required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Center(
        child: SvgPicture.asset(
          team.imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
