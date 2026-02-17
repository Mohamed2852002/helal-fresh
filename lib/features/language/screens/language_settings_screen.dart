import 'package:yalla_now_delivery/features/language/controllers/language_controller.dart';
import 'package:yalla_now_delivery/util/app_constants.dart';
import 'package:yalla_now_delivery/util/dimensions.dart';
import 'package:yalla_now_delivery/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('language'.tr,
            style: robotoMedium.copyWith(fontSize: 18, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body:
          GetBuilder<LocalizationController>(builder: (localizationController) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.language,
                        color: Theme.of(context).primaryColor, size: 30),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('choose_app_language'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor)),
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                          Text('select_preferred_language'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Available Languages
              Text('available_languages'.tr,
                  style:
                      robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isSelected =
                      localizationController.selectedLanguageIndex == index;
                  return InkWell(
                    onTap: () {
                      localizationController.setLanguage(Locale(
                        AppConstants.languages[index].languageCode!,
                        AppConstants.languages[index].countryCode,
                      ));
                      localizationController.setSelectLanguageIndex(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusDefault),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5)
                        ],
                        border: isSelected
                            ? Border.all(color: Theme.of(context).primaryColor)
                            : null,
                      ),
                      child: Row(
                        children: [
                          isSelected
                              ? Icon(Icons.check_circle,
                                  color: Theme.of(context).primaryColor)
                              : Icon(Icons.radio_button_unchecked,
                                  color: Theme.of(context).disabledColor),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    localizationController
                                        .languages[index].languageName!.tr,
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeLarge)),
                                Text(
                                    localizationController.languages[index]
                                        .languageName!, // English name if possible?
                                    style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color:
                                            Theme.of(context).disabledColor)),
                              ],
                            ),
                          ),
                          Image.asset(
                              localizationController.languages[index].imageUrl!,
                              width: 25,
                              height: 25),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Note Section
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text('language_change_note'.tr,
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault)),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'language_change_note_text'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Current Language Footer
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.language,
                          color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('current_language'.tr,
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall)),
                        Text(
                            AppConstants
                                .languages[localizationController
                                    .selectedLanguageIndex]
                                .languageName!,
                            style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge)),
                      ],
                    ),
                    const Spacer(),
                    Image.asset(
                        AppConstants
                            .languages[
                                localizationController.selectedLanguageIndex]
                            .imageUrl!,
                        width: 25,
                        height: 25),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
