import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  final String matchId;

  ChatPage({required this.matchId});

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
      // 서버 주소와 포트를 확인하세요.
      socket = IO.io('http://143.248.229.87:8080', IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());

      socket.connect();
      isConnected = true;

      socket.onConnect((_) {
        print('Connected to socket server');
        // 채팅방에 참가하는 이벤트를 보냅니다.
        socket.emit('join', { 'matchId': widget.matchId });
      });

      // 메시지 수신 처리
      socket.on('message', (data) {
        setState(() {
          messages.add(data);
        });
      });

      // 연결 끊김 처리
      socket.onDisconnect((_) {
        print('Disconnected from socket server');
        isConnected = false;
      });

      // 에러 처리
      socket.on('error', (error) {
        print('Socket error: $error');
      });
    }
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      // 메시지를 서버로 전송
      socket.emit('newMessage', {'matchId': widget.matchId, 'message': message});
      setState(() {
        // 화면에 메시지 추가
        messages.add('Me: $message');
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
