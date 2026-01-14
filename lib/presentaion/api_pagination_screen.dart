import 'package:flutter/material.dart';
import 'package:pagination_with_rxdart/domain/entities/item.dart';
import 'package:pagination_with_rxdart/data/datasources/pagination_api_service.dart';
import 'package:pagination_with_rxdart/presentaion/widgets/custom_loading_indicator.dart';

class ApiPaginationScreen extends StatefulWidget {
  const ApiPaginationScreen({super.key});

  @override
  State<ApiPaginationScreen> createState() => _ApiPaginationScreenState();
}

class _ApiPaginationScreenState extends State<ApiPaginationScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
final PaginationApiService _apiService = PaginationApiService();

  // Pagination variables
  int _currentSkip = 0;
  int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;

  // Animation variables
  late AnimationController _scrollAnimationController;
  List<AnimationController> _itemAnimationControllers = [];

  // List to hold items (domain entity)
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadInitialItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollAnimationController.dispose();
    // Only dispose remaining controllers
    for (var controller in _itemAnimationControllers) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint('Error disposing controller: $e');
      }
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _fetchMoreItems();
      }
    }
  }

  Future<void> _loadInitialItems() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.fetchPaginationData(
        skip: _currentSkip,
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

        setState(() {
          items = newItems;
          _currentSkip += _pageSize;
          _createItemAnimations(items.length);
        });

        // Start animations
        for (var i = 0; i < _itemAnimationControllers.length; i++) {
          Future.delayed(Duration(milliseconds: i * 100), () {
            if (mounted && _itemAnimationControllers[i].isCompleted == false) {
              _itemAnimationControllers[i].forward();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load initial items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMoreItems() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.fetchPaginationData(
        skip: _currentSkip,
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

        final oldLength = items.length;
        setState(() {
          items.addAll(newItems);
          _currentSkip += _pageSize;
          _createItemAnimations(items.length);
        });

        // Start animations for new items only
        for (var i = oldLength; i < _itemAnimationControllers.length; i++) {
          Future.delayed(Duration(milliseconds: (i - oldLength) * 100), () {
            if (mounted && _itemAnimationControllers[i].isCompleted == false) {
              _itemAnimationControllers[i].forward();
            }
          });
        }

        // Check if there are more items to load
        if (result.products!.isEmpty || _currentSkip >= (result.total ?? 0)) {
          _hasMore = false;
        }
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      debugPrint('Failed to fetch more items: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createItemAnimations(int itemCount) {
    // Only create animations for NEW items
    // Keep existing animations for old items (they're already completed)
    final existingCount = _itemAnimationControllers.length;
    
    for (int i = existingCount; i < itemCount; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _itemAnimationControllers.add(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Premium Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading && items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomLoadingIndicator(
                      size: 80.0,
                      primaryColor: Colors.green,
                      secondaryColor: Colors.greenAccent,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading premium items...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: items.length + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // Show custom loading indicator as the last item
                  if (index == items.length) {
                    return _buildLoadingFooter();
                  }

                  if (index < _itemAnimationControllers.length) {
               return _buildAnimatedItemCard(index);
                  }

                  return _buildItemCard(items[index]);
                },
              ),
      ),
    );
  }

  Widget _buildAnimatedItemCard(int index) {
    final animation = _itemAnimationControllers[index];
    final item = items[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * 30),
          child: Opacity(
            opacity: animation.value,
            child: Transform.scale(
              scale: 0.95 + (animation.value * 0.05),
              child: _buildItemCard(item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(Item item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showProductDetails(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product thumbnail image
                if (item.thumbnail != null && item.thumbnail!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                      child: Image.network(
                        item.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                              size: 48,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (item.thumbnail != null && item.thumbnail!.isNotEmpty)
                  const SizedBox(height: 12),
                // Header with ID badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ID: ${item.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.favorite_border,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Product title
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Product description (price)
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 16,
                      color: Colors.green[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Rating and action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingFooter() {
    return _hasMore
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const CustomLoadingIndicator(
                  size: 60.0,
                  primaryColor: Colors.green,
                  secondaryColor: Colors.greenAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading more products...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No more products to load',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'ve reached the end',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
  }

  void _showProductDetails(Item item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Product ID', item.id.toString()),
            _buildDetailRow('Title', item.title),
            _buildDetailRow('Details', item.description),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.greenAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Add to Cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
