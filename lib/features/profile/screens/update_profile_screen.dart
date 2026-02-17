import 'dart:io';
import 'package:yalla_now_delivery/features/auth/controllers/auth_controller.dart';
import 'package:yalla_now_delivery/features/profile/controllers/profile_controller.dart';
import 'package:yalla_now_delivery/features/profile/domain/models/profile_model.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:yalla_now_delivery/common/widgets/custom_button_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_image_widget.dart';
import 'package:yalla_now_delivery/common/widgets/custom_snackbar_widget.dart';
import 'package:yalla_now_delivery/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (Get.find<ProfileController>().profileModel == null) {
      Get.find<ProfileController>().getProfile();
    }
    Get.find<ProfileController>().initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match white background of the card area
      body: GetBuilder<ProfileController>(builder: (profileController) {
        if (profileController.profileModel != null &&
            _fullNameController.text.isEmpty) {
          _fullNameController.text =
              '${profileController.profileModel!.fName ?? ''} ${profileController.profileModel!.lName ?? ''}'
                  .trim();
          _phoneController.text = profileController.profileModel!.phone ?? '';
        }

        return profileController.profileModel != null
            ? Column(
                children: [
                  // Custom Blue Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: const EdgeInsets.only(
                        top: 50, bottom: 20, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Get.back(),
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              // RTL aware
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'profile'.tr,
                                    style: robotoBold.copyWith(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  Text(
                                    'your_info_and_stats'.tr,
                                    style: robotoRegular.copyWith(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            // Custom Back/Cancel Button style
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'cancel'
                                          .tr, // Assuming cancel key exists or verify
                                      style: robotoMedium.copyWith(
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.edit_off_outlined,
                                        color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Profile Info in blue area
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${profileController.profileModel!.fName} ${profileController.profileModel!.lName}',
                                style: robotoBold.copyWith(
                                    fontSize: 22, color: Colors.white),
                              ),
                              Text(
                                '#${profileController.profileModel!.id}', // Assuming simplified ID
                                style: robotoRegular.copyWith(
                                    color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _buildStatPill(
                                    context,
                                    '${profileController.profileModel!.orderCount} ${'deliveries'.tr}',
                                    Colors.white.withOpacity(0.2),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatPill(
                                    context,
                                    '${profileController.profileModel!.avgRating}',
                                    Theme.of(context).primaryColor,
                                    icon: Icons.star,
                                    isRating: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Stack(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: ClipOval(
                                child: profileController.pickedFile != null
                                    ? GetPlatform.isWeb
                                        ? Image.network(
                                            profileController.pickedFile!.path,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover)
                                        : Image.file(
                                            File(profileController
                                                .pickedFile!.path),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover)
                                    : CustomImageWidget(
                                        image:
                                            '${profileController.profileModel!.imageFullUrl}',
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => profileController.pickImage(),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      size: 16,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // White Form Area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            TextFieldWidget(
                              hintText: 'full_name'.tr,
                              controller: _fullNameController,
                              focusNode: _fullNameFocus,
                              nextFocus: _phoneFocus,
                              inputType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                              suffixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            const SizedBox(
                                height: Dimensions.paddingSizeExtraSmall),
                            TextFieldWidget(
                              hintText: 'phone'.tr,
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              inputType: TextInputType.phone,
                              isEnabled:
                                  false, // Phone usually not editable here?
                              suffixIcon: Icon(
                                Icons.phone,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 30),
                            !profileController.isLoading
                                ? CustomButtonWidget(
                                    onPressed: () =>
                                        _updateProfile(profileController),
                                    buttonText: 'save_changes'.tr,
                                  )
                                : const Center(
                                    child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget _buildStatPill(BuildContext context, String text, Color bgColor,
      {IconData? icon, bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2), // Rating yellow/orange
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: robotoMedium.copyWith(color: Colors.white, fontSize: 12),
          ),
          if (icon != null) ...[
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: Colors.yellow),
          ],
        ],
      ),
    );
  }

  void _updateProfile(ProfileController profileController) async {
    String fullName = _fullNameController.text.trim();

    // Simple split logic: First word is First Name, rest is Last Name
    String firstName = '';
    String lastName = '';

    if (fullName.isNotEmpty) {
      List<String> nameParts = fullName.split(' ');
      if (nameParts.isNotEmpty) {
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }
    }

    String email =
        profileController.profileModel!.email ?? ''; // Keep existing email
    String phoneNumber = _phoneController.text
        .trim(); // Keep phone if editable or logic requires

    if (profileController.profileModel!.fName == firstName &&
        profileController.profileModel!.lName == lastName &&
        profileController.profileModel!.phone == phoneNumber &&
        profileController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    } else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr); // Or "Enter full name"
    } else {
      ProfileModel updatedUser = ProfileModel(
          fName: firstName, lName: lastName, email: email, phone: phoneNumber);
      profileController
          .updateUserInfo(
              updatedUser, Get.find<AuthController>().getUserToken())
          .then((isSuccess) async {
        if (isSuccess) {
          await profileController.getProfile();
        }
      });
    }
  }
}
