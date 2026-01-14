//import 'package:rxdart/rxdart.dart';

import 'package:pagination_with_rxdart/data/datasources/pagination_api_service.dart';
import 'package:rxdart/rxdart.dart';

class RxDartDataSource {

 RxDartDataSource._internal();
  static final RxDartDataSource _singleton = RxDartDataSource._internal();
  factory RxDartDataSource() => _singleton;
  final  paginationService=PaginationApiService();

  BehaviorSubject<Map> response= BehaviorSubject<Map>();
  ValueStream get getBannersImgeData => response.stream;
  // Example method to demonstrate usage of RxDart
  void fetchData(int skip, int limit) async {
    final data = await paginationService.fetchPaginationData(skip: skip, limit: limit);
    if (data != null) {
      response.sink.add(data.toJson());
    } else {
      response.sink.addError('Failed to fetch data');
    }
  }

  void dispose() {
    response.close();
  }
}