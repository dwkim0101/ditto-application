import 'package:ditto/identity_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ExamScreen extends StatelessWidget {
  ExamScreen({super.key, required this.examId});
  late final String examId;
  final TextEditingController examNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final userData = {
    '1': '김도완',
    '2': '윤효연',
    '3': '이예람',
  };
  void submit() {
    if (examNumberController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      // 서버 요청 또는 다음 로직 처리
      print('Exam Number: ${examNumberController.text}');
      print('Password: ${passwordController.text}');
      if (examNumberController.text == '1' &&
              passwordController.text == '001230' ||
          examNumberController.text == '2' &&
              passwordController.text == '020415' ||
          examNumberController.text == '3' &&
              passwordController.text == '051217') {
        Get.to(() => IdentityVerificationScreen(
              examNumber: examNumberController.text,
              userName: userData[examNumberController.text]!,
            ));
      } else {
        Get.snackbar(
          '에러',
          '등록되지 않은 학생 정보입니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blueGrey,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        '에러',
        '계정 정보를 모두 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueGrey,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 외부를 터치하면 키보드 닫기
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // 다크 모드 배경색
        appBar: AppBar(
          title: Text('방 \'$examId\' 계정 정보 입력'),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1F1F1F), // AppBar 배경색
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 수험번호 입력 필드
              TextField(
                controller: examNumberController,
                cursorColor: const Color(0xFF3A6DFF), // 커서 색상
                style: const TextStyle(color: Colors.white), // 입력 텍스트 색상
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E), // 입력 필드 배경색
                  labelText: '계정 ID',
                  labelStyle:
                      const TextStyle(color: Color(0xFF3A6DFF)), // 라벨 텍스트 색상
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A6DFF)), // 테두리 색상
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A6DFF), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 비밀번호 입력 필드
              TextField(
                controller: passwordController,
                obscureText: true,
                cursorColor: const Color(0xFF3A6DFF), // 커서 색상
                style: const TextStyle(color: Colors.white), // 입력 텍스트 색상
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E), // 입력 필드 배경색
                  labelText: '비밀번호',
                  labelStyle:
                      const TextStyle(color: Color(0xFF3A6DFF)), // 라벨 텍스트 색상
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A6DFF)), // 테두리 색상
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF3A6DFF), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // 제출 버튼
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A6DFF), // 버튼 배경색 (로고의 파란색)
                  foregroundColor: Colors.white, // 버튼 텍스트 색상 (흰색으로 대비 강조)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // 둥근 버튼 모양 설정
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
