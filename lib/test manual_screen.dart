import 'package:evo/pages/home_page.dart'; // Import HomePage (Guna path yang betul!)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'settings_page.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
      imageUrl: 'assets/face_recognition.png',
      title: 'Adjust Position',
      description:
      'Position the camera so your face is clearly visible for detection.'),
  Slide(
      imageUrl: 'assets/phone_interface.png',
      title: 'Friendly Interface',
      description:
      'A simple and easy to use interface. Suitable for users of all ages.'),
  Slide(
      imageUrl: 'assets/avatar_support.png',
      title: 'Language Avatars',
      description:
      'Each Avatar represent a language. Select your preferred one for a personalized experience.'),
  Slide(
      imageUrl: 'assets/enable_toggle.png', // Gantikan dengan imej yang sesuai
      title: 'Detector Permissions',
      description: 'Enable camera access and detection in settings.'),
  Slide(
      imageUrl: 'assets/get_started.png',
      title: 'Get Started Today',
      description: 'Press the button below to start detection.'),
];

class ManualGuideScreen extends StatefulWidget {
  @override
  _ManualGuideScreenState createState() => _ManualGuideScreenState();
}

class _ManualGuideScreenState extends State<ManualGuideScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool _isCameraEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadCameraEnabledState();
  }

  Future<void> _loadCameraEnabledState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCameraEnabled = prefs.getBool('isCameraEnabled') ?? false;
    });
  }

  Future<void> _saveCameraEnabledState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCameraEnabled', value);
    setState(() {
      _isCameraEnabled = value;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < slideList.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: slideList.length,
                  itemBuilder: (ctx, i) => SlideItem(i),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
              SizedBox(height: 30),
              // Tambah kod ini di sini untuk slider ke-4
              if (_currentPage == 3)
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            isCameraEnabled: _isCameraEnabled,
                            onCameraToggleChanged: (value) {
                              _saveCameraEnabledState(value);
                            },
                            onBackToCamera: () {
                              // Anda boleh kekalkan kod ini jika perlu kembali ke CameraScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraScreen(
                                    avatar: 'default_avatar',
                                    code: 'en-US',
                                    language: 'English',
                                    voice: 'en-US-JennyNeural',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Go to Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              if (_currentPage == slideList.length - 1)
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('manualGuideShown', true);
                      // Dapatkan nilai untuk avatar, code, language, dan voice
                      String avatar =
                          prefs.getString('avatar') ?? 'default_avatar'; // Gantikan 'default_avatar' dengan nilai lalai
                      String code =
                          prefs.getString('code') ?? 'en-US'; // Gantikan 'en-US' dengan nilai lalai
                      String language = prefs.getString('language') ??
                          'English'; // Gantikan 'English' dengan nilai lalai
                      String voice = prefs.getString('voice') ??
                          'en-US-JennyNeural'; // Gantikan 'en-US-JennyNeural' dengan nilai lalai
                      // Push HomePage dulu! (PENTING!)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Homepage()), // Pastikan Homepage diimport dengan betul
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(
                            avatar: avatar,
                            code: code,
                            language: language,
                            voice: voice,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Back to Camera Screen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
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

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: AssetImage(slideList[index].imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          slideList[index].title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          slideList[index].description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
