import 'package:flutter_svg/flutter_svg.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/features/order/screens/order_request_screen.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';

import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/helper/date_converter_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isRunning;
  final int index;
  final Function()? onTrackTap;
  final Function()? onDetailsTap;

  const OrderCardWidget({
    super.key,
    required this.orderModel,
    required this.isRunning,
    required this.index,
    this.onTrackTap,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${'order_id'.tr} #${orderModel.id}',
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(orderModel.orderStatus)
                                .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Text(
                            orderModel.orderStatus?.tr ?? '',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: _getStatusColor(orderModel.orderStatus),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${orderModel.deliveryCharge} ${'egp'.tr}',
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).primaryColor),
                              ),
                              Text(
                                'delivery_charge'.tr,
                                style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).disabledColor),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      orderModel.customer?.fName != null
                          ? '${orderModel.customer!.fName} ${orderModel.customer!.lName}'
                          : 'customer_not_found'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            size: 14, color: Theme.of(context).disabledColor),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          DateConverterHelper.isoStringToLocalDateAnTime(
                              orderModel.createdAt!),
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).disabledColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Theme.of(context).primaryColor),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                          child: Text(
                            orderModel.deliveryAddress?.address ??
                                'address_not_found'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).disabledColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      children: [
                        const Icon(Icons.near_me_outlined,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${(orderModel.deliveryCharge ?? 0).toStringAsFixed(1)} ${'km'.tr}', // Approximation if distance not available
                          style: robotoRegular.copyWith(
                              color: Colors.grey,
                              fontSize: Dimensions.fontSizeSmall),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(Images.orderBox),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          orderModel.paymentMethod?.tr ??
                              'cash_on_delivery'.tr,
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(Images.dollarSign),
                        const SizedBox(
                            width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '${orderModel.totalTaxAmount ?? 0}',
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          if (orderModel.orderStatus == 'canceled' ||
              orderModel.orderStatus == 'failed' ||
              orderModel.orderStatus == 'refund_requested') ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border:
                    Border.all(color: Theme.of(context).colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.close,
                      color: Theme.of(context).colorScheme.error, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'order_canceled'.tr,
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ] else if (orderModel.orderStatus == 'delivered') ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.check,
                      color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    '${'delivered_at'.tr} ${DateConverterHelper.isoStringToLocalTimeOnly(orderModel.updatedAt ?? '')}',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],
          Row(
            children: [
              if (isRunning) ...[
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (orderModel.customer != null &&
                          orderModel.customer!.phone != null) {
                        String url = 'tel:${orderModel.customer!.phone}';
                        if (await canLaunchUrlString(url)) {
                          await launchUrlString(url);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: const Center(
                          child: Icon(Icons.call,
                              color: Colors.white, size: 20)),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: onTrackTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Center(
                        child: Text(
                          'track_order'.tr,
                          style: robotoBold.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: onDetailsTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Center(
                        child: Text(
                          'view_details'.tr,
                          style: robotoBold.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: InkWell(
                    onTap: onDetailsTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Center(
                        child: Text(
                          'view_details'.tr,
                          style: robotoBold.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'pending') {
      return Colors.blue;
    } else if (status == 'confirmed') {
      return Colors.blueAccent;
    } else if (status == 'processing') {
      return Colors.orange;
    } else if (status == 'handover') {
      return Colors.deepOrange;
    } else if (status == 'picked_up') {
      return Colors.purple;
    } else if (status == 'delivered') {
      return Colors.green;
    } else if (status == 'canceled') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}
