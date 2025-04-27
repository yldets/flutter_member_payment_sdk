import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 认证存储服务，用于管理Token等认证信息
class AuthStorage {
  /// SharedPreferences键：访问令牌
  static const String _keyAccessToken = 'flutter_sdk_access_token';
  
  /// SharedPreferences键：用户ID
  static const String _keyUserId = 'flutter_sdk_user_id';
  
  /// SharedPreferences键：刷新令牌
  static const String _keyRefreshToken = 'flutter_sdk_refresh_token';
  
  /// SharedPreferences键：用户信息
  static const String _keyUserInfo = 'flutter_sdk_user_info';
  
  /// SharedPreferences键：用户权限
  static const String _keyUserPermissions = 'flutter_sdk_user_permissions';
  
  /// SharedPreferences键：最后更新时间
  static const String _keyLastUpdated = 'flutter_sdk_last_updated';
  
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
    await _updateLastUpdated();
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
    await _updateLastUpdated();
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
    await _updateLastUpdated();
    return await _prefs.setString(_keyRefreshToken, token);
  }

  /// 获取刷新令牌
  String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }
  
  /// 保存用户信息
  /// 
  /// [userInfo] 用户信息
  Future<bool> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _updateLastUpdated();
    final userInfoJson = jsonEncode(userInfo);
    return await _prefs.setString(_keyUserInfo, userInfoJson);
  }
  
  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    final userInfoJson = _prefs.getString(_keyUserInfo);
    if (userInfoJson == null || userInfoJson.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(userInfoJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// 保存用户权限
  /// 
  /// [permissions] 用户权限列表
  Future<bool> saveUserPermissions(List<String> permissions) async {
    await _updateLastUpdated();
    final permissionsJson = jsonEncode(permissions);
    return await _prefs.setString(_keyUserPermissions, permissionsJson);
  }
  
  /// 获取用户权限
  List<String> getUserPermissions() {
    final permissionsJson = _prefs.getString(_keyUserPermissions);
    if (permissionsJson == null || permissionsJson.isEmpty) {
      return [];
    }
    
    try {
      final list = jsonDecode(permissionsJson) as List;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// 更新最后更新时间
  Future<bool> _updateLastUpdated() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return await _prefs.setInt(_keyLastUpdated, now);
  }
  
  /// 获取最后更新时间
  DateTime? getLastUpdated() {
    final timestamp = _prefs.getInt(_keyLastUpdated);
    if (timestamp == null) {
      return null;
    }
    
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 清除所有认证信息
  Future<void> clearAll() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserInfo);
    await _prefs.remove(_keyUserPermissions);
    await _prefs.remove(_keyLastUpdated);
  }

  /// 检查用户是否已登录
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 检查Token是否过期
  /// 
  /// [expiryDuration] Token有效期，默认为1天
  bool isTokenExpired({Duration expiryDuration = const Duration(days: 1)}) {
    final lastUpdated = getLastUpdated();
    if (lastUpdated == null) {
      return true;
    }
    
    final now = DateTime.now();
    return now.difference(lastUpdated) > expiryDuration;
  }
}