import 'dart:async';
import 'package:yalla_now_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/common/widgets/custom_button_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String? number;
  const VerificationScreen({super.key, required this.number});

  @override
  VerificationScreenState createState() => VerificationScreenState();
}

class VerificationScreenState extends State<VerificationScreen> {
  String? _number;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();

    _number = widget.number!.startsWith('+')
        ? widget.number
        : '+${widget.number!.substring(1, widget.number!.length)}';
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Center(
              child: GetBuilder<ForgotPasswordController>(
                builder: (forgotPasswordController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child:
                              SvgPicture.asset(Images.forgetPassProfileIcon)),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                      Text('phone_number_confirmation'.tr,
                          style: robotoBold.copyWith(fontSize: 24)),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Text('confirmation_code_sent'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).disabledColor)),
                      Text(' $_number',
                          style: robotoMedium.copyWith(
                              color: Theme.of(context).primaryColor)),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: PinCodeTextField(
                          length: 4,
                          appContext: context,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.slide,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 60,
                            fieldWidth: 60,
                            borderWidth: 1,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                            selectedColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.2),
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Theme.of(context).cardColor,
                            inactiveColor: Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 0.1),
                            activeColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.4),
                            activeFillColor: Theme.of(context).cardColor,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged:
                              forgotPasswordController.updateVerificationCode,
                          beforeTextPaste: (text) => true,
                        ),
                      ),
                      Text(
                        '${'resend_in'.tr}\n${_seconds}',
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      !forgotPasswordController.isLoading
                          ? CustomButtonWidget(
                              buttonText: 'next'.tr,
                              backgroundColor: const Color(0xFF0D77BC),
                              onPressed: forgotPasswordController
                                          .verificationCode.length ==
                                      4
                                  ? () {
                                      forgotPasswordController
                                          .verifyToken(_number)
                                          .then((value) {
                                        if (value.isSuccess) {
                                          Get.toNamed(
                                              RouteHelper.getResetPasswordRoute(
                                                  _number,
                                                  forgotPasswordController
                                                      .verificationCode,
                                                  'reset-password'));
                                        } else {
                                          showCustomSnackBar(value.message);
                                        }
                                      });
                                    }
                                  : null,
                            )
                          : const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _seconds < 1
                            ? () {
                                forgotPasswordController
                                    .forgetPassword(widget.number)
                                    .then((value) {
                                  if (value.isSuccess) {
                                    _startTimer();
                                    showCustomSnackBar(
                                        'resend_code_successful'.tr,
                                        isError: false);
                                  } else {
                                    showCustomSnackBar(value.message);
                                  }
                                });
                              }
                            : null,
                        child: Text(
                          'resend_code'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
