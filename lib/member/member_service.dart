import '../common/http_service.dart';
import '../config/sdk_config.dart';

/// 会员等级枚举
enum MemberLevel {
  /// 非会员
  none,
  
  /// 基础会员
  basic,
  
  /// 高级会员
  premium,
  
  /// VIP会员
  vip,
  
  /// 企业会员
  enterprise,
  
  /// 定制会员
  custom,
}

/// 会员信息模型
class MemberInfo {
  /// 用户ID
  final String userId;
  
  /// 会员等级
  final MemberLevel level;
  
  /// 会员等级ID
  final int levelId;
  
  /// 会员到期日期
  final DateTime? expiryDate;
  
  /// 会员积分
  final int points;
  
  /// 会员权益列表
  final List<String> benefits;
  
  /// 原始会员数据
  final Map<String, dynamic> rawData;

  /// 创建会员信息实例
  const MemberInfo({
    required this.userId,
    required this.level,
    this.levelId = 0,
    this.expiryDate,
    this.points = 0,
    this.benefits = const [],
    this.rawData = const {},
  });

  /// 从JSON创建会员信息实例
  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      level: _parseMemberLevel(json['level'] as String? ?? json['level_name'] as String?),
      levelId: json['levelId'] as int? ?? json['level_id'] as int? ?? 0,
      expiryDate: _parseExpiryDate(json),
      points: json['points'] as int? ?? json['member_points'] as int? ?? 0,
      benefits: _parseBenefits(json),
      rawData: json,
    );
  }

  /// 解析会员到期日期
  static DateTime? _parseExpiryDate(Map<String, dynamic> json) {
    final expiryDateStr = json['expiryDate'] as String? ?? 
                        json['expiry_date'] as String? ??
                        json['expire_date'] as String?;
    if (expiryDateStr == null) return null;
    
    try {
      return DateTime.parse(expiryDateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// 解析会员权益
  static List<String> _parseBenefits(Map<String, dynamic> json) {
    final benefits = json['benefits'] ?? json['member_benefits'];
    if (benefits == null) return [];
    
    if (benefits is List) {
      return benefits.map((e) => e.toString()).toList();
    } else if (benefits is String) {
      try {
        // 尝试解析JSON字符串
        final benefitsList = benefits.split(',');
        return benefitsList.where((e) => e.isNotEmpty).toList();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// 将会员等级字符串转换为枚举
  static MemberLevel _parseMemberLevel(String? levelStr) {
    switch (levelStr?.toLowerCase()) {
      case 'basic':
        return MemberLevel.basic;
      case 'premium':
        return MemberLevel.premium;
      case 'vip':
        return MemberLevel.vip;
      case 'enterprise':
        return MemberLevel.enterprise;
      case 'custom':
        return MemberLevel.custom;
      default:
        return MemberLevel.none;
    }
  }

  /// 将会员等级枚举转换为可读字符串
  String get levelName {
    switch (level) {
      case MemberLevel.basic:
        return '基础会员';
      case MemberLevel.premium:
        return '高级会员';
      case MemberLevel.vip:
        return 'VIP会员';
      case MemberLevel.enterprise:
        return '企业会员';
      case MemberLevel.custom:
        return '定制会员';
      case MemberLevel.none:
        return '非会员';
    }
  }

  /// 检查会员是否有效
  bool get isActive {
    if (level == MemberLevel.none) return false;
    if (expiryDate == null) return true;
    return expiryDate!.isAfter(DateTime.now());
  }
  
  /// 获取指定字段的值
  dynamic getValue(String fieldName) {
    return rawData[fieldName];
  }
}

/// 会员服务结果模型
class MemberResult {
  /// 是否成功
  final bool success;
  
  /// 错误信息
  final String? errorMessage;
  
  /// 会员信息
  final MemberInfo? memberInfo;

  /// 创建会员服务结果实例
  const MemberResult({
    this.success = false,
    this.errorMessage,
    this.memberInfo,
  });

  /// 创建成功的会员服务结果
  factory MemberResult.success(MemberInfo memberInfo) {
    return MemberResult(
      success: true,
      memberInfo: memberInfo,
    );
  }

  /// 创建失败的会员服务结果
  factory MemberResult.failure(String errorMessage) {
    return MemberResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 会员服务，提供会员信息查询等功能
class MemberService {
  /// HTTP服务实例
  final HttpService _httpService;
  
  /// SDK配置
  final SDKConfig _config;
  
  /// 当前会员信息缓存
  MemberInfo? _cachedMemberInfo;
  
  /// 缓存过期时间（毫秒）
  final int _cacheExpiryMs = 5 * 60 * 1000; // 5分钟
  
  /// 上次缓存时间
  int _lastCacheTimeMs = 0;

  /// 创建会员服务实例
  /// 
  /// [httpService] HTTP服务实例
  /// [config] SDK配置
  MemberService(this._httpService, this._config);

  /// 获取会员信息
  /// 
  /// [forceRefresh] 是否强制刷新缓存
  Future<MemberResult> fetchMemberInfo({bool forceRefresh = false}) async {
    // 检查缓存是否有效
    final now = DateTime.now().millisecondsSinceEpoch;
    final isCacheValid = _cachedMemberInfo != null && 
                       (now - _lastCacheTimeMs) < _cacheExpiryMs;
    
    // 如果有有效缓存且不需要强制刷新，则直接返回缓存
    if (!forceRefresh && isCacheValid) {
      return MemberResult.success(_cachedMemberInfo!);
    }

    try {
      final response = _config.useXadminAuth
          ? await _fetchXadminMemberInfo()
          : await _fetchStandardMemberInfo();
          
      return response;
    } catch (e) {
      if (_config.debug) {
        print('获取会员信息请求失败: $e');
      }
      return MemberResult.failure('获取会员信息请求失败: $e');
    }
  }
  
  /// 从标准API获取会员信息
  Future<MemberResult> _fetchStandardMemberInfo() async {
    final response = await _httpService.post('/member/info');
    
    final data = response.data as Map<String, dynamic>;
    
    if (response.statusCode == 200 && data['success'] == true) {
      final memberData = data['data'] as Map<String, dynamic>;
      final memberInfo = MemberInfo.fromJson(memberData);
      
      // 更新缓存
      _cachedMemberInfo = memberInfo;
      _lastCacheTimeMs = DateTime.now().millisecondsSinceEpoch;
      
      return MemberResult.success(memberInfo);
    } else {
      final message = data['message'] as String? ?? '获取会员信息失败';
      return MemberResult.failure(message);
    }
  }
  
  /// 从Xadmin API获取会员信息
  Future<MemberResult> _fetchXadminMemberInfo() async {
    final response = await _httpService.get('/member/profile/');
    
    if (response.statusCode == 200) {
      final data = response.data;
      Map<String, dynamic> memberData;
      
      // Xadmin API可能直接返回数据对象，也可能嵌套在results中
      if (data is Map) {
        if (data.containsKey('results') && data['results'] is List && (data['results'] as List).isNotEmpty) {
          memberData = (data['results'] as List).first as Map<String, dynamic>;
        } else {
          memberData = data;
        }
      } else {
        return MemberResult.failure('获取会员信息失败：无效的响应格式');
      }
      
      final memberInfo = MemberInfo.fromJson(memberData);
      
      // 更新缓存
      _cachedMemberInfo = memberInfo;
      _lastCacheTimeMs = DateTime.now().millisecondsSinceEpoch;
      
      return MemberResult.success(memberInfo);
    } else {
      final message = response.data is Map ? response.data['detail'] ?? '获取会员信息失败' : '获取会员信息失败';
      return MemberResult.failure(message.toString());
    }
  }

  /// 清除会员信息缓存
  void clearCache() {
    _cachedMemberInfo = null;
    _lastCacheTimeMs = 0;
  }
  
  /// 获取会员等级列表
  Future<List<Map<String, dynamic>>> fetchMemberLevels() async {
    try {
      final endpoint = _config.useXadminAuth ? '/member/levels/' : '/member/levels';
      final response = await _httpService.get(endpoint);
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> levelsList;
        
        if (data is Map && data.containsKey('results')) {
          levelsList = data['results'] as List;
        } else if (data is List) {
          levelsList = data;
        } else {
          return [];
        }
        
        return levelsList.map((level) => level as Map<String, dynamic>).toList();
      }
      
      return [];
    } catch (e) {
      if (_config.debug) {
        print('获取会员等级列表失败: $e');
      }
      return [];
    }
  }
  
  /// 会员升级
  Future<MemberResult> upgradeMembership(int levelId) async {
    try {
      final endpoint = _config.useXadminAuth ? '/member/upgrade/' : '/member/upgrade';
      final response = await _httpService.post(
        endpoint,
        data: {
          'level_id': levelId,
        },
      );
      
      if (response.statusCode == 200) {
        // 强制刷新会员信息
        return await fetchMemberInfo(forceRefresh: true);
      } else {
        final message = response.data is Map ? 
          (response.data['message'] ?? response.data['detail'] ?? '会员升级失败') : 
          '会员升级失败';
        return MemberResult.failure(message.toString());
      }
    } catch (e) {
      return MemberResult.failure('会员升级请求失败: $e');
    }
  }
}