import 'package:pagination_with_rxdart/domain/entities/item.dart';

class ItemModel extends Item {
  const ItemModel({required int id, required String title, required String description})
      : super(id: id, title: title, description: description);

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
