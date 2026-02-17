import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/util/app_constants.dart';

class OrderTimelineWidget extends StatelessWidget {
  final String? orderStatus;
  const OrderTimelineWidget({super.key, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    int currentStep = _getStepFromStatus(orderStatus);

    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeSmall),
      color: Theme.of(context).cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(context, 'accepted'.tr,
              isActive: currentStep >= 0, isCompleted: currentStep >= 0),
          _buildLine(context, isActive: currentStep > 0),
          _buildStep(context, 'processing'.tr,
              isActive: currentStep >= 1, isCompleted: currentStep >= 1),
          _buildLine(context, isActive: currentStep > 1),
          _buildStep(context, 'delivery'.tr,
              isActive: currentStep >= 2, isCompleted: currentStep >= 2),
          _buildLine(context, isActive: currentStep > 2),
          _buildStep(context, 'completed'.tr,
              isActive: currentStep >= 3, isCompleted: currentStep >= 3),
        ],
      ),
    );
  }

  int _getStepFromStatus(String? status) {
    switch (status) {
      case AppConstants.pending:
      case AppConstants.confirmed:
      case AppConstants.accepted:
        return 0;
      case AppConstants.processing:
      case AppConstants.handover:
        return 1;
      case AppConstants.pickedUp:
        return 2;
      case AppConstants.delivered:
        return 3;
      default:
        return 0;
    }
  }

  Widget _buildStep(BuildContext context, String title,
      {required bool isActive, required bool isCompleted}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withOpacity(0.2),
          ),
          child: Icon(Icons.check,
              size: 16,
              color: isActive ? Colors.white : Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: 10,
            color: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context, {required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor.withOpacity(0.2),
      ),
    );
  }
}
