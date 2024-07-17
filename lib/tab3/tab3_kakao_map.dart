import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:soccer_app/server/model/Meetings.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _requestAllMeetings(); // 전체 미팅 목록 요청
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  void _initializeWebSocket() {
    try {
      print('Attempting to connect to WebSocket...');
      channel = IOWebSocketChannel.connect('ws://172.10.7.63:80');
      channel?.stream.listen(
            (message) {
          debugPrint('Received: $message');
          final decodedMessage = jsonDecode(message);
          switch (decodedMessage['event']) {
            case 'meetingCreated':
              _handleMeetingCreated(decodedMessage['data']);
              break;
            case 'meetingUpdated':
              _handleMeetingUpdated(decodedMessage['data']);
              break;
            case 'meetingsFound':
              debugPrint("hello!!!!!!! meetings found!!!!!!");
              _handleMeetingsFound(decodedMessage['data']);
              break;
            case 'createMeetingError':
              _showToast('Error creating meeting: ${decodedMessage['error']}', Colors.red);
              break;
            case 'joinMeetingError':
              _showToast('Error joining meeting: ${decodedMessage['error']}', Colors.red);
              break;
            case 'welcome': // New event listener
              _showToast(decodedMessage['message'], Colors.green);
              break;
          }
        },
        onError: (error) {
          _showToast('WebSocket Error: $error', Colors.red);
        },
        onDone: () {
          _showToast('WebSocket connection closed', Colors.yellow);
        },
      );
    } catch (e) {
      _showToast('WebSocket connection error: $e', Colors.red);
    }
  }


  void _requestAllMeetings() {
    channel?.sink.add(jsonEncode({'event': 'findAllMeetings'}));
  }

  void _handleMeetingCreated(data) {
    debugPrint("hellohellohello meeting created");
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
    debugPrint("handle meeting found!!!!!!!!!!!!");
    setState(() {
      meetings.clear();
      // 데이터가 배열인지 확인하고 변환
      if (data is List) {
        meetings.addAll(data.map((item) => Meeting.fromJson(item)).toList());
      } else {
        _showToast('Invalid data format received from server.', Colors.red);
      }
    });
  }

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
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
                _buildTextField(_titleController, '제목'),
                _buildTextField(_maxParticipantsController, '최대 참여자 수', keyboardType: TextInputType.number),
                _buildTextField(_pubAddressController, '펍의 주소', onChanged: (value) => _getCoordinates(value)),
                _buildTextField(_supportTeamController, '응원하는 팀'),
                SizedBox(height: 8.0),
                _buildDateTimeButton('시작 시간 선택', _startDateTime, (date) => setState(() => _startDateTime = date)),
                if (_startDateTime != null) _buildDateTimeText('시작 시간', _startDateTime),
                _buildDateTimeButton('종료 시간 선택', _endDateTime, (date) => setState(() => _endDateTime = date)),
                if (_endDateTime != null) _buildDateTimeText('종료 시간', _endDateTime),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: _validateAndAddMeeting,
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text, void Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: labelText),
      onChanged: onChanged,
    );
  }

  TextButton _buildDateTimeButton(String label, DateTime? dateTime, void Function(DateTime?) onDateSelected) {
    return TextButton(
      onPressed: () async {
        final selectedDate = await _selectDateTime();
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Text(
        dateTime == null
            ? label
            : '${dateTime.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
      ),
    );
  }

  Padding _buildDateTimeText(String label, DateTime? dateTime) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        '$label: ${dateTime!.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
        style: TextStyle(fontSize: 14),
      ),
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
        return DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
      }
    }
    return null;
  }

  void _validateAndAddMeeting() {
    if (_titleController.text.isEmpty ||
        _maxParticipantsController.text.isEmpty ||
        _pubAddressController.text.isEmpty ||
        _supportTeamController.text.isEmpty ||
        _startDateTime == null ||
        _endDateTime == null) {
      _showToast('모든 항목을 채워주세요.', Colors.red);
      return;
    }

    int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;

    if (maxParticipants < 2) {
      _showToast('모임은 최소 2명 이상이어야 합니다.', Colors.red);
      return;
    }

    final newMeeting = Meeting(
      id: DateTime.now().toString(),
      title: _titleController.text,
      maxParticipants: maxParticipants,
      currentParticipants: 1,
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
      _clearMeetingForm();
    });

    channel?.sink.add(jsonEncode({'event': 'createMeeting', 'data': newMeeting.toJson()}));
    Navigator.of(context).pop();
  }

  void _clearMeetingForm() {
    _titleController.clear();
    _maxParticipantsController.clear();
    _pubAddressController.clear();
    _supportTeamController.clear();
    _startDateTime = null;
    _endDateTime = null;
  }

  void _joinMeeting(String meetingId) {
    final meeting = meetings.firstWhere((meeting) => meeting.id == meetingId);

    if (meeting.currentParticipants >= meeting.maxParticipants) {
      _showToast('모임이 이미 가득 찼습니다.', Colors.red);
      return;
    }

    // 서버에 참가 요청을 보냅니다.
    final request = jsonEncode({
      'event': 'joinMeeting',
      'data': {
        'id': meetingId,
        'participantId': 'user123', // 실제 사용자 ID로 변경 필요
      }
    });

    channel?.sink.add(request);
  }

  Future<void> _getCoordinates(String address) async {
    final url = 'https://dapi.kakao.com/v2/local/search/address.json?query=$address';
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
      _showToast('주소를 변환하는데 실패했습니다.', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kakao Map Example'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: KakaoMapView(),
          ),
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
                              'Longitude: ${meeting.longitude}, Latitude: ${meeting.latitude}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (meeting.creatorId != 'user123') {
                              _joinMeeting(meeting.id);
                            } else {
                              _showToast("모임 생성자는 참여할 수 없습니다.", Colors.red);
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
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _showAddMeetingDialog,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}


class KakaoMapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://map.kakao.com/',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
// class KakaoMapView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//       initialUrl: 'https://map.kakao.com/',
//       javascriptMode: JavascriptMode.unrestricted,
//     );
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:soccer_app/server/model/Meetings.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

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
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//     _initializeWebSocket();
//     _requestAllMeetings(); // 전체 미팅 목록 요청
//   }

//   @override
//   void dispose() {
//     channel?.sink.close();
//     super.dispose();
//   }

//   void _initializeWebSocket() {
//     try {
//       print('Attempting to connect to WebSocket...');
//       channel = IOWebSocketChannel.connect('ws://143.248.226.9:3000');
//       channel?.stream.listen(
//             (message) {
//           debugPrint('Received: $message');
//           final decodedMessage = jsonDecode(message);
//           switch (decodedMessage['event']) {
//             case 'meetingCreated':
//               _handleMeetingCreated(decodedMessage['data']);
//               break;
//             case 'meetingUpdated':
//               _handleMeetingUpdated(decodedMessage['data']);
//               break;
//             case 'meetingsFound':
//               debugPrint("hello!!!!!!! meetings found!!!!!!");
//               _handleMeetingsFound(decodedMessage['data']);
//               break;
//             case 'createMeetingError':
//               _showToast('Error creating meeting: ${decodedMessage['error']}', Colors.red);
//               break;
//             case 'joinMeetingError':
//               _showToast('Error joining meeting: ${decodedMessage['error']}', Colors.red);
//               break;
//             case 'welcome': // New event listener
//               _showToast(decodedMessage['message'], Colors.green);
//               break;
//           }
//         },
//         onError: (error) {
//           _showToast('WebSocket Error: $error', Colors.red);
//         },
//         onDone: () {
//           _showToast('WebSocket connection closed', Colors.yellow);
//         },
//       );
//     } catch (e) {
//       _showToast('WebSocket connection error: $e', Colors.red);
//     }
//   }


//   void _requestAllMeetings() {
//     channel?.sink.add(jsonEncode({'event': 'findAllMeetings'}));
//   }

//   void _handleMeetingCreated(data) {
//     debugPrint("hellohellohello meeting created");
//     setState(() {
//       meetings.add(Meeting.fromJson(data));
//     });
//   }

//   void _handleMeetingUpdated(data) {
//     setState(() {
//       final index = meetings.indexWhere((meeting) => meeting.id == data['id']);
//       if (index != -1) {
//         meetings[index] = Meeting.fromJson(data);
//       }
//     });
//   }

//   void _handleMeetingsFound(data) {
//     debugPrint("handle meeting found!!!!!!!!!!!!");
//     setState(() {
//       meetings.clear();
//       // 데이터가 배열인지 확인하고 변환
//       if (data is List) {
//         meetings.addAll(data.map((item) => Meeting.fromJson(item)).toList());
//       } else {
//         _showToast('Invalid data format received from server.', Colors.red);
//       }
//     });
//   }

//   void _showToast(String message, Color color) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.CENTER,
//       backgroundColor: color,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

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
//                 _buildTextField(_titleController, '제목'),
//                 _buildTextField(_maxParticipantsController, '최대 참여자 수', keyboardType: TextInputType.number),
//                 _buildTextField(_pubAddressController, '펍의 주소', onChanged: (value) => _getCoordinates(value)),
//                 _buildTextField(_supportTeamController, '응원하는 팀'),
//                 SizedBox(height: 8.0),
//                 _buildDateTimeButton('시작 시간 선택', _startDateTime, (date) => setState(() => _startDateTime = date)),
//                 if (_startDateTime != null) _buildDateTimeText('시작 시간', _startDateTime),
//                 _buildDateTimeButton('종료 시간 선택', _endDateTime, (date) => setState(() => _endDateTime = date)),
//                 if (_endDateTime != null) _buildDateTimeText('종료 시간', _endDateTime),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('취소'),
//             ),
//             TextButton(
//               onPressed: _validateAndAddMeeting,
//               child: Text('추가'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   TextField _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text, void Function(String)? onChanged}) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(labelText: labelText),
//       onChanged: onChanged,
//     );
//   }

//   TextButton _buildDateTimeButton(String label, DateTime? dateTime, void Function(DateTime?) onDateSelected) {
//     return TextButton(
//       onPressed: () async {
//         final selectedDate = await _selectDateTime();
//         if (selectedDate != null) {
//           onDateSelected(selectedDate);
//         }
//       },
//       child: Text(
//         dateTime == null
//             ? label
//             : '${dateTime.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
//       ),
//     );
//   }

//   Padding _buildDateTimeText(String label, DateTime? dateTime) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: Text(
//         '$label: ${dateTime!.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
//         style: TextStyle(fontSize: 14),
//       ),
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
//         return DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
//       }
//     }
//     return null;
//   }

//   void _validateAndAddMeeting() {
//     if (_titleController.text.isEmpty ||
//         _maxParticipantsController.text.isEmpty ||
//         _pubAddressController.text.isEmpty ||
//         _supportTeamController.text.isEmpty ||
//         _startDateTime == null ||
//         _endDateTime == null) {
//       _showToast('모든 항목을 채워주세요.', Colors.red);
//       return;
//     }

//     int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;

//     if (maxParticipants < 2) {
//       _showToast('모임은 최소 2명 이상이어야 합니다.', Colors.red);
//       return;
//     }

//     final newMeeting = Meeting(
//       id: DateTime.now().toString(),
//       title: _titleController.text,
//       maxParticipants: maxParticipants,
//       currentParticipants: 1,
//       pubAddress: _pubAddressController.text,
//       supportTeam: _supportTeamController.text,
//       date: _startDateTime?.toLocal().toString().split(' ')[0] ?? '',
//       time: '${_startDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''} ~ ${_endDateTime?.toLocal().toString().split(' ')[1].substring(0, 5) ?? ''}',
//       longitude: longitude,
//       latitude: latitude,
//       creatorId: 'user123', // 임시로 ‘user123’ 설정, 실제 유저 ID로 대체 필요
//     );

//     setState(() {
//       meetings.add(newMeeting);
//       _clearMeetingForm();
//     });

//     channel?.sink.add(jsonEncode({'event': 'createMeeting', 'data': newMeeting.toJson()}));
//     Navigator.of(context).pop();
//   }

//   void _clearMeetingForm() {
//     _titleController.clear();
//     _maxParticipantsController.clear();
//     _pubAddressController.clear();
//     _supportTeamController.clear();
//     _startDateTime = null;
//     _endDateTime = null;
//   }

//   void _joinMeeting(String meetingId) {
//     final meeting = meetings.firstWhere((meeting) => meeting.id == meetingId);

//     if (meeting.currentParticipants >= meeting.maxParticipants) {
//       _showToast('모임이 이미 가득 찼습니다.', Colors.red);
//       return;
//     }

//     // 서버에 참가 요청을 보냅니다.
//     final request = jsonEncode({
//       'event': 'joinMeeting',
//       'data': {
//         'id': meetingId,
//         'participantId': 'user123', // 실제 사용자 ID로 변경 필요
//       }
//     });

//     channel?.sink.add(request);
//   }

//   Future<void> _getCoordinates(String address) async {
//     final url = 'https://dapi.kakao.com/v2/local/search/address.json?query=$address';
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {'Authorization': 'KakaoAK 22f40ccdc4442898c8643d005848ae3d'},
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['documents'].isNotEmpty) {
//         final coords = data['documents'][0];
//         setState(() {
//           longitude = double.parse(coords['x']);
//           latitude = double.parse(coords['y']);
//         });
//       }
//     } else {
//       _showToast('주소를 변환하는데 실패했습니다.', Colors.red);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Kakao Map Example'),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: KakaoMapView(),
//           ),
//           if (!isMapView)
//             DraggableScrollableSheet(
//               initialChildSize: 0.5,
//               minChildSize: 0.25,
//               maxChildSize: 0.8,
//               builder: (BuildContext context, ScrollController scrollController) {
//                 return Container(
//                   color: Colors.white,
//                   child: ListView.builder(
//                     controller: scrollController,
//                     itemCount: meetings.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final meeting = meetings[index];
//                       return ListTile(
//                         leading: Icon(Icons.sports_soccer),
//                         title: Text(meeting.title),
//                         subtitle: Text(
//                           '${meeting.currentParticipants}/${meeting.maxParticipants} participants\n'
//                               '${meeting.pubAddress}\n'
//                               '${meeting.supportTeam}\n'
//                               '${meeting.date} ${meeting.time}\n'
//                               'Longitude: ${meeting.longitude}, Latitude: ${meeting.latitude}',
//                         ),
//                         trailing: ElevatedButton(
//                           onPressed: () {
//                             if (meeting.creatorId != 'user123') {
//                               _joinMeeting(meeting.id);
//                             } else {
//                               _showToast("모임 생성자는 참여할 수 없습니다.", Colors.red);
//                             }
//                           },
//                           child: Text('참여'),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: () {
//                 setState(() {
//                   isMapView = !isMapView;
//                 });
//                 print('isMapView toggled to $isMapView');
//               },
//               child: Text(
//                 isMapView ? '목록보기' : '지도보기',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: FloatingActionButton(
//               onPressed: _showAddMeetingDialog,
//               child: Icon(Icons.add),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class KakaoMapView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WebView(
//       initialUrl: 'https://map.kakao.com/',
//       javascriptMode: JavascriptMode.unrestricted,
//     );
//   }
// }