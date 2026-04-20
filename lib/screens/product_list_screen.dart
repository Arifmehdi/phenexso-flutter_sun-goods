import 'package:flutter/material.dart';
import 'package:sungoods/models/product.dart';
import 'package:intl/intl.dart';
import 'package:sungoods/widgets/custom_app_bar.dart';
import 'package:sungoods/utils/colors.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart';
import 'package:sungoods/providers/product_provider.dart'; // Import ProductProvider
import 'package:sungoods/providers/category_provider.dart'; // Import CategoryProvider
import 'package:cached_network_image/cached_network_image.dart';
// Import UserRole enum

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  const ProductListScreen({super.key, this.categorySlug});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController
  bool _showBackToTop = false; // Add state for FAB visibility

  // For auto-sliding image carousel
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'assets/images/slider/fruit.png',
    'assets/images/slider/fresh.png',
    'assets/images/slider/dairy.png',
    'assets/images/slider/supply_chain_1.png',
    'assets/images/slider/supply_chain_2.png',
  ];

  List<Map<String, dynamic>> get _menuItems {
    return [
      {
        'title': 'All Category',
        'icon': Icons.category,
        'onTap': () => Navigator.of(context).pushNamed('/all-categories'),
      },
      {
        'title': 'RFQ',
        'icon': Icons.assignment,
        'onTap': () => print('RFQ tapped'),
      },
      {
        'title': 'Order Tracking',
        'icon': Icons.track_changes,
        'onTap': () => Navigator.of(context).pushNamed('/order-tracking'),
      },
      {
        'title': 'Cost Calculator',
        'icon': Icons.calculate,
        'onTap': () => Navigator.of(context).pushNamed('/cost-calculator'),
      },
      {
        'title': 'Wishlist',
        'icon': Icons.favorite_border,
        'onTap': () => Navigator.of(context).pushNamed('/wishlist'),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll); // Add scroll listener

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear(); // Clear search controller on init
      _fetchInitialProducts();

      _pageController.addListener(() {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      });

      _startAutoSlide();
      _searchController.addListener(_filterProducts);
    });
  }

  void _fetchInitialProducts() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    if (widget.categorySlug != null) {
      productProvider.resetProducts();
      productProvider.fetchProducts(
        categorySlug: widget.categorySlug,
        clearProducts: true,
      );
    } else {
      // Home page: Always fetch all products to ensure we clear any category filter
      productProvider.resetProducts();
      productProvider.fetchProducts(clearProducts: true);
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        // Check if controller is attached
        if (_currentPage < _sliderImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _pauseAutoSlide() {
    _timer.cancel();
  }

  void _resumeAutoSlide() {
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        searchController: _searchController,
        onSearch: _filterProducts,
        showDrawerButton: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${productProvider.errorMessage}'),
            );
          }

          final products = productProvider.products;

          // Compute filtered products (only by search query)
          final currentFilteredProducts = products.where((product) {
            final matchesSearch =
                _searchController.text.isEmpty ||
                product.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
            return matchesSearch; // Only search filter applies locally
          }).toList();

          return SingleChildScrollView(
            controller: _scrollController, // Attach the scroll controller
            child: Column(
              children: [
                if (_searchController.text.isEmpty) ...[
                  // Image Slider/Carousel
                  Stack(
                    children: [
                      GestureDetector(
                        onPanDown: (_) => _pauseAutoSlide(),
                        onPanEnd: (_) => _resumeAutoSlide(),
                        onPanCancel: () => _resumeAutoSlide(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: SizedBox(
                              height: 180.0,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _sliderImages.length,
                                itemBuilder: (context, index) {
                                  return Image.asset(
                                    _sliderImages[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 18.0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildPageIndicator(),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            _menuItems
                                .expand(
                                  (item) => [
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 60.0,
                                          height: 60.0,
                                          child: Card(
                                            elevation: 2.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8.0,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: item['onTap'],
                                              borderRadius: BorderRadius.circular(
                                                8.0,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  item['icon'],
                                                  size: 28.0,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        SizedBox(
                                          width: 60.0,
                                          height: 28.0,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0,
                                            ),
                                            child: Text(
                                              item['title'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8.0),
                                  ],
                                )
                                .toList()
                              ..removeLast(),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Image.asset(
                      'assets/images/shop_ad.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 70.0,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Deals for you',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/featured-products');
                              },
                              child: const Row(
                                children: [
                                  Text('View All', style: TextStyle(fontSize: 12)),
                                  Icon(Icons.arrow_forward_ios, size: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Builder(
                          builder: (context) {
                            final featuredProducts = products.where((p) => p.featured == 1).take(10).toList();
                            
                            if (featuredProducts.isEmpty) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'No deals available now',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              );
                            }

                            return SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = featuredProducts[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: SizedBox(
                                      width: 150,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            '/product-detail',
                                            arguments: product,
                                          );
                                        },
                                        child: Card(
                                          elevation: 1.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(
                                                    top: Radius.circular(12.0),
                                                  ),
                                                  child: _buildProductImage(
                                                    product.imageUrls,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 13.0,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    Text(
                                                      '৳ ${NumberFormat.currency(locale: 'en_BD', symbol: '').format(product.price)}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0,
                                                        color: appColorsPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Text(
                        _searchController.text.isEmpty ? 'All Products' : 'Search Results',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: currentFilteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = currentFilteredProducts[index];
                    return ProductGridItem(product: product);
                  },
                ),
                if (productProvider
                    .isFetchingMore) // Loading indicator for fetching more
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              mini: true,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      drawer: _buildCategoryDrawer(context),
    );
  }

  Widget _buildCategoryDrawer(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.categories.isEmpty) {
      categoryProvider.fetchCategories();
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  if (categoryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (categoryProvider.errorMessage != null) {
                    return Center(
                      child: Text('Error: ${categoryProvider.errorMessage}'),
                    );
                  }

                  if (categoryProvider.categories.isEmpty) {
                    return const Center(child: Text('No categories available'));
                  }

                  return ListView.builder(
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return ListTile(
                        leading: category.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  category.imageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.category),
                                ),
                              )
                            : const Icon(Icons.category),
                        title: Text(category.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                            '/category-products',
                            arguments: {'slug': category.slug, 'name': category.name},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterProducts() {
    setState(() {
      // Rebuild will trigger the filtering logic in the build method.
    });
  }

  void _onScroll() {
    setState(() {
      _showBackToTop = _scrollController.offset > 300;
    });

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has scrolled to the bottom, fetch more products
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (!productProvider.isLoading &&
          !productProvider.isFetchingMore &&
          productProvider.hasMore) {
        productProvider.fetchNextPage(categorySlug: widget.categorySlug);
      }
    }
  }

  Widget _buildProductImage(List<String> imageUrls) {
    if (imageUrls.first.startsWith('assets/')) {
      return Image.asset(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50),
              Text('Failed to load image'),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _sliderImages.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[400],
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  Widget _buildProductImage(List<String> imageUrls) {
    if (imageUrls.first.startsWith('assets/')) {
      return Image.asset(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50),
              Text('Failed to load image'),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/product-detail', arguments: product);
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
                child: _buildProductImage(product.imageUrls),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_BD',
                      symbol: '৳ ',
                    ).format(product.price),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${product.rating}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
