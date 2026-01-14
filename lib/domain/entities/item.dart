class Item {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
  });
}
