import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';

class OrderCustomerInfoWidget extends StatelessWidget {
  final OrderModel orderModel;
  const OrderCustomerInfoWidget({super.key, required this.orderModel});

  @override
  Widget build(BuildContext context) {
    bool isParcel = orderModel.orderType == 'parcel';
    String? name = isParcel
        ? orderModel.receiverDetails?.contactPersonName
        : orderModel.deliveryAddress?.contactPersonName;
    String? phone = isParcel
        ? orderModel.receiverDetails?.contactPersonNumber
        : orderModel.deliveryAddress?.contactPersonNumber;
    String? image = isParcel ? '' : orderModel.customer?.imageFullUrl;

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
              Text('customer_info'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.phone, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Container(
                height: 40, width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1)),
                child: Icon(Icons.person,
                    color: Colors
                        .blue), // Placeholder or use CustomImageWidget if image exists
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('name'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor)),
                    Text(name ?? 'not_found'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                    const SizedBox(height: 4),
                    Text('phone'.tr,
                        style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor)),
                    Text(phone ?? 'not_found'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
