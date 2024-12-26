import 'dart:async';
import 'package:ditto/video_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';

class CheckVideoChatScreen extends StatefulWidget {
  const CheckVideoChatScreen({super.key});

  @override
  State<CheckVideoChatScreen> createState() => _CheckVideoChatScreenState();
}

class _CheckVideoChatScreenState extends State<CheckVideoChatScreen> {
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  late RTCVideoRenderer _localRenderer;
  MediaStream? _localStream;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    try {
      await _localRenderer.initialize();

      final Map<String, dynamic> constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        }
      };

      final localStream =
          await navigator.mediaDevices.getUserMedia(constraints);

      setState(() {
        _localStream = localStream;
        _localRenderer.srcObject = localStream;
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing media: $e');
    }
  }

  void _toggleCamera() {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
        videoTrack.enabled = _isVideoEnabled;
      });
    }
  }

  void _toggleMicrophone() {
    final audioTrack = _localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      setState(() {
        _isAudioEnabled = !_isAudioEnabled;
        audioTrack.enabled = _isAudioEnabled;
      });
    }
  }

  void _joinMeeting() {
    if (_isInitialized && _localStream != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => VideoChatScreen(
                  isAudioEnabled: _isAudioEnabled,
                  isVideoEnabled: _isVideoEnabled,
                )),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Please ensure your camera and microphone are enabled.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시험 참여'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isInitialized && _localStream != null
                  ? RTCVideoView(
                      mirror: false,
                      _localRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            color: const Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _isVideoEnabled
                      ? Colors.grey.shade800
                      : Colors.red.shade400,
                  child: IconButton(
                    icon: Icon(
                      _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleCamera,
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
                    onPressed: _toggleMicrophone,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _joinMeeting,
                  icon: const Icon(
                    Icons.video_call,
                    color: Colors.white,
                    size: 30,
                    weight: 2.0,
                  ),
                  label: const Text('시험 시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
          const Gap(30),
        ],
      ),
    );
  }
}
