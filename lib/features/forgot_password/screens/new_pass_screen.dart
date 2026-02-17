import 'package:yalla_now_delivery/features/auth/controllers/auth_controller.dart';
import 'package:yalla_now_delivery/features/auth/widgets/pass_view_widget.dart';
import 'package:yalla_now_delivery/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/features/profile/domain/models/profile_model.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_button_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NewPassScreen extends StatefulWidget {
  final String? resetToken;
  final String? number;
  final bool fromPasswordChange;
  const NewPassScreen(
      {super.key,
      required this.resetToken,
      required this.number,
      required this.fromPasswordChange});

  @override
  State<NewPassScreen> createState() => _NewPassScreenState();
}

class _NewPassScreenState extends State<NewPassScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().showPassView) {
      Get.find<AuthController>().showHidePass();
    }
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
              child: GetBuilder<AuthController>(builder: (authController) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(Images.forgetPassProfileIcon),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    Text(
                      widget.fromPasswordChange
                          ? 'change_password'.tr
                          : 'new_password'.tr,
                      style: robotoBold.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'new_password_label'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        CustomTextFieldWidget(
                          hintText: 'enter_strong_password'.tr,
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocus,
                          nextFocus: _confirmPasswordFocus,
                          inputAction: TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          isPassword: true,
                          prefixIcon: Icons.lock,
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!authController.showPassView) {
                                authController.showHidePass();
                              }
                              authController.validPassCheck(value);
                            } else {
                              if (authController.showPassView) {
                                authController.showHidePass();
                              }
                            }
                          },
                        ),
                        authController.showPassView
                            ? const Align(
                                alignment: Alignment.centerLeft,
                                child: PassViewWidget())
                            : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text(
                          'confirm_new_password_label'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        CustomTextFieldWidget(
                          hintText: 'enter_strong_password'.tr,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          inputAction: TextInputAction.done,
                          inputType: TextInputType.visiblePassword,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          onChanged: (String text) => setState(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GetBuilder<ForgotPasswordController>(
                        builder: (forgotPasswordController) {
                      return !forgotPasswordController.isLoading
                          ? CustomButtonWidget(
                              buttonText: 'confirm_btn'.tr,
                              backgroundColor: const Color(0xFF0D77BC),
                              onPressed: () => _newPasswordController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _confirmPasswordController.text
                                          .trim()
                                          .isNotEmpty
                                  ? _resetPassword(authController)
                                  : null,
                            )
                          : const Center(child: CircularProgressIndicator());
                    }),
                    const SizedBox(height: 30),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _resetPassword(AuthController authController) {
    String password = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    } else if (password.length < 8) {
      showCustomSnackBar('password_should_be'.tr);
    } else if (password != confirmPassword) {
      showCustomSnackBar('password_does_not_matched'.tr);
    } else if (!authController.spatialCheck ||
        !authController.lowercaseCheck ||
        !authController.uppercaseCheck ||
        !authController.numberCheck ||
        !authController.lengthCheck) {
      showCustomSnackBar('provide_valid_password'.tr);
    } else {
      if (widget.fromPasswordChange) {
        ProfileModel user = Get.find<ProfileController>().profileModel!;
        Get.find<ForgotPasswordController>().changePassword(user, password);
      } else {
        Get.find<ForgotPasswordController>()
            .resetPassword(widget.resetToken, widget.number!.trim(), password,
                confirmPassword)
            .then((value) {
          if (value.isSuccess) {
            Get.find<AuthController>()
                .login(widget.number!.trim(), password)
                .then((value) async {
              Get.offAllNamed(RouteHelper.getInitialRoute());
            });
          } else {
            showCustomSnackBar(value.message);
          }
        });
      }
    }
  }
}
