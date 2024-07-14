import 'package:flutter/material.dart';
import 'laliga_team.dart';
import 'laliga_teams_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LaLigaTeamsView extends StatelessWidget {
  final LaLigaTeamsViewModel viewModel = LaLigaTeamsViewModel();

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
                'assets/images/laliga/laliga.png',
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                '라리가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.laLigaTeams.length,
            itemBuilder: (context, index) {
              return _buildLaLigaTeamCard(context, viewModel.laLigaTeams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLaLigaTeamCard(BuildContext context, LaLigaTeam team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LaLigaTeamDetailPage(team: team)),
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

class LaLigaTeamDetailPage extends StatelessWidget {
  final LaLigaTeam team;

  LaLigaTeamDetailPage({required this.team});

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
