import 'package:shared_preferences/shared_preferences.dart';

/// 认证存储服务，用于管理Token等认证信息
class AuthStorage {
  /// SharedPreferences键：访问令牌
  static const String _keyAccessToken = 'flutter_sdk_access_token';
  
  /// SharedPreferences键：用户ID
  static const String _keyUserId = 'flutter_sdk_user_id';
  
  /// SharedPreferences键：刷新令牌
  static const String _keyRefreshToken = 'flutter_sdk_refresh_token';
  
  /// SharedPreferences实例
  late SharedPreferences _prefs;
  
  /// 私有构造函数
  AuthStorage._();
  
  /// 单例实例
  static AuthStorage _instance = AuthStorage._();
  
  /// 获取单例实例
  static AuthStorage get instance => _instance;
  
  /// 设置单例实例，仅用于测试
  static set instance(AuthStorage storage) {
    _instance = storage;
  }
  
  /// 初始化存储服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存访问令牌
  /// 
  /// [token] 访问令牌
  Future<bool> saveAccessToken(String token) async {
    return await _prefs.setString(_keyAccessToken, token);
  }

  /// 获取访问令牌
  String? getAccessToken() {
    return _prefs.getString(_keyAccessToken);
  }

  /// 保存用户ID
  /// 
  /// [userId] 用户ID
  Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(_keyUserId, userId);
  }

  /// 获取用户ID
  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  /// 保存刷新令牌
  /// 
  /// [token] 刷新令牌
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(_keyRefreshToken, token);
  }

  /// 获取刷新令牌
  String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  /// 清除所有认证信息
  Future<void> clearAll() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyRefreshToken);
  }

  /// 检查用户是否已登录
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}