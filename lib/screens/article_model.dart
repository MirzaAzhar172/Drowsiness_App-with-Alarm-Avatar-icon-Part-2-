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
}
