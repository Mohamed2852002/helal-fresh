import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const OrderSearchWidget(
      {super.key, required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 2, // Slight vertical padding adjustment
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: TextField(
        controller: searchController,
        style: robotoRegular,
        decoration: InputDecoration(
          hintText: 'search_order_placeholder'.tr,
          hintStyle:
              robotoRegular.copyWith(color: Theme.of(context).disabledColor),
          border: InputBorder.none,
          suffixIcon:
              Icon(Icons.search, color: Theme.of(context).disabledColor),
        ),
        onChanged: onSearch,
      ),
    );
  }
}
