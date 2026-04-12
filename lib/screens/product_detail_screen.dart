import 'package:flutter/material.dart';
import 'package:sungoods/models/product.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/cart_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sungoods/providers/wishlist_provider.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Color _appBarColor = Colors.transparent;
  Color _iconColor = Colors.white;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pageController.addListener(() {
      setState(() {
        _currentImageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      
      setState(() {
        _showBackToTop = offset > 300;
      });

      if (offset > 250) {
        if (_appBarColor != Colors.white) {
          setState(() {
            _appBarColor = Colors.white;
            _iconColor = Colors.black;
          });
        }
      } else {
        if (_appBarColor != Colors.transparent) {
          setState(() {
            _appBarColor = Colors.transparent;
            _iconColor = Colors.white;
          });
        }
      }
    }
  }

  Widget _buildIcon(IconData icon, VoidCallback onPressed, {int? itemCount}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _appBarColor == Colors.transparent
            ? Colors.grey.withOpacity(0.5)
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: _iconColor),
            onPressed: onPressed,
          ),
          if (itemCount != null && itemCount > 0)
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  itemCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddToCartBottomSheet(
    BuildContext context, {
    bool isBuyNow = false,
  }) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  bottomPadding + 20,
                ), // Significantly increased bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle for aesthetic
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBuyNow ? 'Buy This Item' : 'Product Options',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Summary Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.product.imageUrls[0],
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                NumberFormat.currency(
                                  locale: 'en_BD',
                                  symbol: '৳ ',
                                ).format(widget.product.price),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Available Stock: ${widget.product.stock}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 30),

                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Quantity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'How many items do you need?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: quantity > 1
                                    ? () => setModalState(() => quantity--)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: quantity > 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    setModalState(() => quantity++),
                                icon: const Icon(Icons.add_circle_outline),
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(), // Push the button to the bottom
                    // Confirmation Button at the bottom visible area
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final cart = Provider.of<CartProvider>(
                              context,
                              listen: false,
                            );
                            // Add product to cart multiple times based on quantity
                            for (int i = 0; i < quantity; i++) {
                              await cart.addItem(widget.product);
                            }

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            if (isBuyNow) {
                              Navigator.of(
                                context,
                              ).pushNamed('/shipping-address');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.product.name} added to cart!',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $error')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 2,
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isBuyNow
                              ? 'Proceed to Purchase'
                              : 'Add to Shopping Cart',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: _appBarColor,
            elevation: _appBarColor == Colors.white ? 4 : 0,
            leading: _buildIcon(
              Icons.arrow_back,
              () => Navigator.of(context).pop(),
            ),
            actions: [
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) {
                  final isFavorite = wishlist.isInWishlist(widget.product);
                  return _buildIcon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    () {
                      wishlist.toggleWishlist(widget.product);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? '${widget.product.name} removed from wishlist!'
                                : '${widget.product.name} added to wishlist!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildIcon(Icons.share, () {
                Share.share(
                  'Check out this product: ${widget.product.name} - \$${widget.product.price.toStringAsFixed(2)} '
                  'Link: https://test.musafirinternational.com/products/${widget.product.id}',
                );
              }),
              _buildIcon(Icons.shopping_cart, () {
                Navigator.of(context).pushNamed('/cart');
              }, itemCount: cart.itemCount),
              _buildIcon(Icons.search, () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.product.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.product.imageUrls.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (widget.product.imageUrls.length > 1)
                SizedBox(
                  height: 80.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: Container(
                          width: 70.0,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: _currentImageIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              width: _currentImageIndex == index ? 2.0 : 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Image.network(
                              widget.product.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 20,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_BD',
                        symbol: '৳ ',
                      ).format(widget.product.price),
                      style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          '${widget.product.rating} (${(widget.product.rating * 20).toInt()} reviews)',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category: ${widget.product.category}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Product Description:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Html(data: widget.product.description),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ]),
          ),
        ],
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    _showAddToCartBottomSheet(context, isBuyNow: true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Buy Now'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _showAddToCartBottomSheet(context, isBuyNow: false),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
