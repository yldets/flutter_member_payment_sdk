# 将SDK提交到Git仓库指南

本文档提供将Flutter会员支付SDK提交到Git仓库并供团队使用的完整步骤。

## 一、准备工作

1. 确保您有Git仓库的访问权限
2. 确保本地Git已正确配置

## 二、创建Git仓库（如果还没有）

### GitHub示例

1. 登录GitHub
2. 点击右上角"+"图标，选择"New repository"
3. 输入仓库名称，如"flutter_member_payment_sdk"
4. 选择是否设为私有仓库（团队内部使用推荐选择私有）
5. 点击"Create repository"

### GitLab示例

1. 登录GitLab
2. 点击"New project"
3. 选择"Create blank project"
4. 输入项目名称和描述
5. 选择可见性级别（推荐"Private"）
6. 点击"Create project"

## 三、将SDK代码提交到仓库

### 1. 初始化本地仓库

如果SDK目录还未初始化为Git仓库：

```bash
cd /Users/yldets/Desktop/AI/sdk
git init
```

### 2. 添加远程仓库

```bash
git remote add origin https://github.com/您的用户名或组织/flutter_member_payment_sdk.git
```

### 3. 添加`.gitignore`文件

创建`.gitignore`文件，排除不必要的文件：

```
# Dart/Flutter相关
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
pubspec.lock

# IDE相关
.idea/
.vscode/
*.iml
*.ipr
*.iws
.DS_Store

# 测试相关
coverage/
test/generated_*

# 本地配置
*.env
*.log
node_modules/
```

### 4. 添加文件并提交

```bash
git add .
git commit -m "初始版本：Flutter会员支付SDK"
```

### 5. 推送到远程仓库

```bash
git push -u origin main
```

## 四、创建发布版本（可选但推荐）

### 1. 创建Git标签

```bash
git tag -a v0.1.0 -m "初始版本发布"
git push origin v0.1.0
```

### 2. 在GitHub/GitLab上创建Release（可选）

- 进入仓库页面
- 找到"Releases"或"Tags"部分
- 创建新Release，选择刚才创建的标签
- 添加发布说明（可以使用CHANGELOG.md的内容）

## 五、团队成员使用SDK

### 方法一：通过Git依赖使用

团队成员在自己的Flutter项目的`pubspec.yaml`中添加：

```yaml
dependencies:
  # 其他依赖...
  
  # 从Git仓库获取SDK
  flutter_member_payment_sdk:
    git:
      url: https://github.com/您的用户名或组织/flutter_member_payment_sdk.git
      ref: v0.1.0  # 指定版本标签
```

然后运行：

```bash
flutter pub get
```

### 方法二：克隆仓库到本地使用（适用于需要查看或修改SDK代码的情况）

```bash
# 克隆仓库
git clone https://github.com/您的用户名或组织/flutter_member_payment_sdk.git

# 在Flutter项目中引用本地路径
# 在项目的pubspec.yaml中：
# dependencies:
#   flutter_member_payment_sdk:
#     path: /path/to/flutter_member_payment_sdk
```

## 六、团队协作注意事项

### 1. 版本管理

- 使用语义化版本号：MAJOR.MINOR.PATCH
  - MAJOR：不兼容的API变更
  - MINOR：向后兼容的功能性新增
  - PATCH：向后兼容的问题修正

- 每次发布新版本时：
  1. 更新`pubspec.yaml`中的版本号
  2. 更新`CHANGELOG.md`
  3. 提交代码并创建新标签

### 2. 分支策略

建议使用以下分支策略：

- `main`：稳定版本，经过测试的代码
- `develop`：开发中的代码
- `feature/xxx`：新功能开发
- `bugfix/xxx`：问题修复
- `release/x.x.x`：发布准备

### 3. Pull Request流程

1. 开发者基于`develop`分支创建功能分支
2. 完成开发后创建Pull Request
3. 代码审查通过后合并到`develop`
4. 定期将`develop`合并到`main`并创建新版本

## 七、发布到pub.dev（可选）

如果希望公开发布SDK，可以考虑发布到pub.dev：

1. 确保`pubspec.yaml`、`README.md`、`CHANGELOG.md`和`LICENSE`文件完整
2. 运行`flutter pub publish --dry-run`检查是否有问题
3. 运行`flutter pub publish`发布

## 八、其他建议

1. **明确的贡献指南**：创建`CONTRIBUTING.md`文件，说明如何贡献代码
2. **完善的文档**：确保文档清晰，包含API说明和使用示例
3. **自动化测试**：添加单元测试和集成测试，确保代码质量
4. **持续集成**：设置CI/CD流程，自动运行测试和构建
5. **安全更新**：定期更新依赖库以修复安全漏洞