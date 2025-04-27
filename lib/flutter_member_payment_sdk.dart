library flutter_member_payment_sdk;

// 导出配置
export 'config/sdk_config.dart';

// 导出认证模块
export 'auth/auth_service.dart';

// 导出会员模块
export 'member/member_service.dart';

// 导出支付模块
export 'payment/payment_service.dart';

import 'auth/auth_service.dart';
import 'auth/auth_storage.dart';
import 'common/http_service.dart';
import 'config/sdk_config.dart';
import 'member/member_service.dart';
import 'payment/payment_service.dart';

/// Flutter会员支付SDK
/// 提供一站式登录、会员管理和支付解决方案
class FlutterMemberPaymentSDK {
  /// 私有构造函数，使用单例模式
  FlutterMemberPaymentSDK._();

  /// SDK单例实例
  static final FlutterMemberPaymentSDK _instance = FlutterMemberPaymentSDK._();

  /// 获取SDK实例
  static FlutterMemberPaymentSDK get instance => _instance;

  /// SDK是否已初始化
  bool _isInitialized = false;

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// SDK配置
  late final SDKConfig _config;

  /// HTTP服务
  late final HttpService _httpService;

  /// 认证服务
  late final AuthService _authService;

  /// 会员服务
  late final MemberService _memberService;

  /// 支付服务
  late final PaymentService _paymentService;

  /// 获取认证服务实例
  AuthService get auth => _checkInitAndGet(_authService, '认证服务');

  /// 获取会员服务实例
  MemberService get member => _checkInitAndGet(_memberService, '会员服务');

  /// 获取支付服务实例
  PaymentService get payment => _checkInitAndGet(_paymentService, '支付服务');
  
  /// 获取SDK配置
  SDKConfig get config => _config;

  /// 检查服务是否初始化并返回服务实例
  T _checkInitAndGet<T>(T service, String serviceName) {
    if (!_isInitialized) {
      throw Exception('SDK未初始化，请先调用initialize方法');
    }
    return service;
  }

  /// 初始化SDK
  /// 
  /// [config] SDK配置
  Future<void> initialize(SDKConfig config) async {
    if (_isInitialized) {
      print('SDK已经初始化');
      return;
    }

    try {
      _config = config;

      // 初始化网络服务
      _httpService = HttpService(_config);

      // 初始化认证服务
      _authService = AuthService(_httpService, _config);
      await _authService.initialize();

      // 初始化会员服务
      _memberService = MemberService(_httpService, _config);

      // 初始化支付服务
      _paymentService = PaymentService(_httpService, _config);

      _isInitialized = true;
      
      if (_config.debug) {
        print('SDK初始化成功');
        if (_config.useXadminAuth) {
          print('已启用Xadmin认证系统');
        }
        if (_config.useXadminPermission) {
          print('已启用Xadmin权限系统');
        }
      }
    } catch (e) {
      if (_config.debug) {
        print('SDK初始化失败: $e');
      }
      rethrow;
    }
  }
  
  /// 销毁SDK，清理资源
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }
    
    try {
      // 清除认证信息
      if (_authService.isLoggedIn()) {
        await _authService.logout();
      }
      
      // 清除会员缓存
      _memberService.clearCache();
      
      _isInitialized = false;
      
      if (_config.debug) {
        print('SDK已销毁');
      }
    } catch (e) {
      if (_config.debug) {
        print('SDK销毁时发生错误: $e');
      }
    }
  }
  
  /// 获取SDK版本
  String get version => '1.0.0';
  
  /// 设置Xadmin特定请求头
  void setXadminHeaders(Map<String, dynamic> headers) {
    if (_isInitialized) {
      _httpService.setXadminHeaders(headers);
    }
  }
}