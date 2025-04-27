import '../common/http_service.dart';
import 'auth_storage.dart';
import '../config/sdk_config.dart';

/// 认证结果模型
class AuthResult {
  /// 是否成功
  final bool success;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 用户ID
  final String? userId;
  
  /// 访问令牌
  final String? accessToken;
  
  /// 刷新令牌
  final String? refreshToken;
  
  /// 用户信息
  final Map<String, dynamic>? userInfo;

  /// 创建认证结果实例
  const AuthResult({
    this.success = false,
    this.errorMessage,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.userInfo,
  });

  /// 创建成功的认证结果
  factory AuthResult.success({
    required String userId,
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? userInfo,
  }) {
    return AuthResult(
      success: true,
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      userInfo: userInfo,
    );
  }

  /// 创建失败的认证结果
  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 认证服务，提供登录、登出等功能
class AuthService {
  /// HTTP服务实例
  final HttpService _httpService;
  
  /// 认证存储实例
  final AuthStorage _authStorage;
  
  /// SDK配置
  final SDKConfig _config;

  /// 创建认证服务实例
  /// 
  /// [httpService] HTTP服务实例
  /// [config] SDK配置
  AuthService(this._httpService, this._config) : _authStorage = AuthStorage.instance;

  /// 初始化认证服务
  Future<void> initialize() async {
    await _authStorage.initialize();
    
    // 如果存在令牌，则设置到HTTP服务
    final token = _authStorage.getAccessToken();
    if (token != null) {
      _httpService.setToken(token);
    }
  }

  /// 使用用户名和密码登录
  /// 
  /// [username] 用户名
  /// [password] 密码
  Future<AuthResult> login(String username, String password) async {
    try {
      if (_config.useXadminAuth) {
        return _xadminLogin(username, password);
      } else {
        return _standardLogin(username, password);
      }
    } catch (e) {
      return AuthResult.failure('登录请求失败: $e');
    }
  }
  
  /// 标准登录流程
  Future<AuthResult> _standardLogin(String username, String password) async {
    final response = await _httpService.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    if (response.statusCode == 200 && data['success'] == true) {
      final userId = data['userId'] as String;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String?;

      // 保存认证信息
      await _authStorage.saveUserId(userId);
      await _authStorage.saveAccessToken(accessToken);
      if (refreshToken != null) {
        await _authStorage.saveRefreshToken(refreshToken);
      }

      // 设置HTTP服务的认证头
      _httpService.setToken(accessToken);

      return AuthResult.success(
        userId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } else {
      final message = data['message'] as String? ?? '登录失败';
      return AuthResult.failure(message);
    }
  }
  
  /// Xadmin登录流程
  Future<AuthResult> _xadminLogin(String username, String password) async {
    final response = await _httpService.post(
      '/auth/jwt/create/',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    
    if (response.statusCode == 200) {
      // Xadmin返回的token格式通常是access和refresh
      final accessToken = data['access'] as String;
      final refreshToken = data['refresh'] as String?;
      
      // 获取用户信息
      final userInfo = await _fetchXadminUserInfo(accessToken);
      final userId = userInfo['id']?.toString() ?? '';
      
      // 保存认证信息
      await _authStorage.saveUserId(userId);
      await _authStorage.saveAccessToken(accessToken);
      if (refreshToken != null) {
        await _authStorage.saveRefreshToken(refreshToken);
      }
      
      // 保存用户信息
      await _authStorage.saveUserInfo(userInfo);

      // 设置HTTP服务的认证头
      _httpService.setToken(accessToken);

      return AuthResult.success(
        userId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        userInfo: userInfo,
      );
    } else {
      final message = data['detail'] as String? ?? '登录失败';
      return AuthResult.failure(message);
    }
  }
  
  /// 获取Xadmin用户信息
  Future<Map<String, dynamic>> _fetchXadminUserInfo(String token) async {
    try {
      final response = await _httpService.get('/auth/users/me/');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (_config.debug) {
        print('获取用户信息失败: $e');
      }
      return {};
    }
  }
  
  /// 刷新Token
  Future<bool> refreshToken() async {
    final refreshToken = _authStorage.getRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    
    try {
      final endpoint = _config.useXadminAuth ? '/auth/jwt/refresh/' : '/auth/refresh';
      final data = _config.useXadminAuth ? {'refresh': refreshToken} : {'refreshToken': refreshToken};
      
      final response = await _httpService.post(
        endpoint,
        data: data,
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final newToken = _config.useXadminAuth
            ? responseData['access'] as String
            : responseData['accessToken'] as String;
            
        await _authStorage.saveAccessToken(newToken);
        _httpService.setToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      if (_config.debug) {
        print('Token刷新失败: $e');
      }
      return false;
    }
  }

  /// 登出
  Future<bool> logout() async {
    try {
      // 调用登出API
      if (_config.useXadminAuth) {
        // Xadmin通常不需要调用登出API，只需清除本地令牌
      } else {
        await _httpService.post('/auth/logout');
      }
      
      // 无论API调用是否成功，都清除本地存储
      await _authStorage.clearAll();
      _httpService.clearToken();
      
      return true;
    } catch (e) {
      // 即使API调用失败，仍然清除本地存储
      await _authStorage.clearAll();
      _httpService.clearToken();
      
      return false;
    }
  }

  /// 检查用户是否已登录
  bool isLoggedIn() {
    return _authStorage.isLoggedIn();
  }

  /// 获取当前用户ID
  String? getUserId() {
    return _authStorage.getUserId();
  }
  
  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    return _authStorage.getUserInfo();
  }
  
  /// 获取用户权限
  Future<List<String>> getUserPermissions() async {
    if (!_config.useXadminPermission) {
      return [];
    }
    
    try {
      final response = await _httpService.get('/auth/users/permissions/');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      if (_config.debug) {
        print('获取用户权限失败: $e');
      }
      return [];
    }
  }
  
  /// 检查用户是否有指定权限
  Future<bool> hasPermission(String permission) async {
    if (!_config.useXadminPermission) {
      return true;
    }
    
    final permissions = await getUserPermissions();
    return permissions.contains(permission);
  }
}