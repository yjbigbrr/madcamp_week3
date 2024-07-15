import 'package:flutter/material.dart';
import 'teams_view.dart';
import 'teams_view_model.dart';
import 'teams_data/national_teams_data.dart';
import 'teams_data/kleague_teams_data.dart';
import 'teams_data/premierleague_teams_data.dart';
import 'teams_data/laliga_teams_data.dart';
import 'teams_data/bundesliga_teams_data.dart';

class SoccerTeamsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 250, // 고정된 높이 설정
          child: TeamsView(
            viewModel: TeamsViewModel(teams: nationalTeams),
            title: '국가대표팀',
            iconPath: 'assets/images/national/wcup.png',
          ),
        ),
        Container(
          height: 250, // 고정된 높이 설정
          child: TeamsView(
            viewModel: TeamsViewModel(teams: kleagueTeams),
            title: 'K리그',
            iconPath: 'assets/images/kleague/kleague.png',
          ),
        ),
        Container(
          height: 250, // 고정된 높이 설정
          child: TeamsView(
            viewModel: TeamsViewModel(teams: premierLeagueTeams),
            title: '프리미어리그',
            iconPath: 'assets/images/premierleague/epl.png',
          ),
        ),
        Container(
          height: 250, // 고정된 높이 설정
          child: TeamsView(
            viewModel: TeamsViewModel(teams: laLigaTeams),
            title: '라리가',
            iconPath: 'assets/images/laliga/laliga.png',
          ),
        ),
        Container(
          height: 250, // 고정된 높이 설정
          child: TeamsView(
            viewModel: TeamsViewModel(teams: bundesligaTeams),
            title: '분데스리가',
            iconPath: 'assets/images/bundeseliga/bundeseliga.png',
          ),
        ),
      ],
    );
  }
}
