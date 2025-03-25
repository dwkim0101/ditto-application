import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ditto/exam_end_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoChatScreen extends StatefulWidget {
  final bool isVideoEnabled;
  final bool isAudioEnabled;

  const VideoChatScreen({
    super.key,
    required this.isVideoEnabled,
    required this.isAudioEnabled,
  });

  @override
  State<VideoChatScreen> createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  late bool _isVideoEnabled;
  late bool _isAudioEnabled;

  late IO.Socket socket;
  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream; // Changed to nullable
  final TextEditingController messageController = TextEditingController();
  final TextEditingController chatAreaController = TextEditingController();

  bool _isInitialized = false; // Loading state
  String room = "testRoom";
  late RTCVideoRenderer _localRenderer; // Declare RTCVideoRenderer

  Timer? _captureTimer;
  ui.Image? _currentFrame;
  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideoEnabled;
    _isAudioEnabled = widget.isAudioEnabled;
    _localRenderer = RTCVideoRenderer();
    _initializeSocket();
    _initializeMedia();
  }

  Future<String?> getExamNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('examNumber');
  }

  Future<void> _initializeMedia() async {
    try {
      await _localRenderer.initialize();
      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
      };

      final localStream =
          await navigator.mediaDevices.getUserMedia(constraints);
      final configuration = <String, dynamic>{
        "iceServers": [
          {"urls": "stun:stun.l.google.com:19302"}
        ]
      };

      _peerConnection =
          await createPeerConnection(configuration, <String, dynamic>{});
      localStream.getTracks().forEach((track) {
        _peerConnection.addTrack(track, localStream);
      });

      // 오디오 및 비디오 트랙 활성/비활성화
      localStream.getAudioTracks().forEach((track) {
        track.enabled = _isAudioEnabled;
      });
      localStream.getVideoTracks().forEach((track) {
        track.enabled = _isVideoEnabled;
      });

      setState(() {
        _localStream = localStream;
        _localRenderer.srcObject = localStream;
        _isInitialized = true;
      });

      // 프레임 캡처 시작
      _startFrameCapture();
    } catch (e) {
      print('Error initializing media: $e');
    }
  }

  void _startFrameCapture() {
    _captureTimer?.cancel();
    _captureTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (_localRenderer.videoWidth == 0 || _localRenderer.videoHeight == 0)
        return;

      try {
        final frameBytes = await _captureVideoFrame();
        if (frameBytes != null) {
          // SharedPreferences에서 examNumber 불러오기
          final prefs = await SharedPreferences.getInstance();
          final examNumber = prefs.getString('examNumber') ?? '20010980';

          print('Frame captured - Size: ${frameBytes.length} bytes');
          print('Frame data (first 50 bytes): ${frameBytes.take(50).toList()}');
          print('Preparing to send blob...');
          print('Room: $room');
          print('Timestamp: ${DateTime.now().millisecondsSinceEpoch}');

          socket.emit('message', {
            'blob': frameBytes,
            'candidateId': examNumber // examNumber 사용
          });

          print('Blob sent successfully at: ${DateTime.now()}');
        } else {
          print('Failed to capture frame - null frameBytes');
        }
      } catch (e) {
        print('Error capturing frame: $e');
      }
    });
  }

  Future<void> _initializeSocket() async {
    socket = IO.io(
      'http://43.203.31.163:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // Socket connection and event handling
    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joinRoom', {'room': room});
    });

    socket.on('chatMessage', (data) {
      setState(() {
        chatAreaController.text += "${data['sender']}: ${data['message']}\n";
      });
    });

    socket.on('terminate', (data) async {
      _captureTimer?.cancel();
      _localStream?.dispose();
      _peerConnection.close();
      _localRenderer.dispose();
      socket.disconnect();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ExamEndScreen()),
          (route) => false,
        );
      }
    });
    socket.onDisconnect((_) => print('Disconnected from server'));

    socket.connect();
  }

  Future<Uint8List?> _captureVideoFrame() async {
    if (_localRenderer.videoWidth == 0 || _localRenderer.videoHeight == 0) {
      print(
          'Invalid video dimensions: ${_localRenderer.videoWidth}x${_localRenderer.videoHeight}');
      return null;
    }

    try {
      final videoTrack = _localStream?.getVideoTracks().first;
      if (videoTrack == null) {
        print('No video track available');
        return null;
      }

      final frame = await videoTrack.captureFrame();

      // frame을 Uint8List로 직접 변환
      final bytes = frame.asUint8List();

      print('Successfully captured frame. Size: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      print('Error in frame capture: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _localStream?.dispose();
    _peerConnection.close();
    _localRenderer.dispose();
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 동작 비활성화
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '시험 녹화 진행중',
            style: TextStyle(color: Colors.redAccent),
          ),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1F1F1F),
          automaticallyImplyLeading: false, // AppBar의 뒤로가기 버튼 제거
        ),
        backgroundColor: const Color(0xFF121212),
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _isInitialized && _localStream != null
                        ? RTCVideoView(
                            mirror: false,
                            _localRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60),
              color: const Color(0xFF1E1E1E),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _isVideoEnabled
                            ? Colors.grey.shade800
                            : Colors.red.shade400,
                        child: IconButton(
                          icon: Icon(
                            _isVideoEnabled
                                ? Icons.videocam
                                : Icons.videocam_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final videoTrack =
                                _localStream?.getVideoTracks().first;
                            if (videoTrack != null) {
                              setState(() {
                                _isVideoEnabled = !_isVideoEnabled;
                                videoTrack.enabled = _isVideoEnabled;
                              });
                            }
                          },
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _isAudioEnabled
                            ? Colors.grey.shade800
                            : Colors.red.shade400,
                        child: IconButton(
                          icon: Icon(
                            _isAudioEnabled ? Icons.mic : Icons.mic_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final audioTrack =
                                _localStream?.getAudioTracks().first;
                            if (audioTrack != null) {
                              setState(() {
                                _isAudioEnabled = !_isAudioEnabled;
                                audioTrack.enabled = _isAudioEnabled;
                              });
                            }
                          },
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.call_end, color: Colors.white),
                          onPressed: () {
                            // Clean up resources before leaving
                            _captureTimer?.cancel();
                            _localStream?.dispose();
                            _peerConnection.close();
                            _localRenderer.dispose();
                            socket.disconnect();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ExamEndScreen()),
                              (route) => false, // 모든 이전 화면 제거
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
