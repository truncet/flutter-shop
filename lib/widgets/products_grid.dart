import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;

  ProductGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.showFavorites : productsData.items;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // create: (ct) => products[i],
        value: products[i],
        child: ProductItem(
            // products[i].id,
            //products[i].title,
            //products[i].imageUrl,
            //products[i].price,
            ),
      ),
      padding: EdgeInsets.all(10),
      itemCount: products.length,
    );
  }
}
