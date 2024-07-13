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
  Map<String, int> _physicalAttributes = {};

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
      _attributes[attribute] = 60;
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
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

class MyPlayerDetailView extends StatefulWidget {
  final MyPlayer myPlayer;

  MyPlayerDetailView({required this.myPlayer});

  @override
  _MyPlayerDetailViewState createState() => _MyPlayerDetailViewState();
}

class _MyPlayerDetailViewState extends State<MyPlayerDetailView> {
  bool _showDetailedAttributes = false;

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

    final features = data.keys.toList();
    final dataSet = [data.values.toList().map((value) => value.toDouble()).toList()];

    return Scaffold(
      body: Padding(
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
                  features: features,
                  data: dataSet,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDetailedAttributes = !_showDetailedAttributes;
                });
              },
              child: Text(_showDetailedAttributes ? 'Hide Details' : 'Show Details'),
            ),
            if (_showDetailedAttributes)
              Expanded(
                child: ListView(
                  children: _buildDetailedAttributes(),
                ),
              ),
          ],
        ),
      ),
    );
  }

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


