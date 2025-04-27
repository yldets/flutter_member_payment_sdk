import '../common/http_service.dart';

/// 支付结果模型
class PaymentResult {
  /// 是否成功
  final bool success;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 订单ID
  final String? orderId;
  
  /// 交易ID
  final String? transactionId;

  /// 创建支付结果实例
  const PaymentResult({
    this.success = false,
    this.errorMessage,
    this.orderId,
    this.transactionId,
  });

  /// 创建成功的支付结果
  factory PaymentResult.success({
    required String orderId,
    String? transactionId,
  }) {
    return PaymentResult(
      success: true,
      orderId: orderId,
      transactionId: transactionId,
    );
  }

  /// 创建失败的支付结果
  factory PaymentResult.failure(String errorMessage, {String? orderId}) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      orderId: orderId,
    );
  }
}

/// 支付服务，提供支付功能
class PaymentService {
  /// HTTP服务实例
  final HttpService _httpService;

  /// 创建支付服务实例
  /// 
  /// [httpService] HTTP服务实例
  PaymentService(this._httpService);

  /// 支付订单
  /// 
  /// [orderId] 订单ID
  /// [amount] 金额
  /// [currency] 货币代码，默认为CNY
  Future<PaymentResult> payOrder(
    String orderId, {
    required double amount,
    String currency = 'CNY',
  }) async {
    try {
      final response = await _httpService.post(
        '/pay/order',
        data: {
          'orderId': orderId,
          'amount': amount,
          'currency': currency,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final transactionId = data['transactionId'] as String?;
        
        return PaymentResult.success(
          orderId: orderId,
          transactionId: transactionId,
        );
      } else {
        final message = data['message'] as String? ?? '支付失败';
        return PaymentResult.failure(message, orderId: orderId);
      }
    } catch (e) {
      return PaymentResult.failure('支付请求失败: $e', orderId: orderId);
    }
  }

  /// 查询支付结果
  /// 
  /// [orderId] 订单ID
  Future<PaymentResult> queryPaymentResult(String orderId) async {
    try {
      final response = await _httpService.get(
        '/pay/query',
        queryParameters: {'orderId': orderId},
      );

      final data = response.data as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final paymentData = data['data'] as Map<String, dynamic>;
        final transactionId = paymentData['transactionId'] as String?;
        
        return PaymentResult.success(
          orderId: orderId,
          transactionId: transactionId,
        );
      } else {
        final message = data['message'] as String? ?? '查询支付结果失败';
        return PaymentResult.failure(message, orderId: orderId);
      }
    } catch (e) {
      return PaymentResult.failure('查询支付结果请求失败: $e', orderId: orderId);
    }
  }
}