import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yalla_now_delivery/features/auth/controllers/auth_controller.dart';
import 'package:yalla_now_delivery/features/language/controllers/language_controller.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/features/splash/controllers/splash_controller.dart';
import 'package:yalla_now_delivery/helper/custom_validator_helper.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatelessWidget {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String? countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel!.country!)
                .dialCode;
    _phoneController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              const Color(0xff2D9B5F), // Light Blue
              // Green/Primary
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: GetBuilder<AuthController>(builder: (authController) {
                return Column(children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: SvgPicture.asset(Images.riderSignInIcon)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text('drivers_portal'.tr,
                      style: robotoBold.copyWith(
                          fontSize: 30, color: Colors.white)),
                  Text('helal_fresh'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Colors.white70)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(children: [
                      Text('sign_in'.tr,
                          style: robotoBold.copyWith(
                              fontSize: 24, color: Colors.black)),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      CustomTextFieldWidget(
                        hintText: 'phone'.tr,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.phone,
                        divider: false,
                        isPhone: true,
                        border: true,
                        showTitle: true,
                        onCountryChanged: (CountryCode countryCode) {
                          countryDialCode = countryCode.dialCode;
                        },
                        countryDialCode: countryDialCode != null
                            ? CountryCode.fromCountryCode(
                                    Get.find<SplashController>()
                                        .configModel!
                                        .country!)
                                .code
                            : Get.find<LocalizationController>()
                                .locale
                                .countryCode,
                        suffixIcon: Icons.phone,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      CustomTextFieldWidget(
                        hintText: 'password'.tr,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.visiblePassword,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                        border: true,
                        showTitle: true,
                        onSubmit: (text) => GetPlatform.isWeb
                            ? _login(
                                authController,
                                _phoneController,
                                _passwordController,
                                countryDialCode!,
                                context,
                              )
                            : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Row(children: [
                        Expanded(
                          child: ListTile(
                            onTap: () => authController.toggleRememberMe(),
                            leading: Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: authController.isActiveRememberMe,
                              onChanged: (bool? isChecked) =>
                                  authController.toggleRememberMe(),
                            ),
                            title: Text('remember_me'.tr,
                                style: robotoRegular.copyWith(
                                    color: Theme.of(context).disabledColor)),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            horizontalTitleGap: 0,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Get.toNamed(RouteHelper.getForgotPassRoute()),
                          child: Text('${'forgot_password'.tr}?',
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      !authController.isLoading
                          ? Container(
                              height: 50,
                              width: 1170,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2A93D5), // Light Blue
                                    Theme.of(context).primaryColor, // Green
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusDefault),
                                  ),
                                ),
                                onPressed: () => _login(
                                    authController,
                                    _phoneController,
                                    _passwordController,
                                    countryDialCode!,
                                    context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        Images.riderSignInButtonIcon,
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn)),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('sign_in'.tr,
                                        textAlign: TextAlign.center,
                                        style: robotoBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.fontSizeLarge,
                                        )),
                                  ],
                                ),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'dont_have_account'.tr,
                        style: robotoRegular.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      InkWell(
                        onTap: () {
                          // Action for contacting admin, maybe open url or show dialog
                        },
                        child: Text(
                          'contact_admin'.tr,
                          style: robotoBold.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _login(
      AuthController authController,
      TextEditingController phoneText,
      TextEditingController passText,
      String countryCode,
      BuildContext context) async {
    String phone = phoneText.text.trim();
    String password = passText.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid =
        await CustomValidatorHelper.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    } else {
      authController
          .login(numberWithCountryCode, password)
          .then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(
                phone, password, countryCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          await Get.find<ProfileController>().getProfile();
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
