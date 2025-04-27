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
    
    // 添加拦截器处理Xadmin特定的响应格式
    if (_config.useXadminAuth && dioIsReal()) {
      dio.interceptors.add(InterceptorsWrapper(
        onResponse: (response, handler) {
          // Xadmin API响应格式处理
          _handleXadminResponse(response);
          handler.next(response);
        },
        onError: (DioException error, handler) {
          // Xadmin API错误处理
          _handleXadminError(error);
          handler.next(error);
        },
      ));
    }
  }

  /// 处理Xadmin响应格式
  void _handleXadminResponse(Response response) {
    if (response.data is Map) {
      // Xadmin API通常会返回包含code、message、data字段的响应
      if (response.data['code'] != null && response.data['code'] != 0) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: response.data['message'] ?? 'Unknown Xadmin API error',
        );
      }
    }
  }

  /// 处理Xadmin错误
  void _handleXadminError(DioException error) {
    if (_config.debug) {
      print('Xadmin API Error: ${error.message}');
      if (error.response?.data != null) {
        print('Error details: ${error.response?.data}');
      }
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
    dio.options.headers['Authorization'] = _config.useXadminAuth ? 'JWT $token' : 'Bearer $token';
  }

  /// 清除鉴权令牌
  void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  /// 设置Xadmin特定请求头
  /// 
  /// [headers] 请求头
  void setXadminHeaders(Map<String, dynamic> headers) {
    headers.forEach((key, value) {
      dio.options.headers[key] = value;
    });
  }

  /// 构建完整的API路径
  /// 
  /// [path] 请求路径
  String _buildPath(String path) {
    if (_config.useXadminAuth && !path.startsWith(_config.xadminApiPrefix)) {
      // 对于Xadmin API，确保路径有正确的前缀
      return '${_config.xadminApiPrefix}$path';
    }
    return path;
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
      final fullPath = _buildPath(path);
      final response = await dio.get<T>(
        fullPath,
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
      final fullPath = _buildPath(path);
      final response = await dio.post<T>(
        fullPath,
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
  
  /// 执行PUT请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final fullPath = _buildPath(path);
      final response = await dio.put<T>(
        fullPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // 处理异常
      if (_config.debug) {
        print('HTTP PUT Error: $e');
      }
      rethrow;
    }
  }
  
  /// 执行DELETE请求
  /// 
  /// [path] 请求路径
  /// [data] 请求数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final fullPath = _buildPath(path);
      final response = await dio.delete<T>(
        fullPath,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      // 处理异常
      if (_config.debug) {
        print('HTTP DELETE Error: $e');
      }
      rethrow;
    }
  }
}