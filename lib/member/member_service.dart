import '../common/http_service.dart';

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
}

/// 会员信息模型
class MemberInfo {
  /// 用户ID
  final String userId;
  
  /// 会员等级
  final MemberLevel level;
  
  /// 会员到期日期
  final DateTime? expiryDate;
  
  /// 会员积分
  final int points;

  /// 创建会员信息实例
  const MemberInfo({
    required this.userId,
    required this.level,
    this.expiryDate,
    this.points = 0,
  });

  /// 从JSON创建会员信息实例
  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      userId: json['userId'] as String,
      level: _parseMemberLevel(json['level'] as String?),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      points: json['points'] as int? ?? 0,
    );
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
  
  /// 当前会员信息缓存
  MemberInfo? _cachedMemberInfo;

  /// 创建会员服务实例
  /// 
  /// [httpService] HTTP服务实例
  MemberService(this._httpService);

  /// 获取会员信息
  /// 
  /// [forceRefresh] 是否强制刷新缓存
  Future<MemberResult> fetchMemberInfo({bool forceRefresh = false}) async {
    // 如果有缓存且不需要强制刷新，则直接返回缓存
    if (!forceRefresh && _cachedMemberInfo != null) {
      return MemberResult.success(_cachedMemberInfo!);
    }

    try {
      final response = await _httpService.post('/member/info');
      
      final data = response.data as Map<String, dynamic>;
      
      if (response.statusCode == 200 && data['success'] == true) {
        final memberData = data['data'] as Map<String, dynamic>;
        final memberInfo = MemberInfo.fromJson(memberData);
        
        // 更新缓存
        _cachedMemberInfo = memberInfo;
        
        return MemberResult.success(memberInfo);
      } else {
        final message = data['message'] as String? ?? '获取会员信息失败';
        return MemberResult.failure(message);
      }
    } catch (e) {
      return MemberResult.failure('获取会员信息请求失败: $e');
    }
  }

  /// 清除会员信息缓存
  void clearCache() {
    _cachedMemberInfo = null;
  }
}