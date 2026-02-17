import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_details_model.dart';
import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_item_widget.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';

class OrderContentWidget extends StatelessWidget {
  final OrderModel orderModel;
  final OrderController orderController;
  const OrderContentWidget(
      {super.key, required this.orderModel, required this.orderController});

  @override
  Widget build(BuildContext context) {
    bool isParcel = orderModel.orderType == 'parcel';

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
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text('order_contents'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          isParcel
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('parcel_category'.tr, style: robotoMedium),
                    Text(orderModel.parcelCategory?.name ?? 'not_found'.tr,
                        style: robotoRegular),
                    // Add more parcel details if needed
                  ],
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderDetailsModel!.length,
                  itemBuilder: (context, index) {
                    return OrderItemWidget(
                      order: orderModel,
                      orderDetails: orderController.orderDetailsModel![index],
                    );
                  },
                ),
        ],
      ),
    );
  }
}
