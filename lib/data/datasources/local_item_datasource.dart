import 'dart:async';

import 'package:pagination_with_rxdart/data/models/item_model.dart';

/// Simple local datasource returning a small hard-coded list of items.
class LocalItemDatasource {
  Future<List<ItemModel>> getItems() async {
    // simulate a short delay as if reading from disk / network
    await Future.delayed(const Duration(milliseconds: 250));

    final raw = [
      {'id': 1, 'title': 'Apples', 'description': 'Fresh red apples.'},
      {'id': 2, 'title': 'Bananas', 'description': 'Ripe yellow bananas.'},
      {'id': 3, 'title': 'Cherries', 'description': 'Sweet cherries.'},
      {'id': 4, 'title': 'Dates', 'description': 'Dried dates.'},
      {'id': 5, 'title': 'Elderberries', 'description': 'Tart elderberries.'},
      {'id': 6, 'title': 'Figs', 'description': 'Delicious figs.'},
    ];

    return raw.map((m) => ItemModel.fromJson(m)).toList(growable: false);
  }
}
