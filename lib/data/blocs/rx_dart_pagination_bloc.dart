import 'package:rxdart/rxdart.dart';
import 'package:pagination_with_rxdart/domain/entities/item.dart';
import 'package:pagination_with_rxdart/data/datasources/pagination_api_service.dart';

class RxDartPaginationBloc {
  final PaginationApiService _apiService = PaginationApiService();

  // Input Subjects
  final BehaviorSubject<int> _pageSubject = BehaviorSubject<int>.seeded(0);
  final PublishSubject<void> _loadMoreSubject = PublishSubject<void>();

  // Output Streams
  late final Stream<PaginationState> paginationStream;

  int _currentPage = 0;
  int _pageSize = 10;
  List<Item> _allItems = [];

  RxDartPaginationBloc() {
    // Initialize the pagination stream
    paginationStream = Rx.combineLatest2(
      _pageSubject.stream,
      _loadMoreSubject.stream.startWith(null),
      (page, _) => page,
    ).switchMap((page) => _fetchItems(page));

    // Listen to load more requests
    _loadMoreSubject.listen((_) {
      _currentPage++;
      _pageSubject.add(_currentPage);
    });
  }

  /// Fetch items from API and return PaginationState
  Stream<PaginationState> _fetchItems(int page) async* {
    try {
      // Show loading on first page, loading more on subsequent pages
      yield PaginationState.loading(
        items: _allItems,
        isLoadingMore: page > 0,
      );

      final skip = page * _pageSize;
      final result = await _apiService.fetchPaginationData(
        skip: skip,
        limit: _pageSize,
      );

      if (result != null && result.products != null) {
        final newItems = result.products!
            .map((p) => Item(
                  id: p.id ?? 0,
                  title: p.title ?? 'No Title',
                  description: 'Price: \$${p.price ?? 0}',
                  thumbnail: p.thumbnail,
                ))
            .toList();

        _allItems.addAll(newItems);

        final hasMore =
            (_currentPage + 1) * _pageSize < (result.total ?? 0);

        yield PaginationState.success(
          items: _allItems,
          hasMore: hasMore,
          total: result.total ?? 0,
        );
      } else {
        yield PaginationState.success(
          items: _allItems,
          hasMore: false,
          total: _allItems.length,
        );
      }
    } catch (e) {
      yield PaginationState.error(
        items: _allItems,
        message: 'Failed to load items: $e',
      );
    }
  }

  /// Load more items
  void loadMore() {
    _loadMoreSubject.add(null);
  }

  /// Reset pagination
  void reset() {
    _currentPage = 0;
    _allItems = [];
    _pageSubject.add(_currentPage);
  }

  /// Dispose streams
  void dispose() {
    _pageSubject.close();
    _loadMoreSubject.close();
  }
}

/// Pagination State Model
class PaginationState {
  final List<Item> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int total;

  PaginationState({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    required this.total,
  });

  bool get hasError => error != null;

  /// Success state
  factory PaginationState.success({
    required List<Item> items,
    required bool hasMore,
    required int total,
  }) {
    return PaginationState(
      items: items,
      isLoading: false,
      isLoadingMore: false,
      hasMore: hasMore,
      error: null,
      total: total,
    );
  }

  /// Loading state
  factory PaginationState.loading({
    required List<Item> items,
    required bool isLoadingMore,
  }) {
    return PaginationState(
      items: items,
      isLoading: !isLoadingMore,
      isLoadingMore: isLoadingMore,
      hasMore: true,
      error: null,
      total: items.length,
    );
  }

  /// Error state
  factory PaginationState.error({
    required List<Item> items,
    required String message,
  }) {
    return PaginationState(
      items: items,
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      error: message,
      total: items.length,
    );
  }
}
