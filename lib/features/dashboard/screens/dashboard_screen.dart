import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yalla_now_delivery/features/auth/controllers/auth_controller.dart';
import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';
import 'package:yalla_now_delivery/features/disbursement/helper/disbursement_helper.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/helper/notification_helper.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/main.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_alert_dialog_widget.dart';
import 'package:yalla_now_delivery/features/dashboard/widgets/new_request_dialog_widget.dart';
import 'package:yalla_now_delivery/features/home/screens/home_screen.dart';
import 'package:yalla_now_delivery/features/profile/screens/profile_screen.dart';
import 'package:yalla_now_delivery/features/order/screens/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromOrderDetails;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromOrderDetails = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;
  DisbursementHelper disbursementHelper = DisbursementHelper();

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    showDisbursementWarningMessage();

    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? type = message.data['body_loc_key'] ?? message.data['type'];
      String? orderID =
          message.data['title_loc_key'] ?? message.data['order_id'];
      bool isParcel = (message.data['order_type'] == 'parcel_order');
      if (type != 'assign' &&
          type != 'new_order' &&
          type != 'message' &&
          type != 'order_request' &&
          type != 'order_status') {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      }
      if (type == 'new_order' || type == 'order_request') {
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();
        Get.dialog(NewRequestDialogWidget(
            isRequest: true,
            onTap: () => _navigateRequestPage(),
            orderId: int.parse(message.data['order_id'].toString()),
            isParcel: isParcel));
      } else if (type == 'assign' && orderID != null && orderID.isNotEmpty) {
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();
        Get.dialog(NewRequestDialogWidget(
            isRequest: false,
            orderId: int.parse(message.data['order_id'].toString()),
            isParcel: isParcel,
            onTap: () {
              Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                  int.parse(orderID),
                  fromNotification: true));
            }));
      } else if (type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<ProfileController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });
  }

  showDisbursementWarningMessage() async {
    if (!widget.fromOrderDetails) {
      disbursementHelper.enableDisbursementWarningMessage(true);
    }
  }

  void _navigateRequestPage() {
    if (Get.find<ProfileController>().profileModel != null &&
        Get.find<ProfileController>().profileModel!.active == 1 &&
        Get.find<OrderController>().currentOrderList != null &&
        Get.find<OrderController>().currentOrderList!.isEmpty) {
      _setPage(1);
    } else {
      if (Get.find<ProfileController>().profileModel == null ||
          Get.find<ProfileController>().profileModel!.active == 0) {
        Get.dialog(CustomAlertDialogWidget(
            description: 'you_are_offline_now'.tr,
            onOkPressed: () => Get.back()));
      } else {
        _setPage(1);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (GetPlatform.isAndroid &&
              Get.find<ProfileController>().profileModel!.active == 1) {
            _channel.invokeMethod('sendToBackground');
          } else {
            return;
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'home'.tr,
                      svgPath: Images.homeNavIcon,
                      isSelected: _pageIndex == 0,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'orders'.tr,
                      svgPath: Images.ordersNavIcon,
                      isSelected: _pageIndex == 1,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'profile'.tr,
                      iconData: Icons.person_outline,
                      isSelected: _pageIndex == 2,
                    ),
                  ],
                ),
              ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    String? svgPath,
    IconData? iconData,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _setPage(index),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor,
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : Colors.grey,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      iconData,
                      size: 24,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
              const SizedBox(height: 4),
              Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
