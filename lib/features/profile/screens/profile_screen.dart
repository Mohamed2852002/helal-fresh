import 'package:flutter_svg/svg.dart';
import 'package:yalla_now_delivery/features/auth/controllers/auth_controller.dart';
import 'package:yalla_now_delivery/features/language/controllers/language_controller.dart';
import 'package:yalla_now_delivery/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/features/profile/widgets/profile_info_card.dart';
import 'package:yalla_now_delivery/features/profile/widgets/profile_statistics_card.dart';
import 'package:yalla_now_delivery/common/widgets/confirmation_dialog_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_image_widget.dart';
import 'package:yalla_now_delivery/helper/route_helper.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/images.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/features/language/screens/language_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<ProfileController>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        if (profileController.profileModel == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(
                  top: 50, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'profile_user'.tr,
                    style:
                        robotoBold.copyWith(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        image:
                            '${profileController.profileModel!.imageFullUrl}',
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    ProfileInfoCard(
                        profileModel: profileController.profileModel),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Edit Profile Button
                    _buildOptionButton(
                      context,
                      'edit_profile'.tr,
                      Icons.edit_outlined,
                      () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
                      isSvg: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // Language Button
                    _buildOptionButton(
                      context,
                      'language'.tr,
                      Icons.language,
                      () => Get.to(() => const LanguageSettingsScreen()),
                      isLanguage: true,
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    ProfileStatisticsCard(
                        profileModel: profileController.profileModel),

                    const SizedBox(height: 30),

                    // Logout Button
                    InkWell(
                      onTap: () {
                        Get.dialog(ConfirmationDialogWidget(
                          icon: Images.support,
                          description: 'are_you_sure_to_logout'.tr,
                          isLogOut: true,
                          onYesPressed: () {
                            Get.find<AuthController>().clearSharedData();
                            Get.find<ProfileController>().stopLocationRecord();
                            Get.offAllNamed(RouteHelper.getSignInRoute());
                          },
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout,
                                color: Colors
                                    .red), // Flipped icon direction if needed for RTL? Default is fine usually.
                            const SizedBox(width: 8),
                            Text(
                              'logout'.tr,
                              style: robotoBold.copyWith(
                                  color: Colors.red,
                                  fontSize: Dimensions.fontSizeLarge),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOptionButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap,
      {bool isLanguage = false, bool isSvg = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .disabledColor), // Arrow on left for RTL look in design?
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                if (isLanguage)
                  Text(
                    'Arabic', // Placeholder or dynamic logic
                    style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0FF), // Light purple/blue bg
                borderRadius: BorderRadius.circular(8),
              ),
              child: isSvg
                  ? SvgPicture.asset(Images.editIcon)
                  : Icon(icon, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
