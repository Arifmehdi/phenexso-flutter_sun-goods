import 'package:sungoods/models/product.dart';

class CartItem {
  final String? id; // Database ID from 'carts' table
  final Product product;
  int quantity;

  CartItem({this.id, required this.product, this.quantity = 1});
}
