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
  
  /// xadmin集成相关配置
  final bool useXadminAuth;      // 是否使用xadmin认证系统
  final String xadminApiPrefix;  // xadmin API前缀，默认为'/api'
  final bool useXadminPermission; // 是否使用xadmin权限系统
  
  /// SDK运行环境
  final SDKEnvironment environment;

  /// 创建SDK配置实例
  /// 
  /// [appId] 应用ID，必填项
  /// [serverUrl] 服务器URL，必填项
  /// [debug] 是否开启调试模式，默认为false
  /// [useXadminAuth] 是否使用xadmin认证系统，默认为false
  /// [xadminApiPrefix] xadmin API前缀，默认为'/api'
  /// [useXadminPermission] 是否使用xadmin权限系统，默认为false
  /// [environment] SDK运行环境，默认为生产环境
  const SDKConfig({
    required this.appId,
    required this.serverUrl,
    this.debug = false,
    this.useXadminAuth = false,
    this.xadminApiPrefix = '/api',
    this.useXadminPermission = false,
    this.environment = SDKEnvironment.production,
  });

  /// 创建开发环境配置
  factory SDKConfig.dev({
    required String appId,
    required String serverUrl,
    bool debug = true,
    bool useXadminAuth = false,
    String xadminApiPrefix = '/api',
    bool useXadminPermission = false,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      useXadminAuth: useXadminAuth,
      xadminApiPrefix: xadminApiPrefix,
      useXadminPermission: useXadminPermission,
      environment: SDKEnvironment.dev,
    );
  }

  /// 创建测试环境配置
  factory SDKConfig.staging({
    required String appId,
    required String serverUrl,
    bool debug = true,
    bool useXadminAuth = false,
    String xadminApiPrefix = '/api',
    bool useXadminPermission = false,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      useXadminAuth: useXadminAuth,
      xadminApiPrefix: xadminApiPrefix,
      useXadminPermission: useXadminPermission,
      environment: SDKEnvironment.staging,
    );
  }

  /// 创建生产环境配置
  factory SDKConfig.production({
    required String appId,
    required String serverUrl,
    bool debug = false,
    bool useXadminAuth = false,
    String xadminApiPrefix = '/api',
    bool useXadminPermission = false,
  }) {
    return SDKConfig(
      appId: appId,
      serverUrl: serverUrl,
      debug: debug,
      useXadminAuth: useXadminAuth,
      xadminApiPrefix: xadminApiPrefix,
      useXadminPermission: useXadminPermission,
      environment: SDKEnvironment.production,
    );
  }
}

enum Environment {
  development,
  staging,
  production,
}