import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:ditto/ocr_processing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay_new/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay_new/model.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;
  bool isUploading = false; // 업로드 상태를 나타내는 변수
  double uploadProgress = 0.0; // 업로드 진행률

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // CameraController 생성 및 초기화
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
        );
        await _cameraController.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      } else {
        throw Exception("No cameras available");
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      Get.snackbar('Error', 'Failed to initialize camera',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  Future<void> uploadToServer(File file) async {
    try {
      setState(() {
        isUploading = true; // 업로드 시작 시 로딩 상태 활성화
        uploadProgress = 0.0; // 진행률 초기화
      });

      Dio dio = Dio();

      // FormData 생성
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path,
            filename: "captured_id.jpg"),
      });

      // 서버 요청
      Response response = await dio.post(
        "https://your-server-endpoint.com/upload",
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
        ),
        onSendProgress: (int sent, int total) {
          setState(() {
            uploadProgress = sent / total; // 진행률 계산
          });
          debugPrint(
              "Progress: $sent / $total (${(uploadProgress * 100).toStringAsFixed(1)}%)");
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'ID card uploaded successfully!',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
      } else {
        Get.snackbar('Error', 'Failed to upload ID card.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OCRProcessingScreen()),
        (route) => route.settings.name == '/room', // '/room' 경로까지 스택 유지
      );
      debugPrint('Upload error: $e');
      // Get.snackbar('Error', e.toString(),
      //     snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      setState(() {
        isUploading = false; // 업로드 완료 후 로딩 상태 비활성화
        uploadProgress = 0.0; // 진행률 초기화
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신분증 촬영'),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1F1F1F),
      ),
      backgroundColor: const Color(0xFF1F1F1F),
      body: isCameraInitialized
          ? Stack(
              children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;

                      // 카메라의 실제 비율 계산
                      const double cameraAspectRatio = 0.7;

                      return OverflowBox(
                        maxHeight:
                            size.width / cameraAspectRatio, // 카메라 비율에 맞게 높이 조정
                        maxWidth: size.width, // 화면 너비에 맞춤
                        child: CameraOverlay(
                          cameras.first,
                          CardOverlay.byFormat(OverlayFormat.cardID1),
                          (XFile file) async {
                            // 저장 경로 지정
                            final Directory directory =
                                await getApplicationDocumentsDirectory();
                            final String filePath =
                                '${directory.path}/captured_id.jpg';

                            // 파일 저장
                            final savedFile =
                                await File(file.path).copy(filePath);

                            // 서버 업로드 호출
                            await uploadToServer(savedFile);
                          },
                          info: '신분증을 중앙에 위치시키고, 빛에 비치지 않도록 주의해주세요.',
                          label: '신분증 촬영',
                        ),
                      );
                    },
                  ),
                ),
                if (isUploading)
                  Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Uploading... ${(uploadProgress * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }
}
