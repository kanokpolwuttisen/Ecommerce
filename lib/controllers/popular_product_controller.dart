import 'package:ecommerce/controllers/cart_controller.dart';
import 'package:ecommerce/data/repository/popular_product_repo.dart';
import 'package:ecommerce/models/products_model.dart';
import 'package:ecommerce/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cart_model.dart';

class PopularProductController extends GetxController {
  final PopularProductRepo popularProductRepo;
  PopularProductController({required this.popularProductRepo});
  List<ProductsModel> _popularProductList = [];
  List<ProductsModel> get popularProductList => _popularProductList;
  late CartController _cart;
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  bool _addEnough = true;
  bool get addEnough => _addEnough;
  bool _reduceEnough = true;
  bool get reduceEnough => _reduceEnough;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItem = 0;
  int get inCartItem => _inCartItem + _quantity;

  Future<void> getPopularProductList() async {
    Response response = await popularProductRepo.getPopularProductList();
    if (response.statusCode == 200) {
      // print("got products");
      _popularProductList = [];
      _popularProductList.addAll(Product.fromJson(response.body).products);
      // print(_popularProductList);
      _isLoaded = true;
      update();
    } else {
      print("can't get products");
    }
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = checkQuantity(_quantity + 1);
      print("number of items " + _quantity.toString());
    } else {
      _quantity = checkQuantity(_quantity - 1);
      print("decrement " + _quantity.toString());
    }
    update();
  }

  int checkQuantity(int quantity) {
    if ((_inCartItem + quantity) < 0) {
      // _reduceEnough = false;
      Get.snackbar("Item count", "You can't reduce more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      return -_inCartItem;
    } else if ((_inCartItem + quantity) > 20) {
      _addEnough = false;
      Get.snackbar("Item count", "You can't add more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      return 20 - _inCartItem;
    } else {
      _addEnough = true;
      _reduceEnough = true;
      return quantity;
    }
  }

  void initProduct(ProductsModel product, CartController cart) {
    _quantity = 0;
    _inCartItem = 0;
    _cart = cart;
    var exist = false;
    exist = _cart.existInCart(product);
    //if exist
    //get from storage _inCartItem=3
    // print("exist or not " + exist.toString());
    if (exist) {
      _inCartItem = _cart.getQuantity(product);
    }
    // print("the quantity in the cart is " + _inCartItem.toString());
  }

  void addItem(ProductsModel product) {
    _cart.addItem(product, _quantity);
    _quantity = 0;
    _inCartItem = _cart.getQuantity(product);
    _cart.item.forEach((key, value) {
      print("The id is " +
          value.id.toString() +
          "The quantity is " +
          value.quantity.toString());
    });
    update();
  }

  int get totalItems {
    return _cart.totalItems;
  }

  List<CartModel> get getItems {
    return _cart.getItems;
  }
}
