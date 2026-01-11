import 'package:pagination_with_rxdart/domain/entities/item.dart';

abstract class ItemRepository {
  /// Fetches a list of items.
  ///
  /// Returns a [List<Item>] on success. Implementations may fetch from
  /// remote or local sources.
  Future<List<Item>> fetchItems();
}
