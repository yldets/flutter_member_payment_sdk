/// SDK环境枚举
enum SDKEnvironment {
  /// 开发环境
  dev,
  
  /// 测试环境
  staging,
  
  /// 生产环境
  production,
}

/// SDK配置类
class SDKConfig {
  /// 应用ID
  final String appId;
  
  /// 服务器URL
  final String serverUrl;
  
  /// 是否开启调试模式
  final bool debug;
  
  /// SDK运行环境
  final SDKEnvironment environment;

  /// 创建SDK配置实例
  /// 
  /// [appId] 应用ID，必填项
  /// [serverUrl] 服务器URL，必填项
  /// [debug] 是否开启调试模式，默认为false
  /// [environment] SDK运行环境，默认为生产环境
  const SDKConfig({
    required this.appId,
    required this.serverUrl,
    this.debug = false,
    this.environment = SDKEnvironment.production,
  });

  /// 创建开发环境配置
  factory SDKConfig.dev({
    required String appId,
    required String serverUrl,
    bool debug = true,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      environment: SDKEnvironment.dev,
    );
  }

  /// 创建测试环境配置
  factory SDKConfig.staging({
    required String appId,
    required String serverUrl,
    bool debug = true,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      environment: SDKEnvironment.staging,
    );
  }

  /// 创建生产环境配置
  factory SDKConfig.production({
    required String appId,
    required String serverUrl,
    bool debug = false,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      environment: SDKEnvironment.production,
    );
  }
}