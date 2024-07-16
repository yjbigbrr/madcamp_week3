import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:provider/provider.dart';
import 'myplayer_view_model.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';

// MyPlayerPage 클래스 정의, StatelessWidget을 상속
class MyPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바 정의
      appBar: AppBar(
        title: Text('My Player'),
      ),
      // Consumer를 사용하여 MyPlayerViewModel을 구독
      body: Consumer<MyPlayerViewModel>(
        builder: (context, viewModel, child) {
          // 데이터를 로딩 중일 때 로딩 인디케이터를 표시
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // 플레이어 ID가 없을 때 'Create My Player' 버튼 표시
          if (viewModel.myPlayerIds == null || viewModel.myPlayerIds!.isEmpty) {
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

          // Column을 ListView로 변경하여 overflow 문제를 해결
          return Column(
            children: [
              if (viewModel.myPlayerIds != null && viewModel.myPlayerIds!.isNotEmpty)
                DropdownButton<String>(
                  value: viewModel.myPlayerIds![0],
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.changePlayer(value);
                    }
                  },
                  items: viewModel.myPlayerIds!.map((id) {
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(id),
                    );
                  }).toList(),
                ),
              // Expanded를 사용하여 MyPlayerDetailView의 크기를 제한
              Expanded(
                child: viewModel.currentMyPlayer != null
                    ? MyPlayerDetailView(myPlayer: viewModel.currentMyPlayer!)
                    : Center(child: Text('No player data available')),
              ),
            ],
          );
        },
      ),
    );
  }
}

// MyPlayerCreationPage 클래스 정의, StatefulWidget을 상속
class MyPlayerCreationPage extends StatefulWidget {
  @override
  _MyPlayerCreationPageState createState() => _MyPlayerCreationPageState();
}

class _MyPlayerCreationPageState extends State<MyPlayerCreationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 컨트롤러
  late TextEditingController _nameController; // 플레이어 이름 입력 컨트롤러
  String _selectedPosition = '공격수'; // 선택된 포지션 초기값
  String _selectedPreferredFoot = '오른발'; // 선택된 선호 발 초기값
  Map<String, int> _attributes = {}; // 플레이어 능력치
  Map<String, int> _physicalAttributes = {}; // 플레이어 신체 능력치

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 탭 컨트롤러 초기화
    _nameController = TextEditingController(); // 이름 컨트롤러 초기화
    _initializeAttributes(); // 능력치 초기화
  }

  // 플레이어 능력치 초기화 함수
  void _initializeAttributes() {
    final attributes = _selectedPosition == '골키퍼'
        ? ['reflexes', 'aeriel', 'handling', 'communication', 'commandOfArea', 'goalKicks', 'throwing']
        : ['dribbling', 'shooting', 'passing', 'firstTouch', 'crossing', 'offTheBall', 'tackling', 'marking', 'defensivePositioning', 'concentration', 'vision'];

    for (var attribute in attributes) {
      _attributes[attribute] = 60; // 각 능력치 초기값 60 설정
    }

    _physicalAttributes = {
      'strength': 60,
      'pace': 60,
      'stamina': 60,
      'agility': 60,
      'jumping': 60,
      'injuryProneness': 60,
    };
  }

  @override
  void dispose() {
    _tabController.dispose(); // 탭 컨트롤러 해제
    _nameController.dispose(); // 이름 컨트롤러 해제
    super.dispose();
  }

  // 플레이어 생성 함수
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
      overAll: 100,
      strength: _physicalAttributes['strength'] ?? 0,
      pace: _physicalAttributes['pace'] ?? 0,
      stamina: _physicalAttributes['stamina'] ?? 0,
      agility: _physicalAttributes['agility'] ?? 0,
      jumping: _physicalAttributes['jumping'] ?? 0,
      injuryProneness: _physicalAttributes['injuryProneness'] ?? 0,
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
      aeriel: _attributes['aeriel'],
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
    Navigator.pop(context); // 플레이어 생성 후 이전 화면으로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create My Player'),
        bottom: TabBar(
          controller: _tabController, // 탭 컨트롤러 연결
          tabs: [
            Tab(text: 'Info'),
            Tab(text: 'Attributes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // 탭 컨트롤러 연결
        children: [
          _buildInfoTab(), // 정보 입력 탭
          _buildAttributesTab(), // 능력치 입력 탭
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit, // 플레이어 생성 함수 호출
        child: Icon(Icons.check),
      ),
    );
  }

  // 정보 입력 탭 UI
  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController, // 이름 입력 컨트롤러 연결
            decoration: InputDecoration(labelText: 'Player Name'),
          ),
          DropdownButton<String>(
            value: _selectedPosition, // 선택된 포지션 값
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
            value: _selectedPreferredFoot, // 선택된 선호 발 값
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

  // 능력치 입력 탭 UI
  Widget _buildAttributesTab() {
    final attributes = _selectedPosition == '골키퍼'
        ? ['reflexes', 'aeriel', 'handling', 'communication', 'commandOfArea', 'goalKicks', 'throwing']
        : ['dribbling', 'shooting', 'passing', 'firstTouch', 'crossing', 'offTheBall', 'tackling', 'marking', 'defensivePositioning', 'concentration', 'vision'];

    // ListView를 사용하여 overflow 문제를 해결
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 각 능력치에 대한 TextField 생성
        ...attributes.map((attribute) {
          return TextField(
            controller: TextEditingController(text: _attributes[attribute]?.toString() ?? '60'),
            decoration: InputDecoration(labelText: attribute),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _attributes[attribute] = int.tryParse(value) ?? 60;
              });
            },
          );
        }).toList(),
        SizedBox(height: 16),
        Text('Physical Attributes'),
        // 각 신체 능력치에 대한 TextField 생성
        ..._physicalAttributes.keys.map((attribute) {
          return TextField(
            controller: TextEditingController(text: _physicalAttributes[attribute]?.toString() ?? '60'),
            decoration: InputDecoration(labelText: attribute),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _physicalAttributes[attribute] = int.tryParse(value) ?? 60;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}

// MyPlayerDetailView 클래스 정의, StatefulWidget을 상속
class MyPlayerDetailView extends StatefulWidget {
  final MyPlayer myPlayer;

  MyPlayerDetailView({required this.myPlayer});

  @override
  _MyPlayerDetailViewState createState() => _MyPlayerDetailViewState();
}

class _MyPlayerDetailViewState extends State<MyPlayerDetailView> {
  bool _showDetailedAttributes = false; // 상세 능력치 표시 여부

  @override
  Widget build(BuildContext context) {
    final data = widget.myPlayer.position == '골키퍼'
        ? {
      '공배급': widget.myPlayer.goalKicks! * 0.6 + widget.myPlayer.throwing! * 0.3 + widget.myPlayer.communication! * 0.1,
      '수비조율': widget.myPlayer.commandOfArea! * 0.2 + widget.myPlayer.agility! * 0.2 + widget.myPlayer.communication! * 0.5 + widget.myPlayer.handling! * 0.1,
      '공중볼': widget.myPlayer.commandOfArea! * 0.1 + widget.myPlayer.aeriel! * 0.6 + widget.myPlayer.jumping! * 0.3,
      '피지컬': widget.myPlayer.pace * 0.3 + widget.myPlayer.strength * 0.3 + widget.myPlayer.jumping * 0.1 + widget.myPlayer.agility * 0.1 + widget.myPlayer.stamina * 0.2,
      '선방': widget.myPlayer.reflexes! * 0.5 + widget.myPlayer.agility! * 0.3 + widget.myPlayer.handling! * 0.2,
    }
        : {
      '개인기': widget.myPlayer.dribbling! * 0.4 + widget.myPlayer.firstTouch! * 0.3 + widget.myPlayer.agility! * 0.3,
      '슛': widget.myPlayer.strength * 0.3 + widget.myPlayer.shooting! * 0.5 + widget.myPlayer.firstTouch! * 0.2,
      '패스': widget.myPlayer.passing! * 0.4 + widget.myPlayer.vision! * 0.3 + widget.myPlayer.crossing! * 0.2 + widget.myPlayer.firstTouch! * 0.1,
      '수비': widget.myPlayer.tackling! * 0.4 + widget.myPlayer.marking! * 0.2 + widget.myPlayer.defensivePositioning! * 0.2 + widget.myPlayer.concentration! * 0.2,
      '움직임': widget.myPlayer.pace * 0.3 + widget.myPlayer.agility! * 0.2 + (widget.myPlayer.position == '공격수'
          ? widget.myPlayer.offTheBall! * 0.5
          : widget.myPlayer.position == '수비수'
          ? widget.myPlayer.defensivePositioning! * 0.3 + widget.myPlayer.marking! * 0.2
          : widget.myPlayer.offTheBall! * 0.2 + widget.myPlayer.defensivePositioning! * 0.2 + widget.myPlayer.marking! * 0.1),
      '피지컬': widget.myPlayer.pace * 0.3 + widget.myPlayer.strength * 0.3 + widget.myPlayer.jumping * 0.1 + widget.myPlayer.agility * 0.1 + widget.myPlayer.stamina * 0.2,
    };

    final features = data.keys.toList(); // 능력치 이름 리스트
    final dataSet = [data.values.toList().map((value) => value.toDouble()).toList()]; // 레이더 차트 데이터셋

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/football.png',
                  width: 40,
                  height: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Name: ${widget.myPlayer.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Position: ${widget.myPlayer.position}',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Preferred Foot: ${widget.myPlayer.preferredFoot}',
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
                height: 300,
                child: RadarChart(
                  ticks: [30, 60, 90, 120, 150],
                  features: features, // 레이더 차트의 능력치 이름
                  data: dataSet, // 레이더 차트의 데이터
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDetailedAttributes = !_showDetailedAttributes; // 상세 능력치 표시 여부 토글
                });
              },
              child: Text(_showDetailedAttributes ? 'Hide Details' : 'Show Details'),
            ),
            if (_showDetailedAttributes)
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: _buildDetailedAttributes(), // 상세 능력치 리스트 생성
              ),
          ],
        ),
      ),
    );
  }

  // 상세 능력치 리스트를 생성하는 함수
  List<Widget> _buildDetailedAttributes() {
    final detailedAttributes = widget.myPlayer.position == '골키퍼'
        ? {
      'Goalkeeper Skills': {
        'Reflexes': widget.myPlayer.reflexes,
        'Handling': widget.myPlayer.handling,
        'Communication': widget.myPlayer.communication,
        'Command of Area': widget.myPlayer.commandOfArea,
        'Goal Kicks': widget.myPlayer.goalKicks,
        'Throwing': widget.myPlayer.throwing,
        'Aerial': widget.myPlayer.aeriel,
      },
      'Physical Attributes': {
        'Strength': widget.myPlayer.strength,
        'Pace': widget.myPlayer.pace,
        'Stamina': widget.myPlayer.stamina,
        'Agility': widget.myPlayer.agility,
        'Jumping': widget.myPlayer.jumping,
        'Injury Proneness': widget.myPlayer.injuryProneness,
      }
    }
        : {
      'Attacking Skills': {
        'Dribbling': widget.myPlayer.dribbling,
        'Shooting': widget.myPlayer.shooting,
        'Off the ball': widget.myPlayer.offTheBall,
      },
      'Passing Skills': {
        'Passing': widget.myPlayer.passing,
        'First Touch': widget.myPlayer.firstTouch,
        'Vision': widget.myPlayer.vision,
        'Crossing': widget.myPlayer.crossing,
      },
      'Defensive Skills': {
        'Tackling': widget.myPlayer.tackling,
        'Marking': widget.myPlayer.marking,
        'Defensive Positioning': widget.myPlayer.defensivePositioning,
        'Concentration': widget.myPlayer.concentration,
      },
      'Physical Attributes': {
        'Strength': widget.myPlayer.strength,
        'Pace': widget.myPlayer.pace,
        'Stamina': widget.myPlayer.stamina,
        'Agility': widget.myPlayer.agility,
        'Jumping': widget.myPlayer.jumping,
        'Injury Proneness': widget.myPlayer.injuryProneness,
      }
    };

    return detailedAttributes.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.key,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...entry.value.entries.map((attr) {
            return Text('${attr.key}: ${attr.value ?? 'N/A'}');
          }).toList(),
          SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
