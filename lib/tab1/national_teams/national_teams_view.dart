import 'package:flutter/material.dart';
import 'national_team.dart';
import 'national_teams_view_model.dart';

class NationalTeamsView extends StatelessWidget {
  final NationalTeamsViewModel viewModel = NationalTeamsViewModel();

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
                'assets/images/national/wcup.png',
                width: 24, // 글자 크기와 동일하게 설정
                height: 24,
              ),
              SizedBox(width: 8),
              Text(
                '국가대표팀',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.nationalTeams.length,
            itemBuilder: (context, index) {
              return _buildNationalTeamCard(context, viewModel.nationalTeams[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNationalTeamCard(BuildContext context, NationalTeam team) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NationalTeamDetailPage(team: team)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            Image.asset(
              team.imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),


          ],
        ),
      ),
    );
  }
}

class NationalTeamDetailPage extends StatelessWidget {
  final NationalTeam team;

  NationalTeamDetailPage({required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Center(
        child: Image.asset(team.imagePath),
      ),
    );
  }
}
