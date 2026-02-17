import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_card_widget.dart';
import 'package:yalla_now_delivery/features/order/widgets/new_widgets/order_screen_header.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_status_tabs_widget.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadData() async {
    await Get.find<OrderController>().getCurrentOrders();
    await Get.find<OrderController>().getCompletedOrders(1);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        Get.find<OrderController>().completedOrderList != null &&
        !Get.find<OrderController>().paginate) {
      int pageSize = (Get.find<OrderController>().pageSize! / 10).ceil();
      if (Get.find<OrderController>().offset < pageSize) {
        Get.find<OrderController>()
            .setOffset(Get.find<OrderController>().offset + 1);
        debugPrint('end of the page');
        Get.find<OrderController>().showBottomLoader();
        Get.find<OrderController>()
            .getCompletedOrders(Get.find<OrderController>().offset);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderController>(builder: (orderController) {
        List<OrderModel> currentList = orderController.currentOrderList ?? [];
        List<OrderModel> completedList =
            orderController.completedOrderList ?? [];
        List<OrderModel> allOrders = [...currentList, ...completedList];

        // Filter by Status
        List<OrderModel> filteredByStatus = [];
        if (_selectedStatus == 'all') {
          filteredByStatus = allOrders;
        } else if (_selectedStatus == 'active') {
          filteredByStatus = currentList;
        } else if (_selectedStatus == 'completed') {
          filteredByStatus = completedList
              .where((order) => order.orderStatus == 'delivered')
              .toList();
        } else if (_selectedStatus == 'canceled') {
          filteredByStatus = completedList
              .where((order) =>
                  order.orderStatus == 'canceled' ||
                  order.orderStatus == 'failed' ||
                  order.orderStatus == 'refund_requested')
              .toList();
        }

        // Filter by Search Query
        String query = _searchController.text.toLowerCase();
        List<OrderModel> finalOrders = filteredByStatus.where((order) {
          String orderId = order.id.toString();
          String customerName = order.customer != null
              ? '${order.customer!.fName} ${order.customer!.lName}'
              : '';
          return orderId.contains(query) ||
              customerName.toLowerCase().contains(query);
        }).toList();

        // Counts for Tabs
        Map<String, int> statusCounts = {
          'all': allOrders.length,
          'active': currentList.length,
          'completed': completedList
              .where((order) => order.orderStatus == 'delivered')
              .length,
          'canceled': completedList
              .where((order) =>
                  order.orderStatus == 'canceled' ||
                  order.orderStatus == 'failed' ||
                  order.orderStatus == 'refund_requested')
              .length,
        };

        return RefreshIndicator(
          onRefresh: () async {
            await _loadData();
          },
          child: Column(
            children: [
              OrderScreenHeader(
                searchController: _searchController,
                orderCount: finalOrders.length,
                onSearch: (value) {
                  setState(() {});
                },
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                        ),
                        child: Column(
                          children: [
                            OrderStatusTabsWidget(
                              selectedStatus: _selectedStatus,
                              onTap: (status) {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              statusCounts: statusCounts,
                            ),
                          ],
                        ),
                      ),
                    ),
                    finalOrders.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == finalOrders.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          Dimensions.paddingSizeSmall),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical:
                                          Dimensions.paddingSizeExtraSmall),
                                  child: OrderCardWidget(
                                    orderModel: finalOrders[index],
                                    isRunning:
                                        _selectedStatus == 'active' ||
                                            (finalOrders[index].orderStatus !=
                                                    'delivered' &&
                                                finalOrders[index]
                                                        .orderStatus !=
                                                    'canceled' &&
                                                finalOrders[index]
                                                        .orderStatus !=
                                                    'failed' &&
                                                finalOrders[index]
                                                        .orderStatus !=
                                                    'refund_requested'),
                                    index: index,
                                    onTrackTap: () {
                                      Get.toNamed(
                                          RouteHelper.getOrderDetailsRoute(
                                              finalOrders[index].id));
                                    },
                                    onDetailsTap: () {
                                      Get.toNamed(
                                          RouteHelper.getOrderDetailsRoute(
                                              finalOrders[index].id));
                                    },
                                  ),
                                );
                              },
                              childCount: finalOrders.length +
                                  (orderController.paginate ? 1 : 0),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: Center(
                              child: Text('no_order_found'.tr,
                                  style: robotoRegular),
                            ),
                          ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
