import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sungoods/providers/wishlist_provider.dart';
import 'package:sungoods/models/product.dart';
import 'package:sungoods/providers/cart_provider.dart'; // Re-add CartProvider import
import 'package:intl/intl.dart';

class WishlistScreen extends StatefulWidget {
  static const routeName = '/wishlist';

  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          if (wishlistProvider.wishlistItems.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Consistent with CategoryProductsScreen
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: wishlistProvider.wishlistItems.length,
            itemBuilder: (ctx, i) {
              final product = wishlistProvider.wishlistItems[i];
              return WishlistItem(product: product);
            },
          );
        },
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  final Product product;

  const WishlistItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/product-detail', arguments: product);
      },
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrls[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, child) {
                        return IconButton(
                          icon: Icon(
                            wishlistProvider.isInWishlist(product)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            wishlistProvider.toggleWishlist(product);
                            if (!context.mounted)
                              return; // Add mounted check here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  wishlistProvider.isInWishlist(product)
                                      ? '${product.name} added to wishlist!'
                                      : '${product.name} removed from wishlist!',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_BD',
                      symbol: '৳ ',
                    ).format(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addItem(product);
                        if (!context.mounted) return; // Add mounted check here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
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
