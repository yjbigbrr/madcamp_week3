import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String matchId;
  final String userName; // 추가된 닉네임 정보

  ChatPage({required this.matchId, required this.userName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  void connectSocket() {
    if (!isConnected) {
      socket = IO.io('http://143.248.229.171:3001', IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());

      socket.connect();
      isConnected = true;

      socket.onConnect((_) {
        print('Connected to socket server');
        // 채팅방에 참가하는 이벤트를 보냅니다.
        socket.emit('join', {
          'matchId': widget.matchId,
          'userName': widget.userName // 닉네임 정보 추가
        });
      });

      // 메시지 수신 처리
      socket.on('message', (data) {
        if (data is Map) {
          String userName = data['userName'] ?? 'Unknown';
          String message = data['message'] ?? '';
          setState(() {
            messages.add('$userName: $message');
          });
        }
      });

      socket.on('userJoined', (data) {
        if (data is Map) {
          final userName = data['userName'];
          if (userName is String) {
            print('$userName joined the room');
            setState(() {
              messages.add('$userName joined the room');
            });
          }
        }
      });

      socket.on('userLeft', (data) {
        if (data is Map) {
          final userName = data['userName'];
          if (userName is String) {
            print('$userName left the room');
            setState(() {
              messages.add('$userName left the room');
            });
          }
        }
      });

      socket.onDisconnect((_) {
        print('Disconnected from socket server');
        isConnected = false;
      });

      socket.on('error', (error) {
        print('Socket error: $error');
      });
    }
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      socket.emit('newMessage', {
        'matchId': widget.matchId,
        'message': message,
        'userName': widget.userName // 닉네임 정보 추가
      });
      messageController.clear();
    }
  }

  @override
  void dispose() {
    socket.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
