import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isCameraEnabled;
  final ValueChanged<bool> onCameraToggleChanged;

  SettingsPage({Key? key, required this.isCameraEnabled, required this.onCameraToggleChanged})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isCameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _isCameraEnabled = widget.isCameraEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png', // Gantikan dengan path logo anda
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'DROWY App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mengesan mengantuk, microsleep & menguap dengan amaran suara, popup & avatar animasi. Ada toggle kamera & detection untuk kawalan mudah. Kekal fokus, pandu selamat! 🚦',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Divider(
                    color: Colors.grey[400],
                    thickness: 1.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Camera/Detector',
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: _isCameraEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isCameraEnabled = value;
                          });
                          widget.onCameraToggleChanged(value);
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
