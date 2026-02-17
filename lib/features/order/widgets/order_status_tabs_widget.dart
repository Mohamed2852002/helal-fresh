import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderStatusTabsWidget extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onTap;
  final Map<String, int> statusCounts;

  const OrderStatusTabsWidget({
    super.key,
    required this.selectedStatus,
    required this.onTap,
    required this.statusCounts,
  });

  @override
  Widget build(BuildContext context) {
    // Keys matching JSON translation keys
    final tabs = [
      'all',
      'completed',
      'active',
      'canceled'
    ]; // Reordered to match mock: All, Completed, Active, Canceled (Mock was 10, 6, 3, 1 -> All, Completed, Active, Canceled likely)

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((status) {
          bool isSelected = selectedStatus == status;
          Color statusColor;
          if (status == 'all') {
            statusColor = Theme.of(context).textTheme.bodyLarge!.color!;
          } else if (status == 'canceled') {
            statusColor = Colors.red;
          } else {
            statusColor = Theme.of(context).primaryColor;
          }

          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () => onTap(status),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                constraints: const BoxConstraints(minWidth: 80),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: [
                    isSelected
                        ? BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(
                                0, 4), // stronger shadow for 3D effect
                          )
                        : BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${statusCounts[status] ?? 0}',
                      style: robotoBold.copyWith(
                        color: statusColor,
                        fontSize:
                            Dimensions.fontSizeExtraLarge + 4, // Larger number
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      status.tr,
                      style: robotoRegular.copyWith(
                        color: statusColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
