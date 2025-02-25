import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../utils/alarm_service.dart';

class DrowsinessDetector {
  final FaceDetector _faceDetector;
  final AlarmService _alarmService = AlarmService();

  int _consecutiveFramesWithClosedEyes = 0;
  final int _drowsinessThreshold = 10;
  bool _isDrowsy = false;

  int _consecutiveFramesWithYawn = 0;
  final int _yawnThreshold = 5;
  bool _isYawning = false;

  final double _yawnAspectRatioThreshold = 0.4; // Dikurangkan dari 0.5 ke 0.4
  final int _stableFramesRequired = 2; // Dikurangkan dari 4 ke 2

  double _maxMouthOpening = 0.0;
  bool _calibrationComplete = false;
  int _calibrationFrames = 0;
  final int _requiredCalibrationFrames = 20;

  List<double> _recentAspectRatios = [];
  double _baselineAspectRatio = 0.0;
  bool _baselineEstablished = false;
  int _stableFrames = 0;

  Rect? _faceBoundingBox;

  DrowsinessDetector()
      : _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<Map<String, dynamic>> processCameraImage(InputImage inputImage) async {
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      _alarmService.stopAlarm();
      return {'drowsy': false, 'yawning': false, 'faceBoundingBox': null};
    }

    final face = faces.first;
    _detectDrowsiness(face);
    _detectYawn(face);

    _faceBoundingBox = face.boundingBox;

    if (_isDrowsy || _isYawning) {
      _alarmService.playAlarm();
    } else {
      _alarmService.stopAlarm();
    }

    return {
      'drowsy': _isDrowsy,
      'yawning': _isYawning,
      'faceBoundingBox': _faceBoundingBox,
    };
  }

  void _detectDrowsiness(Face face) {
    if (face.leftEyeOpenProbability != null &&
        face.rightEyeOpenProbability != null) {
      bool eyesClosed = face.leftEyeOpenProbability! < 0.2 &&
          face.rightEyeOpenProbability! < 0.2;

      if (eyesClosed) {
        _consecutiveFramesWithClosedEyes++;
      } else {
        _consecutiveFramesWithClosedEyes = 0;
      }

      _isDrowsy = _consecutiveFramesWithClosedEyes >= _drowsinessThreshold;
    }
  }

  void _detectYawn(Face face) {
    final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;

    if (bottomMouth == null || leftMouth == null || rightMouth == null) {
      return;
    }

    double mouthWidth = (rightMouth.x - leftMouth.x).toDouble().abs();
    double mouthHeight =
    (bottomMouth.y - ((leftMouth.y + rightMouth.y) / 2)).toDouble().abs();

    if (mouthWidth < 1.0) mouthWidth = 1.0;

    double aspectRatio = mouthHeight / mouthWidth;

    _recentAspectRatios.add(aspectRatio);
    if (_recentAspectRatios.length > 10) {
      _recentAspectRatios.removeAt(0);
    }

    if (!_calibrationComplete) {
      _calibrationFrames++;

      if (_baselineEstablished) {
        _baselineAspectRatio =
            (_baselineAspectRatio * 0.9) + (aspectRatio * 0.1);
      } else if (_recentAspectRatios.length >= 3) {
        _baselineAspectRatio = _recentAspectRatios.reduce((a, b) => a + b) /
            _recentAspectRatios.length;
        _baselineEstablished = true;
      }

      _maxMouthOpening = max(_maxMouthOpening, aspectRatio);

      if (_calibrationFrames >= _requiredCalibrationFrames) {
        _calibrationComplete = true;
      }

      return;
    }

    double yawnThreshold = max(_yawnAspectRatioThreshold, _baselineAspectRatio * 1.3); // Turunkan dari 1.5 ke 1.3

    bool isLikelyYawning =
        aspectRatio > yawnThreshold || (aspectRatio > _baselineAspectRatio * 1.4); // Turun dari 1.6 ke 1.4

    if (isLikelyYawning) {
      _stableFrames++;
      if (_stableFrames >= _stableFramesRequired) { // Guna 2 frame je
        _consecutiveFramesWithYawn++;
      }
    } else {
      _stableFrames = max(0, _stableFrames - 1);
      _consecutiveFramesWithYawn = max(0, _consecutiveFramesWithYawn - 1);
    }

    _isYawning = _consecutiveFramesWithYawn >= _yawnThreshold;
  }

  void dispose() {
    _faceDetector.close();
  }
}
