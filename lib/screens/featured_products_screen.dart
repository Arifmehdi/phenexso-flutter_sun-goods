import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/user_role.dart';

class FeaturedProductsScreen extends StatefulWidget {
  static const routeName = '/featured-products';

  const FeaturedProductsScreen({super.key});

  @override
  State<FeaturedProductsScreen> createState() => _FeaturedProductsScreenState();
}

class _FeaturedProductsScreenState extends State<FeaturedProductsScreen> {
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Fetch products if list is empty
    Future.microtask(() {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (provider.products.isEmpty) {
        provider.fetchProducts(clearProducts: true);
      }
    });

    _scrollController.addListener(() {
      setState(() {
        _showBackToTop = _scrollController.offset > 300;
      });

      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        final productProvider = Provider.of<ProductProvider>(context, listen: false);
        if (productProvider.hasMore && !productProvider.isFetchingMore) {
          productProvider.fetchNextPage();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart');
        break;
      case 4:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/account');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Featured Deals',
        searchController: _searchController,
        onSearch: () => setState(() {}),
        showBackButton: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final featuredProducts = productProvider.products.where((p) {
            final isFeatured = p.featured == 1;
            final matchesSearch = _searchController.text.isEmpty || 
                                 p.name.toLowerCase().contains(_searchController.text.toLowerCase());
            return isFeatured && matchesSearch;
          }).toList();

          if (featuredProducts.isEmpty) {
            return const Center(
              child: Text('No featured products available at the moment.'),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: featuredProducts.length + (productProvider.isFetchingMore ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == featuredProducts.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final product = featuredProducts[i];
              return _FeaturedProductItem(product: product);
            },
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'RFQ'),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) => Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(cart.itemCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Shipping'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _FeaturedProductItem extends StatelessWidget {
  final Product product;
  const _FeaturedProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product-detail', arguments: product),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(product.imageUrls[0], fit: BoxFit.cover, width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(NumberFormat.currency(locale: 'en_BD', symbol: '৳ ').format(product.price),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12))]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
