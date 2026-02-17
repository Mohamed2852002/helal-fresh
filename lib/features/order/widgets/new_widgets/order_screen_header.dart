import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';

class OrderScreenHeader extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final int orderCount;

  const OrderScreenHeader({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.orderCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 50,
          bottom: Dimensions.paddingSizeDefault,
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'my_orders'.tr,
                    style: robotoBold.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.fontSizeExtraLarge),
                  ),
                  Text(
                    'all_orders_and_deliveries'.tr,
                    style: robotoRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Text(
                  '$orderCount ${'orders'.tr}',
                  style: robotoMedium.copyWith(
                      color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          TextField(
            controller: searchController,
            style: robotoRegular.copyWith(color: Colors.black),
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'search_order_placeholder'.tr,
              hintStyle: robotoRegular.copyWith(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault, vertical: 12),
              suffixIcon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
