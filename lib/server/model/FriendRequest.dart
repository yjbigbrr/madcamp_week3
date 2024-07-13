class FriendRequest {
  final String senderId;
  final String status;

  FriendRequest({
    required this.senderId,
    this.status = 'pending',
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      senderId: json['senderId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'status': status,
    };
  }
}