import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AnnouncementPage extends StatefulWidget {
  final List<String> notifications;

  AnnouncementPage({Key? key, required this.notifications}) : super(key: key);

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  String _location = 'Mencari Lokasi...';
  String _weather = 'Mencari Cuaca...';
  List<String> _notifications = [];

  @override
  void initState() {
    super.initState();
    _getLocationFromIP();
    _notifications = List.from(widget.notifications);
  }

  Future<void> _getLocationFromIP() async {
    final apiKey = 'DDF5FEF20B1452E68586E8BFEC891019'; // API Key IP2Location.io
    final url = Uri.parse('https://api.ip2location.io/?key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _location =
          '${data['city_name']}, ${data['region_name']}, ${data['country_name']}';
        });
      } else {
        setState(() {
          _location = 'Gagal mendapatkan lokasi.';
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Ralat mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _getWeather(double latitude, double longitude) async {
    final apiKey = '521dfa37ebc97ef1980032866e5cd8b5'; // API Key OpenWeatherMap
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weather =
          'Cuaca: ${data['weather'][0]['description']}, Suhu: ${data['main']['temp']}°C';
        });
      } else {
        setState(() {
          _weather = 'Gagal mendapatkan cuaca.';
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'Ralat mendapatkan cuaca: $e';
      });
    }
  }

  void _clearNotifications() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Notifications'),
        content: Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      setState(() {
        _notifications.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcement'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Text(
                  'Cuaca & Lokasi:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '${_location.split(',').first} / ${_weather.split('Suhu: ').last}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Spasi antara container
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifikasi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _clearNotifications,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(fontSize: 12),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                for (var notification in _notifications)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(notification)),
                        Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
