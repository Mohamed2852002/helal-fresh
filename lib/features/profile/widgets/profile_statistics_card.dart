import 'package:yalla_now_delivery/features/profile/domain/models/profile_model.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileStatisticsCard extends StatelessWidget {
  final ProfileModel? profileModel;

  const ProfileStatisticsCard({super.key, required this.profileModel});

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
          Row(
            children: [
              Text(
                'statistics'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(width: 5),
              Icon(Icons.trending_up, color: Theme.of(context).primaryColor),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  context,
                  'on_time_delivery'.tr,
                  '96.2%', // Placeholder
                  Colors.blue[50]!,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: _buildStatBox(
                  context,
                  'completion_rate'.tr,
                  '98.5%', // Placeholder
                  Colors.green[50]!,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Colors.orange[50], // Light orange background for date
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align to right for Arabic
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'join_date'.tr,
                      style: robotoRegular.copyWith(
                        color: Colors.brown,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      profileModel?.createdAt != null
                          ? DateFormat('MMMM yyyy')
                              .format(DateTime.parse(profileModel!.createdAt!))
                          : '',
                      style: robotoBold.copyWith(
                        color: Colors.deepOrange,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                const Icon(Icons.calendar_today, color: Colors.deepOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String title, String value,
      Color bgColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, size: 16, color: accentColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeExtraLarge,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
