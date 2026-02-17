import 'package:get/get.dart';
import 'package:yalla_now_delivery/common/models/config_model.dart';
import 'package:yalla_now_delivery/features/splash/domain/services/splash_service_interface.dart';

class SplashController extends GetxController implements GetxService {
  final SplashServiceInterface splashServiceInterface;
  SplashController({required this.splashServiceInterface});

  ConfigModel? _configModel;
  ConfigModel? get configModel => _configModel;

  bool _firstTimeConnectionCheck = true;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  int? _storeCategoryID;
  int? get storeCategoryID => _storeCategoryID;

  String? _storeType;
  String? get storeType => _storeType;

  Map<String, dynamic>? _data = {};

  DateTime get currentTime => DateTime.now();

  Module getModuleConfig(String? moduleType) {
    Module module = Module.fromJson(_data!['module_config'][moduleType]);
    moduleType == 'food'
        ? module.newVariation = true
        : module.newVariation = false;
    return module;
  }

  Future<bool> getConfigData() async {
    Response response = await splashServiceInterface.getConfigData();
    bool isSuccess = false;
    print('====> Config statusCode: ${response.statusCode}');
    print('====> Config body type: ${response.body.runtimeType}');
    print(
        '====> Config body snippet: ${response.body.toString().substring(0, response.body.toString().length > 200 ? 200 : response.body.toString().length)}');
    if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
      _data = response.body;
      _configModel = ConfigModel.fromJson(response.body);
      print('Config Data: ${_configModel!.webSocketUri}');
      print('Config Data: ${_configModel!.webSocketPort}');
      print('Config Data: ${_configModel!.webSocketKey}');

      isSuccess = true;
    } else if (response.statusCode == 200) {
      print('Error: API returned 200 but body is not a Map: ${response.body}');
    } else {
      isSuccess = false;
    }
    update();
    return isSuccess;
  }

  Module getModule(String? moduleType) =>
      Module.fromJson(_data!['module_config'][moduleType]);

  Future<bool> initSharedData() {
    return splashServiceInterface.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashServiceInterface.removeSharedData();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }
}
