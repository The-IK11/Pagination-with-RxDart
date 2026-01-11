import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pagination_with_rxdart/data/models/api_pagination_data_model.dart';

class PaginationApiService {
  PaginationApiService.internal();

  static final PaginationApiService _singleton = PaginationApiService.internal();
  factory PaginationApiService() => _singleton;

  final Dio dio = Dio();

  /// Fetches paginated products from the API
  /// 
  /// [skip] - number of products to skip (for pagination)
  /// [limit] - number of products to fetch per request
  Future<GetPaginationDataModel?> fetchPaginationData({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        "https://dummyjson.com/products",
        queryParameters: {
          'limit': limit,
          'skip': skip,
          'select': 'title,price,thumbnail,id',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(jsonEncode(response.data));
        return GetPaginationDataModel.fromJson(data);
      } else {
        log("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Exception in fetchPaginationData: $e");
      return null;
    }
  }
}
