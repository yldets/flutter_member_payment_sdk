import '../common/http_service.dart';
import 'auth_storage.dart';

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

  /// 创建认证结果实例
  const AuthResult({
    this.success = false,
    this.errorMessage,
    this.userId,
    this.accessToken,
    this.refreshToken,
  });

  /// 创建成功的认证结果
  factory AuthResult.success({
    required String userId,
    required String accessToken,
    String? refreshToken,
  }) {
    return AuthResult(
      success: true,
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
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

  /// 创建认证服务实例
  /// 
  /// [httpService] HTTP服务实例
  AuthService(this._httpService) : _authStorage = AuthStorage.instance;

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
    } catch (e) {
      return AuthResult.failure('登录请求失败: $e');
    }
  }

  /// 登出
  Future<bool> logout() async {
    try {
      // 调用登出API
      await _httpService.post('/auth/logout');
      
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
}