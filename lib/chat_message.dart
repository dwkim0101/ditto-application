// 채팅 메시지 데이터 클래스
class ChatMessage {
  final String sender;
  final String message;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isMe,
  });
}
