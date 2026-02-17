import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/features/order/screens/order_location_screen.dart';
import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';

class OrderDeliveryAddressWidget extends StatelessWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  final int? index;
  const OrderDeliveryAddressWidget(
      {super.key,
      required this.orderModel,
      required this.orderController,
      this.index});

  @override
  Widget build(BuildContext context) {
    bool isParcel = orderModel.orderType == 'parcel';
    String? address = isParcel
        ? orderModel.receiverDetails?.address
        : orderModel.deliveryAddress?.address;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              blurRadius: 5,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('delivery_address'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              InkWell(
                onTap: () {
                  Get.to(() => OrderLocationScreen(
                        orderModel: orderModel,
                        orderController: orderController,
                        index: index ?? 0,
                        onTap: () {},
                      ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('view_on_map'.tr,
                          style: robotoRegular.copyWith(
                              color: Colors.white,
                              fontSize: Dimensions.fontSizeExtraSmall)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined,
                  color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address ?? '',
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    // Specific details like Floor, Apt if available in address model?
                    // Assuming they are part of address string or separate fields.
                    // If separate:
                    // Text('Floor: ${orderModel.deliveryAddress?.floor ?? 'N/A'}', ...),
                  ],
                ),
              ),
            ],
          ),
          if (orderModel.orderNote != null &&
              orderModel.orderNote!.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6), // Light yellow bg from image
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border:
                    Border.all(color: const Color(0xFFFFE082)), // Yellow border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.comment,
                          color: Color(0xFFFFA000), size: 16),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('customer_note'.tr,
                          style: robotoMedium.copyWith(
                              color: const Color(0xFFFFA000))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(orderModel.orderNote!,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
