import '../common/http_service.dart';
import '../config/sdk_config.dart';

/// 支付方式枚举
enum PaymentMethod {
  /// 微信支付
  wechat,
  
  /// 支付宝
  alipay,
  
  /// 银行卡
  bankCard,
  
  /// 余额支付
  balance,
  
  /// 其他方式
  other,
}

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
  
  /// 支付链接
  final String? paymentUrl;
  
  /// 订单状态
  final String? status;
  
  /// 支付方式
  final PaymentMethod? paymentMethod;
  
  /// 原始支付数据
  final Map<String, dynamic>? rawData;

  /// 创建支付结果实例
  const PaymentResult({
    this.success = false,
    this.errorMessage,
    this.orderId,
    this.transactionId,
    this.paymentUrl,
    this.status,
    this.paymentMethod,
    this.rawData,
  });

  /// 创建成功的支付结果
  factory PaymentResult.success({
    required String orderId,
    String? transactionId,
    String? paymentUrl,
    String? status,
    PaymentMethod? paymentMethod,
    Map<String, dynamic>? rawData,
  }) {
    return PaymentResult(
      success: true,
      orderId: orderId,
      transactionId: transactionId,
      paymentUrl: paymentUrl,
      status: status,
      paymentMethod: paymentMethod,
      rawData: rawData,
    );
  }

  /// 创建失败的支付结果
  factory PaymentResult.failure(String errorMessage, {
    String? orderId,
    Map<String, dynamic>? rawData,
  }) {
    return PaymentResult(
      success: false,
      errorMessage: errorMessage,
      orderId: orderId,
      rawData: rawData,
    );
  }
  
  /// 将支付方式字符串转换为枚举
  static PaymentMethod? parsePaymentMethod(String? method) {
    if (method == null) return null;
    
    switch (method.toLowerCase()) {
      case 'wechat':
      case 'weixin':
      case 'wechatpay':
      case 'wx':
        return PaymentMethod.wechat;
      case 'alipay':
      case 'ali':
      case 'zhifubao':
        return PaymentMethod.alipay;
      case 'bank':
      case 'bankcard':
      case 'card':
        return PaymentMethod.bankCard;
      case 'balance':
      case 'wallet':
        return PaymentMethod.balance;
      default:
        return PaymentMethod.other;
    }
  }
}

/// 支付服务，提供支付功能
class PaymentService {
  /// HTTP服务实例
  final HttpService _httpService;
  
  /// SDK配置
  final SDKConfig _config;

  /// 创建支付服务实例
  /// 
  /// [httpService] HTTP服务实例
  /// [config] SDK配置
  PaymentService(this._httpService, this._config);

  /// 支付订单
  /// 
  /// [orderId] 订单ID
  /// [amount] 金额
  /// [currency] 货币代码，默认为CNY
  /// [method] 支付方式，可选
  /// [description] 订单描述，可选
  /// [metadata] 元数据，可选
  Future<PaymentResult> payOrder(
    String orderId, {
    required double amount,
    String currency = 'CNY',
    PaymentMethod? method,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_config.useXadminAuth) {
        return _xadminPayOrder(
          orderId,
          amount: amount,
          currency: currency,
          method: method,
          description: description,
          metadata: metadata,
        );
      } else {
        return _standardPayOrder(
          orderId,
          amount: amount,
          currency: currency,
          method: method,
          description: description,
          metadata: metadata,
        );
      }
    } catch (e) {
      if (_config.debug) {
        print('支付请求失败: $e');
      }
      return PaymentResult.failure('支付请求失败: $e', orderId: orderId);
    }
  }
  
  /// 标准支付订单
  Future<PaymentResult> _standardPayOrder(
    String orderId, {
    required double amount,
    String currency = 'CNY',
    PaymentMethod? method,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _httpService.post(
      '/pay/order',
      data: {
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        if (method != null) 'method': method.toString().split('.').last,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    if (response.statusCode == 200 && data['success'] == true) {
      final transactionId = data['transactionId'] as String?;
      final paymentUrl = data['paymentUrl'] as String?;
      final status = data['status'] as String?;
      final methodStr = data['method'] as String?;
      
      return PaymentResult.success(
        orderId: orderId,
        transactionId: transactionId,
        paymentUrl: paymentUrl,
        status: status,
        paymentMethod: PaymentResult.parsePaymentMethod(methodStr),
        rawData: data,
      );
    } else {
      final message = data['message'] as String? ?? '支付失败';
      return PaymentResult.failure(message, orderId: orderId, rawData: data);
    }
  }
  
  /// Xadmin支付订单
  Future<PaymentResult> _xadminPayOrder(
    String orderId, {
    required double amount,
    String currency = 'CNY',
    PaymentMethod? method,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    // 适配Xadmin API格式
    final methodStr = method != null ? method.toString().split('.').last : null;
    
    final response = await _httpService.post(
      '/payments/create/',
      data: {
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        if (methodStr != null) 'payment_method': methodStr,
        if (description != null) 'description': description,
        if (metadata != null) 'metadata': metadata,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final transactionId = data['transaction_id'] as String?;
      final paymentUrl = data['payment_url'] as String?;
      final status = data['status'] as String?;
      final methodStr = data['payment_method'] as String?;
      
      return PaymentResult.success(
        orderId: orderId,
        transactionId: transactionId,
        paymentUrl: paymentUrl,
        status: status,
        paymentMethod: PaymentResult.parsePaymentMethod(methodStr),
        rawData: data,
      );
    } else {
      final message = response.data is Map ? 
        (response.data['detail'] ?? response.data['message'] ?? '支付失败') : 
        '支付失败';
      return PaymentResult.failure(message.toString(), orderId: orderId);
    }
  }

  /// 查询支付结果
  /// 
  /// [orderId] 订单ID
  Future<PaymentResult> queryPaymentResult(String orderId) async {
    try {
      if (_config.useXadminAuth) {
        return _xadminQueryPayment(orderId);
      } else {
        return _standardQueryPayment(orderId);
      }
    } catch (e) {
      if (_config.debug) {
        print('查询支付结果请求失败: $e');
      }
      return PaymentResult.failure('查询支付结果请求失败: $e', orderId: orderId);
    }
  }
  
  /// 标准查询支付结果
  Future<PaymentResult> _standardQueryPayment(String orderId) async {
    final response = await _httpService.get(
      '/pay/query',
      queryParameters: {'orderId': orderId},
    );

    final data = response.data as Map<String, dynamic>;
    
    if (response.statusCode == 200 && data['success'] == true) {
      final paymentData = data['data'] as Map<String, dynamic>;
      final transactionId = paymentData['transactionId'] as String?;
      final status = paymentData['status'] as String?;
      final methodStr = paymentData['method'] as String?;
      
      return PaymentResult.success(
        orderId: orderId,
        transactionId: transactionId,
        status: status,
        paymentMethod: PaymentResult.parsePaymentMethod(methodStr),
        rawData: paymentData,
      );
    } else {
      final message = data['message'] as String? ?? '查询支付结果失败';
      return PaymentResult.failure(message, orderId: orderId);
    }
  }
  
  /// Xadmin查询支付结果
  Future<PaymentResult> _xadminQueryPayment(String orderId) async {
    final response = await _httpService.get(
      '/payments/query/',
      queryParameters: {'order_id': orderId},
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final transactionId = data['transaction_id'] as String?;
      final status = data['status'] as String?;
      final methodStr = data['payment_method'] as String?;
      
      return PaymentResult.success(
        orderId: orderId,
        transactionId: transactionId,
        status: status,
        paymentMethod: PaymentResult.parsePaymentMethod(methodStr),
        rawData: data,
      );
    } else {
      final message = response.data is Map ? 
        (response.data['detail'] ?? '查询支付结果失败') : 
        '查询支付结果失败';
      return PaymentResult.failure(message.toString(), orderId: orderId);
    }
  }
  
  /// 取消支付
  /// 
  /// [orderId] 订单ID
  Future<PaymentResult> cancelPayment(String orderId) async {
    try {
      final endpoint = _config.useXadminAuth ? '/payments/cancel/' : '/pay/cancel';
      final param = _config.useXadminAuth ? {'order_id': orderId} : {'orderId': orderId};
      
      final response = await _httpService.post(
        endpoint,
        data: param,
      );
      
      if (response.statusCode == 200) {
        return PaymentResult.success(
          orderId: orderId,
          status: 'cancelled',
          rawData: response.data is Map ? response.data as Map<String, dynamic> : null,
        );
      } else {
        final message = response.data is Map ? 
          (response.data['detail'] ?? response.data['message'] ?? '取消支付失败') : 
          '取消支付失败';
        return PaymentResult.failure(message.toString(), orderId: orderId);
      }
    } catch (e) {
      return PaymentResult.failure('取消支付请求失败: $e', orderId: orderId);
    }
  }
}