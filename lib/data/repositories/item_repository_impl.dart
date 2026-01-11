import 'package:pagination_with_rxdart/data/datasources/local_item_datasource.dart';
import 'package:pagination_with_rxdart/domain/entities/item.dart';
import 'package:pagination_with_rxdart/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final LocalItemDatasource datasource;

  ItemRepositoryImpl(this.datasource);

  @override
  Future<List<Item>> fetchItems() async {
    // simply delegate to the datasource in this simple example
    final models = await datasource.getItems();
    return models;
  }
}
