
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:soccer_app/server/model/Meetings.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KakaoMapScreen(),
    );
  }
}

class KakaoMapScreen extends StatefulWidget {
  @override
  _KakaoMapScreenState createState() => _KakaoMapScreenState();
}

class _KakaoMapScreenState extends State<KakaoMapScreen> {
  bool isMapView = true;
  final List<Meeting> meetings = [];
  WebSocketChannel? channel;

  final _titleController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _pubAddressController = TextEditingController();
  final _supportTeamController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  double longitude = 0.0;
  double latitude = 0.0;

  @override
void initState() {
  super.initState();
  if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  _initializeWebSocket();

  // 모든 모임 조회 요청
  _requestAllMeetings();
}

void _requestAllMeetings() {
  channel?.sink.add(jsonEncode({
    'event': 'findAllMeetings'
  }));
}
   void _initializeWebSocket() {
    try {
      print('Attempting to connect to WebSocket...');
      channel = IOWebSocketChannel.connect('ws://10.0.2.2:3001'); // 포트 확인
       print('Attempting to connect to WebSocket2...');
      channel?.stream.listen((message) {
        print('Received: $message');
        final decodedMessage = jsonDecode(message);
        
        // 이벤트 타입에 따라 처리
        if (decodedMessage['event'] == 'meetingCreated') {
          _handleMeetingCreated(decodedMessage['data']);
        } else if (decodedMessage['event'] == 'meetingUpdated') {
          _handleMeetingUpdated(decodedMessage['data']);
        } else if (decodedMessage['event'] == 'meetingsFound') {
          _handleMeetingsFound(decodedMessage['data']);
        }
      }, onError: (error) {
        print('WebSocket Error: $error');
        Fluttertoast.showToast(
          msg: 'WebSocket Error: $error',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }, onDone: () {
        print('WebSocket connection closed');
        Fluttertoast.showToast(
          msg: 'WebSocket connection closed',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.yellow,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      });
    } catch (e) {
      print('WebSocket connection error: $e');
      Fluttertoast.showToast(
        msg: 'WebSocket connection error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

void _handleMeetingCreated(data) {
  setState(() {
    meetings.add(Meeting.fromJson(data));
  });
}

void _handleMeetingUpdated(data) {
  setState(() {
    final index = meetings.indexWhere((meeting) => meeting.id == data['id']);
    if (index != -1) {
      meetings[index] = Meeting.fromJson(data);
    }
  });
}

void _handleMeetingsFound(data) {
  setState(() {
    meetings.clear();
    meetings.addAll((data as List).map((item) => Meeting.fromJson(item)).toList());
  });
}
  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Kakao Map Example'),
    ),
    body: Stack(
      children: [
        // 첫 번째 자식: 전체 화면을 차지하는 KakaoMapView
        Positioned.fill(
          child: KakaoMapView(),
        ),
        // 조건에 따라 보여지는 DraggableScrollableSheet
        if (!isMapView)
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.25,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                color: Colors.white,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: meetings.length,
                  itemBuilder: (BuildContext context, int index) {
                    final meeting = meetings[index];
                    return ListTile(
                      leading: Icon(Icons.sports_soccer),
                      title: Text(meeting.title),
                      subtitle: Text(
                        '${meeting.currentParticipants}/${meeting.maxParticipants} participants\n'
                        '${meeting.pubAddress}\n'
                        '${meeting.supportTeam}\n'
                        '${meeting.date} ${meeting.time}\n'
                        'Longitude: ${meeting.longitude}, Latitude: ${meeting.latitude}'
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (meeting.creatorId != 'user123') {
                            _joinMeeting(meeting.id);
                          } else {
                            Fluttertoast.showToast(
                              msg: "모임 생성자는 참여할 수 없습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        },
                        child: Text('참여'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        // 지도 보기/목록 보기 토글 버튼
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () { 
              setState(() {
                isMapView = !isMapView;
              });
              print('isMapView toggled to $isMapView');
            },
            child: Text(
              isMapView ? '목록보기' : '지도보기',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
        // 새 모임 추가 버튼
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            onPressed: () {
              _showAddMeetingDialog();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    ),
  );
}

  void _showAddMeetingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새로운 이벤트'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: _maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: '최대 참여자 수'),
                ),
                TextField(
                  controller: _pubAddressController,
                  decoration: InputDecoration(labelText: '펍의 주소'),
                  onChanged: (value) {
                    _getCoordinates(value);
                  },
                ),
                TextField(
                  controller: _supportTeamController,
                  decoration: InputDecoration(labelText: '응원하는 팀'),
                ),
                SizedBox(height: 8.0),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await _selectDateTime();
                    if (selectedDate != null) {
                      setState(() {
                        _startDateTime = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    _startDateTime == null
                        ? '시작 시간 선택'
                        : '${_startDateTime!.toLocal()}'.split(' ')[0] + ' ' + _startDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
                  ),
                ),
                if (_startDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '시작 시간: ${_startDateTime!.toLocal()}'.split(' ')[0] + ' ' + _startDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await _selectDateTime();
                    if (selectedDate != null) {
                      setState(() {
                        _endDateTime = selectedDate;
                      });
                    }
                  },
                  child: Text(
                    _endDateTime == null
                        ? '종료 시간 선택'
                        : '${_endDateTime!.toLocal()}'.split(' ')[0] + ' ' + _endDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
                  ),
                ),
                if (_endDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '종료 시간: ${_endDateTime!.toLocal()}'.split(' ')[0] + ' ' + _endDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _validateAndAddMeeting();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDateTime() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                selectedTime.hour, selectedTime.minute);
  }
}
return null;}
void _validateAndAddMeeting() {
if (_titleController.text.isEmpty ||
_maxParticipantsController.text.isEmpty ||
_pubAddressController.text.isEmpty ||
_supportTeamController.text.isEmpty ||
_startDateTime == null ||
_endDateTime == null) {
Fluttertoast.showToast(
msg: '모든 항목을 채워주세요.',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.CENTER,
backgroundColor: Colors.red,
textColor: Colors.white,
fontSize: 16.0,
);
return;
}
int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;

if (maxParticipants < 2) {
  Fluttertoast.showToast(
    msg: '모임은 최소 2명 이상이어야 합니다.',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
  return;
}

final newMeeting = Meeting(
  id: DateTime.now().toString(),
  title: _titleController.text,
  maxParticipants: maxParticipants,
  currentParticipants: 1, // 모임 생성자는 자동으로 참여자로 추가
  pubAddress: _pubAddressController.text,
  supportTeam: _supportTeamController.text,
  date: _startDateTime?.toLocal().toString().split(' ')[0] ?? '',
  time: '${_startDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''} ~ ${_endDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''}',
  longitude: longitude,
  latitude: latitude,
  creatorId: 'user123', // 임시로 ‘user123’ 설정, 실제 유저 ID로 대체 필요
);
setState(() {
  meetings.add(newMeeting);
  _titleController.clear();
  _maxParticipantsController.clear();
  _pubAddressController.clear();
  _supportTeamController.clear();
  _startDateTime = null;
  _endDateTime = null;
});

channel?.sink.add(jsonEncode(newMeeting.toJson())); // WebSocket으로 새로운 모임 정보 전송

Navigator.of(context).pop();}
void _joinMeeting(String meetingId) {
setState(() {
final meeting = meetings.firstWhere((meeting) => meeting.id == meetingId);
if (meeting.currentParticipants < meeting.maxParticipants) {
meeting.currentParticipants += 1;
channel?.sink.add(jsonEncode(meeting.toJson())); // WebSocket으로 업데이트된 모임 정보 전송
} else {
Fluttertoast.showToast(
msg: '모임이 이미 가득 찼습니다.',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.CENTER,
backgroundColor: Colors.red,
textColor: Colors.white,
fontSize: 16.0,
);
}
});
}

Future _getCoordinates(String address) async {
final url =
'https://dapi.kakao.com/v2/local/search/address.json?query=$address';
final response = await http.get(
Uri.parse(url),
headers: {'Authorization': 'KakaoAK 22f40ccdc4442898c8643d005848ae3d'},
);
if (response.statusCode == 200) {
final data = json.decode(response.body);
if (data['documents'].isNotEmpty) {
final coords = data['documents'][0];
setState(() {
longitude = double.parse(coords['x']);
latitude = double.parse(coords['y']);
});
}
} else {
Fluttertoast.showToast(
msg: '주소를 변환하는데 실패했습니다.',
toastLength: Toast.LENGTH_SHORT,
gravity: ToastGravity.CENTER,
backgroundColor: Colors.red,
textColor: Colors.white,
fontSize: 16.0,
);
}
}
}

class KakaoMapView extends StatelessWidget {
@override
Widget build(BuildContext context) {
return Container(
child: WebView(
initialUrl: 'https://map.kakao.com/',
javascriptMode: JavascriptMode.unrestricted,
),
);
}
}







// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:soccer_app/server/model/Meetings.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: KakaoMapScreen(),
//     );
//   }
// }

// class KakaoMapScreen extends StatefulWidget {
//   @override
//   _KakaoMapScreenState createState() => _KakaoMapScreenState();
// }

// class _KakaoMapScreenState extends State<KakaoMapScreen> {
//   bool isMapView = true;
//   final List<Meeting> meetings = [];
//   WebSocketChannel? channel;

//   final _titleController = TextEditingController();
//   final _maxParticipantsController = TextEditingController();
//   final _pubAddressController = TextEditingController();
//   final _supportTeamController = TextEditingController();
//   DateTime? _startDateTime;
//   DateTime? _endDateTime;
//   double longitude = 0.0;
//   double latitude = 0.0;

//   @override
// void initState() {
//   super.initState();
//   if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   _initializeWebSocket();

//   // 모든 모임 조회 요청
//   _requestAllMeetings();
// }

// void _requestAllMeetings() {
//   channel?.sink.add(jsonEncode({
//     'event': 'findAllMeetings'
//   }));
// }
//   void _initializeWebSocket() {
//   try {
//     print('Attempting to connect to WebSocket...');
//     channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
//     channel?.stream.listen((message) {
//       print('Received: $message');
//       final decodedMessage = jsonDecode(message);
      
//       // 이벤트 타입에 따라 처리
//       if (decodedMessage['event'] == 'meetingCreated') {
//         _handleMeetingCreated(decodedMessage['data']);
//       } else if (decodedMessage['event'] == 'meetingUpdated') {
//         _handleMeetingUpdated(decodedMessage['data']);
//       } else if (decodedMessage['event'] == 'meetingsFound') {
//         _handleMeetingsFound(decodedMessage['data']);
//       }
//     }, onError: (error) {
//       print('WebSocket Error: $error');
//       Fluttertoast.showToast(
//         msg: 'WebSocket Error: $error',
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.CENTER,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0,
//       );
//     }, onDone: () {
//       print('WebSocket connection closed');
//       Fluttertoast.showToast(
//         msg: 'WebSocket connection closed',
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.CENTER,
//         backgroundColor: Colors.yellow,
//         textColor: Colors.black,
//         fontSize: 16.0,
//       );
//     });
//   } catch (e) {
//     print('WebSocket connection error: $e');
//     Fluttertoast.showToast(
//       msg: 'WebSocket connection error: $e',
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.CENTER,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }
// }

// void _handleMeetingCreated(data) {
//   setState(() {
//     meetings.add(Meeting.fromJson(data));
//   });
// }

// void _handleMeetingUpdated(data) {
//   setState(() {
//     final index = meetings.indexWhere((meeting) => meeting.id == data['id']);
//     if (index != -1) {
//       meetings[index] = Meeting.fromJson(data);
//     }
//   });
// }

// void _handleMeetingsFound(data) {
//   setState(() {
//     meetings.clear();
//     meetings.addAll((data as List).map((item) => Meeting.fromJson(item)).toList());
//   });
// }
//   @override
//   void dispose() {
//     channel?.sink.close();
//     super.dispose();
//   }

//   @override
//   @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text('Kakao Map Example'),
//     ),
//     body: Stack(
//       children: [
//         // 첫 번째 자식: 전체 화면을 차지하는 KakaoMapView
//         Positioned.fill(
//           child: KakaoMapView(),
//         ),
//         // 조건에 따라 보여지는 DraggableScrollableSheet
//         if (!isMapView)
//           DraggableScrollableSheet(
//             initialChildSize: 0.5,
//             minChildSize: 0.25,
//             maxChildSize: 0.8,
//             builder: (BuildContext context, ScrollController scrollController) {
//               return Container(
//                 color: Colors.white,
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: meetings.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     final meeting = meetings[index];
//                     return ListTile(
//                       leading: Icon(Icons.sports_soccer),
//                       title: Text(meeting.title),
//                       subtitle: Text(
//                         '${meeting.currentParticipants}/${meeting.maxParticipants} participants\n'
//                         '${meeting.pubAddress}\n'
//                         '${meeting.supportTeam}\n'
//                         '${meeting.date} ${meeting.time}\n'
//                         'Longitude: ${meeting.longitude}, Latitude: ${meeting.latitude}'
//                       ),
//                       trailing: ElevatedButton(
//                         onPressed: () {
//                           if (meeting.creatorId != 'user123') {
//                             _joinMeeting(meeting.id);
//                           } else {
//                             Fluttertoast.showToast(
//                               msg: "모임 생성자는 참여할 수 없습니다.",
//                               toastLength: Toast.LENGTH_SHORT,
//                               gravity: ToastGravity.CENTER,
//                               backgroundColor: Colors.red,
//                               textColor: Colors.white,
//                               fontSize: 16.0,
//                             );
//                           }
//                         },
//                         child: Text('참여'),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//         // 지도 보기/목록 보기 토글 버튼
//         Positioned(
//           bottom: 20,
//           right: 20,
//           child: FloatingActionButton(
//             onPressed: () { 
//               setState(() {
//                 isMapView = !isMapView;
//               });
//               print('isMapView toggled to $isMapView');
//             },
//             child: Text(
//               isMapView ? '목록보기' : '지도보기',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12),
//             ),
//           ),
//         ),
//         // 새 모임 추가 버튼
//         Positioned(
//           bottom: 20,
//           left: 20,
//           child: FloatingActionButton(
//             onPressed: () {
//               _showAddMeetingDialog();
//             },
//             child: Icon(Icons.add),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   void _showAddMeetingDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('새로운 이벤트'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(labelText: '제목'),
//                 ),
//                 TextField(
//                   controller: _maxParticipantsController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(labelText: '최대 참여자 수'),
//                 ),
//                 TextField(
//                   controller: _pubAddressController,
//                   decoration: InputDecoration(labelText: '펍의 주소'),
//                   onChanged: (value) {
//                     _getCoordinates(value);
//                   },
//                 ),
//                 TextField(
//                   controller: _supportTeamController,
//                   decoration: InputDecoration(labelText: '응원하는 팀'),
//                 ),
//                 SizedBox(height: 8.0),
//                 TextButton(
//                   onPressed: () async {
//                     final selectedDate = await _selectDateTime();
//                     if (selectedDate != null) {
//                       setState(() {
//                         _startDateTime = selectedDate;
//                       });
//                     }
//                   },
//                   child: Text(
//                     _startDateTime == null
//                         ? '시작 시간 선택'
//                         : '${_startDateTime!.toLocal()}'.split(' ')[0] + ' ' + _startDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
//                   ),
//                 ),
//                 if (_startDateTime != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       '시작 시간: ${_startDateTime!.toLocal()}'.split(' ')[0] + ' ' + _startDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 TextButton(
//                   onPressed: () async {
//                     final selectedDate = await _selectDateTime();
//                     if (selectedDate != null) {
//                       setState(() {
//                         _endDateTime = selectedDate;
//                       });
//                     }
//                   },
//                   child: Text(
//                     _endDateTime == null
//                         ? '종료 시간 선택'
//                         : '${_endDateTime!.toLocal()}'.split(' ')[0] + ' ' + _endDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
//                   ),
//                 ),
//                 if (_endDateTime != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       '종료 시간: ${_endDateTime!.toLocal()}'.split(' ')[0] + ' ' + _endDateTime!.toLocal().toString().split(' ')[1].substring(0, 5),
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('취소'),
//             ),
//             TextButton(
//               onPressed: () {
//                 _validateAndAddMeeting();
//               },
//               child: Text('추가'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<DateTime?> _selectDateTime() async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );

//     if (selectedDate != null) {
//       TimeOfDay? selectedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (selectedTime != null) {
//         return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
//                 selectedTime.hour, selectedTime.minute);
//   }
// }
// return null;}
// void _validateAndAddMeeting() {
// if (_titleController.text.isEmpty ||
// _maxParticipantsController.text.isEmpty ||
// _pubAddressController.text.isEmpty ||
// _supportTeamController.text.isEmpty ||
// _startDateTime == null ||
// _endDateTime == null) {
// Fluttertoast.showToast(
// msg: '모든 항목을 채워주세요.',
// toastLength: Toast.LENGTH_SHORT,
// gravity: ToastGravity.CENTER,
// backgroundColor: Colors.red,
// textColor: Colors.white,
// fontSize: 16.0,
// );
// return;
// }
// int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;

// if (maxParticipants < 2) {
//   Fluttertoast.showToast(
//     msg: '모임은 최소 2명 이상이어야 합니다.',
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.CENTER,
//     backgroundColor: Colors.red,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
//   return;
// }

// final newMeeting = Meeting(
//   id: DateTime.now().toString(),
//   title: _titleController.text,
//   maxParticipants: maxParticipants,
//   currentParticipants: 1, // 모임 생성자는 자동으로 참여자로 추가
//   pubAddress: _pubAddressController.text,
//   supportTeam: _supportTeamController.text,
//   date: _startDateTime?.toLocal().toString().split(' ')[0] ?? '',
//   time: '${_startDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''} ~ ${_endDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''}',
//   longitude: longitude,
//   latitude: latitude,
//   creatorId: 'user123', // 임시로 ‘user123’ 설정, 실제 유저 ID로 대체 필요
// );
// setState(() {
//   meetings.add(newMeeting);
//   _titleController.clear();
//   _maxParticipantsController.clear();
//   _pubAddressController.clear();
//   _supportTeamController.clear();
//   _startDateTime = null;
//   _endDateTime = null;
// });

// channel?.sink.add(jsonEncode(newMeeting.toJson())); // WebSocket으로 새로운 모임 정보 전송

// Navigator.of(context).pop();}
// void _joinMeeting(String meetingId) {
// setState(() {
// final meeting = meetings.firstWhere((meeting) => meeting.id == meetingId);
// if (meeting.currentParticipants < meeting.maxParticipants) {
// meeting.currentParticipants += 1;
// channel?.sink.add(jsonEncode(meeting.toJson())); // WebSocket으로 업데이트된 모임 정보 전송
// } else {
// Fluttertoast.showToast(
// msg: '모임이 이미 가득 찼습니다.',
// toastLength: Toast.LENGTH_SHORT,
// gravity: ToastGravity.CENTER,
// backgroundColor: Colors.red,
// textColor: Colors.white,
// fontSize: 16.0,
// );
// }
// });
// }

// Future _getCoordinates(String address) async {
// final url =
// 'https://dapi.kakao.com/v2/local/search/address.json?query=$address';
// final response = await http.get(
// Uri.parse(url),
// headers: {'Authorization': 'KakaoAK 22f40ccdc4442898c8643d005848ae3d'},
// );
// if (response.statusCode == 200) {
// final data = json.decode(response.body);
// if (data['documents'].isNotEmpty) {
// final coords = data['documents'][0];
// setState(() {
// longitude = double.parse(coords['x']);
// latitude = double.parse(coords['y']);
// });
// }
// } else {
// Fluttertoast.showToast(
// msg: '주소를 변환하는데 실패했습니다.',
// toastLength: Toast.LENGTH_SHORT,
// gravity: ToastGravity.CENTER,
// backgroundColor: Colors.red,
// textColor: Colors.white,
// fontSize: 16.0,
// );
// }
// }
// }

// class KakaoMapView extends StatelessWidget {
// @override
// Widget build(BuildContext context) {
// return Container(
// child: WebView(
// initialUrl: 'https://map.kakao.com/',
// javascriptMode: JavascriptMode.unrestricted,
// ),
// );
// }
// }
