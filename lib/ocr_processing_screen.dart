import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:ditto/check_video_chat.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OCRProcessingScreen extends StatefulWidget {
  const OCRProcessingScreen({super.key});

  @override
  _OCRProcessingScreenState createState() => _OCRProcessingScreenState();
}

class _OCRProcessingScreenState extends State<OCRProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // 5초 후에 라우팅
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const ResultScreen()), // 결과 화면으로 이동
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212), // 어두운 테마 유지
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 애니메이션 표시 (로딩 스피너)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 6.0,
            ),
            SizedBox(height: 20),
            // 상태 메시지
            Text(
              '신분증 처리 중입니다...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // ConfettiController 초기화 (3초 동안 실행)
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play(); // 빵빠래 애니메이션 시작

    // 1초 후 다음 화면으로 이동
    Timer(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CheckVideoChatScreen()),
        (route) => route.settings.name == '/room', // '/room' 경로까지 스택 유지
      );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose(); // 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('OCR 결과'),
      //   backgroundColor: const Color(0xFF1F1F1F),
      // ),
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Confetti 애니메이션 위젯
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // 모든 방향으로 발사
              shouldLoop: false, // 반복 여부 설정
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow
              ], // 색상 설정
              numberOfParticles: 20, // 입자 수 설정
              gravity: 0.5, // 중력 설정 (낮을수록 천천히 떨어짐)
            ),
            // 축하 메시지 표시
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '축하합니다!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  '신분 확인이 완료되었습니다!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
