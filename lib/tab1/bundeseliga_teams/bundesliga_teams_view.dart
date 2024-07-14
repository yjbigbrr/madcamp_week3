import 'package:flutter/material.dart';
import 'bundesliga_team.dart';
import 'bundesliga_teams_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BundesligaTeamsView extends StatelessWidget {
  final BundesligaTeamsViewModel viewModel = BundesligaTeamsViewModel();

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
                'assets/images/bundeseliga/bundeseliga.png',
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                '분데스리가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.bundesligaTeams.length,
            itemBuilder: (context, index) {
              return _buildBundesligaTeamCard(context, viewModel.bundesligaTeams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBundesligaTeamCard(BuildContext context, BundesligaTeam team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BundesligaTeamDetailPage(team: team)),
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

class BundesligaTeamDetailPage extends StatelessWidget {
  final BundesligaTeam team;

  BundesligaTeamDetailPage({required this.team});

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
