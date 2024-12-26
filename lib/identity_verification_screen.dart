import 'package:ditto/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class IdentityVerificationScreen extends StatefulWidget {
  late String examNumber;
  late String userName;
  IdentityVerificationScreen(
      {super.key, required this.examNumber, required this.userName});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  void _startCamera() {
    _btnController.reset();
    Get.to(() => const CameraScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신분증 인증'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1F1F1F), // 다크 모드 AppBar 배경색
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF121212), // 다크 모드 배경색
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SvgPicture.asset(
                    height: 300,
                    'assets/imgs/id_card.svg',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '안녕하세요 ${widget.userName}님.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white, // 텍스트 색상 (흰색)
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "시험 시작을 위해 신분증을 준비해주세요.",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white, // 텍스트 색상 (흰색)
                    ),
                  ),
                ],
              ),
              const Gap(200),
              Column(
                children: [
                  RoundedLoadingButton(
                    controller: _btnController,
                    onPressed: _startCamera,
                    successColor: const Color(0xFF3A6DFF), // 성공 시 버튼 색상 (파란색)
                    color: const Color(0xFF3A6DFF), // 버튼 기본 배경색 (로고의 파란색)
                    child: const Text(
                      "신분증 인증 시작",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ), // 버튼 텍스트 색상 (흰색)
                    ),
                  ),
                  const Gap(100),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
