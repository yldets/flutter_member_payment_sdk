# 贡献指南

感谢您对Flutter会员支付SDK的关注！我们欢迎各种形式的贡献，包括但不限于功能改进、错误修复、文档更新等。本指南将帮助您了解如何参与到项目中来。

## 开发准备

1. 确保您的开发环境已安装：
   - Flutter SDK (最新稳定版)
   - Dart SDK
   - 适当的IDE (推荐VS Code或Android Studio)
   - Git

2. Fork并克隆仓库：
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_member_payment_sdk.git
   cd flutter_member_payment_sdk
   ```

3. 安装依赖：
   ```bash
   flutter pub get
   ```

## 分支管理

- `main`: 稳定版本分支，用于发布
- `develop`: 开发分支，所有功能分支都应基于此创建
- `feature/*`: 新功能分支
- `bugfix/*`: 错误修复分支
- `release/*`: 发布准备分支

## 开发流程

1. 基于`develop`分支创建新分支：
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. 在新分支上进行开发

3. 遵循代码规范：
   - 使用Dart风格指南
   - 添加适当的文档注释
   - 确保代码通过linting检查：`flutter analyze`

4. 编写测试：
   - 单元测试: 针对独立功能
   - 集成测试: 针对多个组件协作

5. 测试您的更改：
   ```bash
   flutter test
   ```

6. 提交您的更改：
   ```bash
   git add .
   git commit -m "描述性的提交信息"
   ```

7. 确保您的分支与最新的`develop`同步：
   ```bash
   git checkout develop
   git pull origin develop
   git checkout feature/your-feature-name
   git rebase develop
   ```

8. 推送您的分支：
   ```bash
   git push origin feature/your-feature-name
   ```

9. 创建Pull Request：
   - 基础分支选择`develop`
   - 清晰描述您的更改内容
   - 关联相关的Issues（如果有）

## 代码评审

所有提交都需要通过代码评审才能合并。在评审过程中：

- 接受建设性的批评
- 及时响应评审意见
- 根据需要修改代码
- 保持礼貌和尊重

## 版本控制

我们使用[语义化版本控制](https://semver.org/)，格式为`MAJOR.MINOR.PATCH`：

- MAJOR版本：不兼容的API变更
- MINOR版本：向后兼容的功能新增
- PATCH版本：向后兼容的Bug修复

## 更新CHANGELOG

对于每个值得注意的变更，请在`CHANGELOG.md`文件中添加相应条目：

- 新功能（New Features）
- 改进（Improvements）
- 错误修复（Bug Fixes）
- 不兼容变更（Breaking Changes）

## 文档

- 更新API文档以反映您的更改
- 在必要时更新README.md
- 对于重大功能变更，考虑更新或创建使用示例

## 提交Pull Request前的检查清单

- [ ] 代码符合代码规范
- [ ] 添加了必要的测试
- [ ] 所有测试通过
- [ ] 更新了相关文档
- [ ] 更新了CHANGELOG（如果适用）
- [ ] 分支与最新的`develop`同步

## 报告问题

如果您发现了问题但没有解决方案，也欢迎通过Issues提交问题报告。请提供：

- 清晰的问题描述
- 复现步骤
- 预期行为与实际行为
- 环境信息（Flutter版本、平台等）
- 相关日志或截图（如适用）

## 许可协议

通过提交代码，您同意您的贡献将在项目的许可协议下发布。

感谢您的贡献！