import 'package:dio/dio.dart';
import '../config/sdk_config.dart';

/// HTTP服务类，封装网络请求
class HttpService {
  /// Dio实例
  final Dio dio;
  
  /// 服务器URL
  late final String _serverUrl;
  
  /// SDK配置
  late final SDKConfig _config;

  /// 构造HTTP服务实例
  /// 
  /// [config] SDK配置
  /// [dioClient] 可选的Dio实例，主要用于测试
  HttpService(SDKConfig config, {Dio? dioClient}) : 
      dio = dioClient ?? Dio() {
    _config = config;
    _serverUrl = config.serverUrl;
    _initDio();
  }

  /// 初始化Dio实例
  void _initDio() {
    final options = BaseOptions(
      baseUrl: _serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    dio.options = options;

    // 只有在非测试环境和调试模式下才添加拦截器
    if (_config.debug && dioIsReal()) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  /// 检查是否使用的是真实的Dio实例（非测试环境）
  bool dioIsReal() {
    try {
      return dio.interceptors.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 设置鉴权令牌
  /// 
  /// [token] 鉴权令牌
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 清除鉴权令牌
  void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  /// 执行GET请求
  /// 
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // 处理异常
      if (_config.debug) {
        print('HTTP GET Error: $e');
      }
      rethrow;
    }
  }

  /// 执行POST请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // 处理异常
      if (_config.debug) {
        print('HTTP POST Error: $e');
      }
      rethrow;
    }
  }
}