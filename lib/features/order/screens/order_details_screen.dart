import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yalla_now_delivery/features/order/controllers/order_controller.dart';
import 'package:yalla_now_delivery/features/splash/controllers/splash_controller.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_details_model.dart';
import 'package:yalla_now_delivery/features/order/domain/models/order_model.dart';
import 'package:yalla_now_delivery/helper/price_converter_helper.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/app_constants.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_button_widget.dart';
import 'package:yalla_now_delivery/features/order/widgets/verify_delivery_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:yalla_now_delivery/features/order/widgets/order_timeline_widget.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_customer_info_widget.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_delivery_address_widget.dart';
import 'package:yalla_now_delivery/features/order/widgets/order_content_widget.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool? isRunningOrder;
  final int? orderIndex;
  final bool fromNotification;
  final bool fromLocationScreen;
  const OrderDetailsScreen(
      {super.key,
      required this.orderId,
      required this.isRunningOrder,
      required this.orderIndex,
      this.fromNotification = false,
      this.fromLocationScreen = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;

  void _startApiCalling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().getOrderWithId(widget.orderId!);
    });
  }

  Future<void> _loadData() async {
    Get.find<OrderController>()
        .pickPrescriptionImage(isRemove: true, isCamera: false);
    await Get.find<OrderController>().getOrderWithId(widget.orderId);
    Get.find<OrderController>().getOrderDetails(widget.orderId,
        Get.find<OrderController>().orderModel!.orderType == 'parcel');
    await Get.find<OrderController>().getLatestOrders();
    if (Get.find<OrderController>().showDeliveryImageField) {
      Get.find<OrderController>().changeDeliveryImageStatus(isUpdate: false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _startApiCalling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if ((widget.fromNotification || widget.fromLocationScreen)) {
          Future.delayed(const Duration(milliseconds: 0), () async {
            await Get.offAllNamed(RouteHelper.getInitialRoute());
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(
            title: 'order_details'.tr,
            onBackPressed: () {
              if (widget.fromNotification || widget.fromLocationScreen) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        body: SafeArea(
          child: GetBuilder<OrderController>(builder: (orderController) {
            OrderModel? controllerOrderModel = orderController.orderModel;

            bool? parcel,
                processing,
                accepted,
                confirmed,
                handover,
                pickedUp,
                cod,
                wallet,
                partialPay,
                offlinePay;
            double? deliveryCharge = 0;
            double itemsPrice = 0;
            double? discount = 0;
            double? couponDiscount = 0;
            double? tax = 0;
            double addOns = 0;
            double? dmTips = 0;
            double additionalCharge = 0;
            double extraPackagingAmount = 0;
            double referrerBonusAmount = 0;
            bool? taxIncluded = false;
            OrderModel? order = controllerOrderModel;

            if (order != null && orderController.orderDetailsModel != null) {
              deliveryCharge = order.deliveryCharge;
              dmTips = order.dmTips;
              discount = order.storeDiscountAmount! +
                  order.flashAdminDiscountAmount! +
                  order.flashStoreDiscountAmount!;
              tax = order.totalTaxAmount;
              taxIncluded = order.taxStatus;
              additionalCharge = order.additionalCharge!;
              extraPackagingAmount = order.extraPackagingAmount!;
              referrerBonusAmount = order.referrerBonusAmount!;
              couponDiscount = order.couponDiscountAmount;

              if (order.prescriptionOrder!) {
                double orderAmount = order.orderAmount ?? 0;
                itemsPrice = (orderAmount + discount) -
                    ((taxIncluded! ? 0 : tax!) +
                        deliveryCharge! +
                        additionalCharge) -
                    dmTips!;
              } else {
                for (OrderDetailsModel orderDetails
                    in orderController.orderDetailsModel!) {
                  for (AddOn addOn in orderDetails.addOns!) {
                    addOns = addOns + (addOn.price! * addOn.quantity!);
                  }
                  itemsPrice = itemsPrice +
                      (orderDetails.price! * orderDetails.quantity!);
                }
              }
            }
            double subTotal = itemsPrice + addOns;
            double total = itemsPrice +
                addOns -
                discount +
                (taxIncluded! ? 0 : tax!) +
                deliveryCharge! -
                couponDiscount! +
                dmTips! +
                additionalCharge +
                extraPackagingAmount -
                referrerBonusAmount;

            if (controllerOrderModel != null) {
              parcel = controllerOrderModel.orderType == 'parcel';
              processing =
                  controllerOrderModel.orderStatus == AppConstants.processing;
              accepted =
                  controllerOrderModel.orderStatus == AppConstants.accepted;
              confirmed =
                  controllerOrderModel.orderStatus == AppConstants.confirmed;
              handover =
                  controllerOrderModel.orderStatus == AppConstants.handover;
              pickedUp =
                  controllerOrderModel.orderStatus == AppConstants.pickedUp;
              cod = controllerOrderModel.paymentMethod == 'cash_on_delivery';
              wallet = controllerOrderModel.paymentMethod == 'wallet';
              partialPay =
                  controllerOrderModel.paymentMethod == 'partial_payment';
              offlinePay =
                  controllerOrderModel.paymentMethod == 'offline_payment';
            }

            return (orderController.orderDetailsModel != null &&
                    controllerOrderModel != null)
                ? Column(
                    children: [
                      OrderTimelineWidget(
                          orderStatus: controllerOrderModel.orderStatus),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Column(
                            children: [
                              OrderCustomerInfoWidget(
                                  orderModel: controllerOrderModel),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              OrderDeliveryAddressWidget(
                                  orderModel: controllerOrderModel,
                                  orderController: orderController,
                                  index: widget.orderIndex),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              OrderContentWidget(
                                  orderModel: controllerOrderModel,
                                  orderController: orderController),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),

                              // Payment Summary Widget
                              Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radiusDefault),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors
                                            .grey[Get.isDarkMode ? 800 : 200]!,
                                        blurRadius: 5,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Text('payment_summary'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge)),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeDefault),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('item_price'.tr,
                                              style: robotoRegular),
                                          Text(
                                              PriceConverterHelper.convertPrice(
                                                  itemsPrice),
                                              style: robotoRegular),
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('delivery_fee'.tr,
                                              style: robotoRegular),
                                          Text(
                                              PriceConverterHelper.convertPrice(
                                                  deliveryCharge),
                                              style: robotoRegular),
                                        ]),
                                    const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: Divider()),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('total_amount'.tr,
                                              style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                          Text(
                                              PriceConverterHelper.convertPrice(
                                                  total),
                                              style: robotoBold.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeLarge,
                                                  color: Theme.of(context)
                                                      .primaryColor)),
                                        ]),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeDefault),
                                    Container(
                                      padding: const EdgeInsets.all(
                                          Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                            Dimensions.radiusSmall),
                                        border: Border.all(color: Colors.green),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('payment_method'.tr,
                                              style: robotoRegular.copyWith(
                                                  color: Colors.green,
                                                  fontSize: Dimensions
                                                      .fontSizeSmall)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                  cod!
                                                      ? Icons.money
                                                      : Icons.credit_card,
                                                  color: Colors.green,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                  cod!
                                                      ? 'cash_on_delivery'.tr
                                                      : 'digital_payment'.tr,
                                                  style: robotoMedium.copyWith(
                                                      color: Colors.green)),
                                            ],
                                          ),
                                          if (cod!) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.orange,
                                                    size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                    '${'collect_money'.tr} ${PriceConverterHelper.convertPrice(total)}',
                                                    style:
                                                        robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color:
                                                                Colors.orange)),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Action Buttons
                      if (controllerOrderModel.orderStatus != 'delivered' &&
                          controllerOrderModel.orderStatus != 'failed' &&
                          controllerOrderModel.orderStatus != 'canceled' &&
                          controllerOrderModel.orderStatus != 'refunded')
                        Container(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 1)
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (handover! ||
                                  processing! ||
                                  accepted! ||
                                  confirmed!)
                                CustomButtonWidget(
                                  buttonText: 'confirm_receiving'.tr,
                                  backgroundColor: Colors.orange,
                                  onPressed: () {
                                    Get.find<OrderController>()
                                        .updateOrderStatus(controllerOrderModel,
                                            AppConstants.pickedUp,
                                            back: true);
                                  },
                                ),
                              if (pickedUp!)
                                Column(
                                  children: [
                                    CustomButtonWidget(
                                      buttonText: 'start_delivery'.tr,
                                      backgroundColor: Colors.purple,
                                      onPressed: () async {
                                        String url =
                                            'https://www.google.com/maps/dir/?api=1&destination=${controllerOrderModel.deliveryAddress?.latitude},${controllerOrderModel.deliveryAddress?.longitude}&mode=d';
                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        }
                                      },
                                      icon: Icons.navigation,
                                    ),
                                    const SizedBox(
                                        height: Dimensions.paddingSizeSmall),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomButtonWidget(
                                            buttonText: 'call_customer'.tr,
                                            transparent: true,
                                            onPressed: () {
                                              launchUrlString(
                                                  'tel:${controllerOrderModel.deliveryAddress?.contactPersonNumber}');
                                            },
                                            icon: Icons.call,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                        Expanded(
                                          child: CustomButtonWidget(
                                            buttonText: 'confirm_delivery'.tr,
                                            onPressed: () {
                                              Get.back();
                                              Get.bottomSheet(
                                                  VerifyDeliverySheetWidget(
                                                    currentOrderModel:
                                                        controllerOrderModel,
                                                    verify: Get.find<
                                                            SplashController>()
                                                        .configModel!
                                                        .orderDeliveryVerification!,
                                                    orderAmount:
                                                        controllerOrderModel
                                                            .orderAmount,
                                                    cod: cod,
                                                  ),
                                                  isScrollControlled: true);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                child: PhotoView(
                  tightMode: true,
                  imageProvider: NetworkImage(imageUrl),
                  heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    splashRadius: 5,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                  )),
            ]),
          );
        },
      );
}
