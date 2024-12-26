import 'package:ditto/camera_screen.dart';
import 'package:ditto/check_video_chat.dart';
import 'package:ditto/identity_verification_screen.dart';
import 'package:ditto/ocr_processing_screen.dart';
import 'package:ditto/room_screen.dart';
import 'package:ditto/video_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Ditto',
      theme: ThemeData(
        fontFamily: 'Pretendard',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5FF), // 로고와 어울리는 배경색
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF3A6DFF), // 커서 색상 설정 (로고의 파란색)
          selectionColor: Color(0xFFB3D4FF), // 선택 영역 색상 (밝은 파란색)
          selectionHandleColor: Color(0xFF3A6DFF), // 선택 핸들 색상
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A6DFF), // 버튼 배경색
            foregroundColor: Colors.white, // 버튼 텍스트 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // 입력 필드 배경색
          labelStyle: TextStyle(color: Color(0xFF3A6DFF)), // 입력 필드 라벨 색상
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3A6DFF)), // 입력 필드 테두리 색상
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3A6DFF), width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      initialRoute: '/room',
      getPages: [
        GetPage(
            name: '/',
            page: () => IdentityVerificationScreen(
                  examNumber: '',
                  userName: '',
                )),
        GetPage(name: '/room', page: () => const RoomScreen()),
        GetPage(name: '/video-check', page: () => const CheckVideoChatScreen()),
        GetPage(name: '/ocr', page: () => const OCRProcessingScreen()),
        GetPage(
            name: '/video-chat',
            page: () => const VideoChatScreen(
                  isAudioEnabled: true,
                  isVideoEnabled: true,
                )),
        GetPage(
          name: '/ ',
          page: () => const CameraScreen(),
        ),
      ],
    );
  }
}
