// Webcam helper untuk MOBILE (menggunakan camera package)
import 'dart:typed_data';
import 'package:camera/camera.dart';

class WebCamera {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No camera available');
    }

    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
  }

  // Switch between front and back camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('No other camera available');
    }

    // Toggle camera index
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;

    // Dispose old controller
    await _controller?.dispose();

    // Initialize new camera
    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
  }

  Future<Uint8List> capture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    final image = await _controller!.takePicture();
    return await image.readAsBytes();
  }

  void dispose() {
    _controller?.dispose();
  }

  CameraController? get controller => _controller;
  
  // Check if device has multiple cameras
  bool get hasMultipleCameras => _cameras != null && _cameras!.length > 1;
}
