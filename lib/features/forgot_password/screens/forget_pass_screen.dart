import 'package:country_code_picker/country_code_picker.dart';
import 'package:yalla_now_delivery/features/splash/controllers/splash_controller.dart';
import 'package:yalla_now_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:yalla_now_delivery/helper/custom_validator_helper.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_button_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!)
      .dialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(Images.forgetPassProfileIcon)),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Text('forgot_password'.tr, style: robotoBold.copyWith(fontSize: 30)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text('please_enter_mobile_number'.tr,
              style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center),
          const SizedBox(height: 50),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('phone_label'.tr,
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: Row(children: [
                  CountryCodePicker(
                    onChanged: (CountryCode countryCode) {
                      _countryDialCode = countryCode.dialCode;
                    },
                    initialSelection: _countryDialCode,
                    favorite: [_countryDialCode!],
                    showDropDownButton: true,
                    padding: EdgeInsets.zero,
                    dialogBackgroundColor: Theme.of(context).cardColor,
                    backgroundColor: Theme.of(context).cardColor,
                    showFlagMain: true,
                    textStyle: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  Expanded(
                      child: CustomTextFieldWidget(
                    controller: _numberController,
                    inputType: TextInputType.phone,
                    inputAction: TextInputAction.done,
                    hintText: 'phone'.tr,
                    border: false,
                    onSubmit: (text) => GetPlatform.isWeb
                        ? _forgetPass(_countryDialCode!)
                        : null,
                  )),
                ]),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          GetBuilder<ForgotPasswordController>(
              builder: (forgotPasswordController) {
            return !forgotPasswordController.isLoading
                ? CustomButtonWidget(
                    buttonText: 'send_verification_code'.tr,
                    backgroundColor: const Color(0xFF0D77BC),
                    onPressed: () => _forgetPass(_countryDialCode!),
                  )
                : const Center(child: CircularProgressIndicator());
          }),
          const SizedBox(height: 100),
        ])),
      ))),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid =
        await CustomValidatorHelper.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else {
      Get.find<ForgotPasswordController>()
          .forgetPassword(numberWithCountryCode)
          .then((status) async {
        if (status.isSuccess) {
          Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode));
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
