import 'package:yalla_now_delivery/common/models/response_model.dart';
import 'package:yalla_now_delivery/features/cash_in_hand/domain/models/wallet_payment_model.dart';

abstract class CashInHandServiceInterface {
  Future<ResponseModel> makeCollectCashPayment(
      double amount, String paymentGatewayName);
  Future<List<Transactions>?> getWalletPaymentList();
  Future<List<Transactions>?> getWalletProvidedEarningList();
  Future<ResponseModel> makeWalletAdjustment();
}
