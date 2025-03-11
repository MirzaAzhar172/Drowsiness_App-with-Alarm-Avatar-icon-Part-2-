import 'package:url_launcher/url_launcher.dart';

class Article {
  final String title;
  final String link;
  final String description;

  Article({
    required this.title,
    required this.link,
    required this.description,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      link: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Future<void> launchURL() async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $link';
    }
  }
}
