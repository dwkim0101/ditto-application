import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exam_screen.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController roomIdController = TextEditingController();

  void login() {
    // 방 ID 입력 여부 확인 후 라우팅 처리
    if (roomIdController.text.isNotEmpty) {
      Get.to(() => ExamScreen(
            examId: roomIdController.text,
          ));
    } else {
      Get.snackbar(
        'Error',
        'Room ID cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 외부 터치 시 닫기
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212), // 다크 모드 AppBar 배경색
          elevation: 0,
        ),
        backgroundColor: const Color(0xFF121212), // 다크 모드 배경색
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        // 로고 이미지
                        Image.asset(
                          'assets/imgs/logo.png', // 로고 파일 경로 (assets 폴더에 저장)
                          width: 200,
                        ),
                        const SizedBox(height: 50),
                        // Room ID 입력 필드
                        TextField(
                          controller: roomIdController,
                          style: const TextStyle(color: Colors.white), // 텍스트 색상
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E), // 입력 필드 배경색
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            labelText: '시험 ID',
                            labelStyle: const TextStyle(
                                color: Colors.blueAccent), // 라벨 색상
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 참석 버튼 (항상 화면 아래 위치)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.blueAccent, // 버튼 배경색 (로고와 어울리는 파란색)
                  ),
                  child: const Text(
                    '참여하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
