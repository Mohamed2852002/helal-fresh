import 'package:yalla_now_delivery/features/notification/controllers/notification_controller.dart';
import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/features/order/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_details_model.dart';
import 'package:yalla_now_delivery/helper/date_converter_helper.dart';
import 'package:yalla_now_delivery/helper/price_converter_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  Future<void> _loadData() async {
    Get.find<OrderController>().getIgnoreList();
    Get.find<OrderController>().removeFromIgnoreList();
    await Get.find<ProfileController>().getProfile();
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<OrderController>().getLatestOrders();
    await Get.find<OrderController>().getCompletedOrders(1);
    await Get.find<NotificationController>().getNotificationList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _HomeHeader(),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _SummaryCards(),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _OrderTabs(
                selectedIndex: _tabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              _OrderList(tabIndex: _tabIndex),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      if (profileController.profileModel == null) {
        return const SizedBox(height: 100);
      }
      return Container(
        padding: const EdgeInsets.only(
            top: 50,
            bottom: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'welcome'.tr} ${profileController.profileModel!.fName} ${profileController.profileModel!.lName}',
                  style: robotoBold.copyWith(
                      color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '#${profileController.profileModel!.id}',
                  style: robotoRegular.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            Expanded(
              child: _InfoCard(
                title: 'total_orders'.tr, // Using existing translation key
                value: profileController.profileModel?.orderCount.toString() ??
                    '0',
                icon: Icons.check_circle_outline,
                color: Colors.purple,
                iconColor: Colors.purple,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _InfoCard(
                title: 'rating'.tr, // Using existing translation key
                value: profileController.profileModel?.avgRating.toString() ??
                    '0.0',
                icon: Icons.star, // Changed icon to match typical rating UI
                color: Colors.orange,
                iconColor: Colors.orange,
                isRating: true,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final bool isRating;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              Expanded(
                child: Text(title,
                    style: robotoRegular.copyWith(
                        color: Colors.grey[600],
                        fontSize: Dimensions.fontSizeSmall)),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Text(value,
                  style: robotoBold.copyWith(
                      fontSize: 24,
                      color: isRating ? Colors.orange : Colors.purple)),
              isRating
                  ? const Icon(Icons.star, color: Colors.orange, size: 20)
                  : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTabs extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const _OrderTabs({required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          _TabItem(
              title: 'available'.tr, // "Requests" equivalent
              count: Get.find<OrderController>().latestOrderList?.length ?? 0,
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0)),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          _TabItem(
              title: 'active'.tr,
              count: Get.find<OrderController>().currentOrderList?.length ?? 0,
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1)),
          Container(width: 1, height: 20, color: Colors.grey[300]),
          _TabItem(
              title: 'completed'.tr, // "History" equivalent
              count:
                  Get.find<OrderController>().completedOrderList?.length ?? 0,
              isSelected: selectedIndex == 2,
              onTap: () => onTabSelected(2)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem(
      {required this.title,
      required this.count,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: robotoBold.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: robotoRegular.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final int tabIndex;

  const _OrderList({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(builder: (orderController) {
      List<OrderModel>? orders;
      if (tabIndex == 0) {
        orders = orderController.latestOrderList;
      } else if (tabIndex == 1) {
        orders = orderController.currentOrderList;
      } else {
        orders = orderController.completedOrderList;
      }

      if (orders == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (orders.isEmpty) {
        return Center(child: Text('no_order_found'.tr));
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault),
        itemCount: orders.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: Dimensions.paddingSizeDefault),
        itemBuilder: (context, index) {
          return _NewOrderCard(
            order: orders![index],
            isAvailable: tabIndex == 0,
            index: index,
          );
        },
      );
    });
  }
}

class _NewOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isAvailable;
  final int index;

  const _NewOrderCard(
      {required this.order, required this.isAvailable, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${'order_id'.tr} #${order.id}',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.paymentMethod == 'cash_on_delivery'
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(
                  order.paymentMethod == 'cash_on_delivery'
                      ? 'cod'.tr
                      : 'digital_payment'.tr,
                  style: robotoMedium.copyWith(
                    color: order.paymentMethod == 'cash_on_delivery'
                        ? Colors.green
                        : Colors.blue,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${order.deliveryCharge ?? 0} ${'egp'.tr}',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      'delivery_charge'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Text(
            order.customer?.fName ?? 'guest_user'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          Text(
            DateConverterHelper.timeDistanceInMin(order.createdAt!).toString(),
            style: robotoRegular.copyWith(
                color: Colors.grey, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.blue, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.deliveryAddress?.address ?? '',
                  style: robotoRegular.copyWith(
                      color: Colors.grey[700],
                      fontSize: Dimensions.fontSizeSmall),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.near_me_outlined, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                '${(order.deliveryCharge ?? 0).toStringAsFixed(1)} ${'km'.tr}', // Approximation if distance not available
                style: robotoRegular.copyWith(
                    color: Colors.grey, fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                '${order.createdAt}', // Placeholder for ETA
                style: robotoRegular.copyWith(
                    color: Colors.grey, fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('products'.tr,
                    style: robotoMedium.copyWith(
                        color: Colors.grey[600],
                        fontSize: Dimensions.fontSizeSmall)),
                const SizedBox(height: 8),
                FutureBuilder<List<OrderDetailsModel>?>(
                  future: Get.find<OrderController>()
                      .orderServiceInterface
                      .getOrderDetails(order.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.map((detail) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${detail.itemDetails?.name ?? 'Unknown'} x ${detail.quantity}',
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return Text('loading_failed'.tr);
                  },
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total_amount'.tr, style: robotoBold),
                    Text(
                      PriceConverterHelper.convertPrice(order.orderAmount),
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
              ),
              onPressed: () {
                if (isAvailable) {
                  Get.find<OrderController>()
                      .acceptOrder(order.id, index, order);
                } else {
                  Get.toNamed(
                    RouteHelper.getOrderDetailsRoute(order.id),
                    arguments: OrderDetailsScreen(
                      orderId: order.id,
                      isRunningOrder: true,
                      orderIndex: index,
                    ),
                  );
                }
              },
              child: Text(
                isAvailable ? 'accept_order'.tr : 'view_details'.tr,
                style: robotoBold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
