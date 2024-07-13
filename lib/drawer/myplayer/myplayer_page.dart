import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:provider/provider.dart';
import 'myplayer_view_model.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';

class MyPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Player'),
      ),
      body: Consumer<MyPlayerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.myPlayer == null) {
            debugPrint("my player is null!!!!!!!!!!!!!!!!!!!!!");
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyPlayerCreationPage(),
                    ),
                  );
                },
                child: Text('Create My Player'),
              ),
            );
          }

          return MyPlayerDetailView(myPlayer: viewModel.myPlayer!);
        },
      ),
    );
  }
}

class MyPlayerCreationPage extends StatefulWidget {
  @override
  _MyPlayerCreationPageState createState() => _MyPlayerCreationPageState();
}

class _MyPlayerCreationPageState extends State<MyPlayerCreationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  String _selectedPosition = '공격수';
  String _selectedPreferredFoot = '오른발';
  Map<String, int> _attributes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _initializeAttributes();
  }

  void _initializeAttributes() {
    final attributes = _selectedPosition == '골키퍼'
        ? ['reflexes', 'aeriel', 'handling', 'communication', 'commandOfArea', 'goalKicks', 'throwing']
        : ['dribbling', 'shooting', 'passing', 'firstTouch', 'crossing', 'offTheBall', 'tackling', 'marking', 'defensivePositioning', 'concentration', 'vision'];

    for (var attribute in attributes) {
      _attributes[attribute] = 60; // 기본값으로 60 설정
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Player name is required')));
      return;
    }

    final myPlayerData = MyPlayer(
      id: '', // 서버에서 생성된 ID를 사용
      name: _nameController.text,
      position: _selectedPosition,
      preferredFoot: _selectedPreferredFoot,
      overAll: 100, // 기본값
      strength: _attributes['strength'] ?? 0,
      pace: _attributes['pace'] ?? 0,
      stamina: _attributes['stamina'] ?? 0,
      agility: _attributes['agility'] ?? 0,
      jumping: _attributes['jumping'] ?? 0,
      injuryProneness: _attributes['injuryProneness'] ?? 0,
      dribbling: _attributes['dribbling'],
      shooting: _attributes['shooting'],
      passing: _attributes['passing'],
      firstTouch: _attributes['firstTouch'],
      crossing: _attributes['crossing'],
      offTheBall: _attributes['offTheBall'],
      tackling: _attributes['tackling'],
      marking: _attributes['marking'],
      defensivePositioning: _attributes['defensivePositioning'],
      concentration: _attributes['concentration'],
      reflexes: _attributes['reflexes'],
      handling: _attributes['handling'],
      communication: _attributes['communication'],
      commandOfArea: _attributes['commandOfArea'],
      goalKicks: _attributes['goalKicks'],
      throwing: _attributes['throwing'],
      vision: _attributes['vision'],
    );

    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final profile = profileViewModel.profile;

    Provider.of<MyPlayerViewModel>(context, listen: false).createMyPlayer(profile?.id, myPlayerData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create My Player'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Info'),
            Tab(text: 'Attributes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildAttributesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Player Name'),
          ),
          DropdownButton<String>(
            value: _selectedPosition,
            onChanged: (value) {
              setState(() {
                _selectedPosition = value!;
                _initializeAttributes(); // 새 포지션에 맞게 능력치 기본값 재설정
              });
            },
            items: ['공격수', '미드필더', '수비수', '골키퍼']
                .map((position) => DropdownMenuItem(
              value: position,
              child: Text(position),
            ))
                .toList(),
          ),
          DropdownButton<String>(
            value: _selectedPreferredFoot,
            onChanged: (value) {
              setState(() {
                _selectedPreferredFoot = value!;
              });
            },
            items: ['왼발', '오른발']
                .map((foot) => DropdownMenuItem(
              value: foot,
              child: Text(foot),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesTab() {
    final attributes = _selectedPosition == '골키퍼'
        ? ['reflexes', 'aeriel', 'handling', 'communication', 'commandOfArea', 'goalKicks', 'throwing']
        : ['dribbling', 'shooting', 'passing', 'firstTouch', 'crossing', 'offTheBall', 'tackling', 'marking', 'defensivePositioning', 'concentration', 'vision'];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: attributes.length,
      itemBuilder: (context, index) {
        final attribute = attributes[index];
        return TextField(
          controller: TextEditingController(text: _attributes[attribute]?.toString() ?? '60'), // 기본값 60 표시
          decoration: InputDecoration(labelText: attribute),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _attributes[attribute] = int.tryParse(value) ?? 60; // 입력값을 60으로 초기화
            });
          },
        );
      },
    );
  }
}

class MyPlayerDetailView extends StatelessWidget {
  final MyPlayer myPlayer;

  MyPlayerDetailView({required this.myPlayer});

  @override
  Widget build(BuildContext context) {
    final data = myPlayer.position == '골키퍼'
        ? {
      '공배급': myPlayer.goalKicks! * 0.6 + myPlayer.throwing! * 0.3 + myPlayer.communication! * 0.1,
      '수비조율': myPlayer.commandOfArea! * 0.2 + myPlayer.agility! * 0.2 + myPlayer.communication! * 0.5 + myPlayer.handling! * 0.1,
      '공중볼': myPlayer.commandOfArea! * 0.1 + myPlayer.aeriel! * 0.6 + myPlayer.jumping! * 0.3,
      '피지컬': myPlayer.pace * 0.3 + myPlayer.strength * 0.3 + myPlayer.jumping * 0.1 + myPlayer.agility * 0.1 + myPlayer.stamina * 0.2,
      '선방': myPlayer.reflexes! * 0.5 + myPlayer.agility! * 0.3 + myPlayer.handling! * 0.2,
    }
        : {
      '개인기': myPlayer.dribbling! * 0.4 + myPlayer.firstTouch! * 0.3 + myPlayer.agility! * 0.3,
      '슛': myPlayer.strength * 0.3 + myPlayer.shooting! * 0.5 + myPlayer.firstTouch! * 0.2,
      '패스': myPlayer.passing! * 0.4 + myPlayer.vision! * 0.3 + myPlayer.crossing! * 0.2 + myPlayer.firstTouch! * 0.1,
      '수비': myPlayer.tackling! * 0.4 + myPlayer.marking! * 0.2 + myPlayer.defensivePositioning! * 0.2 + myPlayer.concentration! * 0.2,
      '움직임': myPlayer.pace * 0.3 + myPlayer.agility! * 0.2 + (myPlayer.position == '공격수'
          ? myPlayer.offTheBall! * 0.5
          : myPlayer.position == '수비수'
          ? myPlayer.defensivePositioning! * 0.3 + myPlayer.marking! * 0.2
          : myPlayer.offTheBall! * 0.2 + myPlayer.defensivePositioning! * 0.2 + myPlayer.marking! * 0.1),
      '피지컬': myPlayer.pace * 0.3 + myPlayer.strength * 0.3 + myPlayer.jumping * 0.1 + myPlayer.agility * 0.1 + myPlayer.stamina * 0.2,
    };

    final features = data.keys.toList();
    final dataSet = [data.values.toList().map((value) => value.toDouble()).toList()];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 축구공 아이콘과 스타일링된 텍스트
            Row(
              children: [
                Image.asset(
                  'assets/images/football.png', // 축구공 아이콘 파일 경로
                  width: 40,
                  height: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Name: ${myPlayer.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Position: ${myPlayer.position}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Preferred Foot: ${myPlayer.preferredFoot}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300, // RadarChart의 높이를 지정
                child: RadarChart(
                  ticks: [30, 60, 90, 120, 150],
                  features: features,
                  data: dataSet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


