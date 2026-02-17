import 'package:yalla_now_delivery/features/profile/domain/models/profile_model.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileModel? profileModel;

  const ProfileInfoCard({super.key, required this.profileModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'account_info'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _buildInfoItem(
              context,
              'full_name'.tr,
              '${profileModel?.fName ?? ''} ${profileModel?.lName ?? ''}',
              Icons.person_outline),
          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Divider(),
          ),
          _buildInfoItem(context, 'phone_number'.tr, profileModel?.phone ?? '',
              Icons.phone),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
            ),
            Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          ],
        ),
      ],
    );
  }
}
