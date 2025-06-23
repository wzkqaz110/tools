<!-- 项目顶栏徽章，可按需增减 -->
<p align="center">
  <img alt="Shell" src="https://img.shields.io/badge/language-shell-0891FF?logo=gnu-bash">
  <img alt="Stars" src="https://img.shields.io/github/stars/wzkqaz110/tools?style=social">
  <!-- 如果已有协议，请把 MIT 换成对应协议并在根目录补充 LICENSE 文件 -->
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green">
</p>

<h1 align="center">自用小工具 (personal-tools)</h1>

<p align="center">
  🛠️ 一些日常运维脚本的集合，专注 <b>一键安装 / 配置</b>，提升效率。
</p>

---

## 📦 快速开始

| # | 功能             | 一键命令 |
|---|------------------|---------|
| 1 | **更改 SSH 端口** | `wget -N https://raw.githubusercontent.com/wzkqaz110/tools/refs/heads/main/change_ssh_port.sh && bash change_ssh_port.sh` |
| 2 | **安装 XrayR**   | `wget -N https://raw.githubusercontent.com/wzkqaz110/tools/refs/heads/main/xrayr/install.sh && bash install.sh` |

> **提示**：脚本默认在 `/root` 执行；若需其他目录，请自行 `cd` 之后再运行。

---

## 🗂️ 目录

- [更改 SSH 端口](#更改-ssh-端口)
- [XrayR 一键安装](#xrayr-一键安装)
- [常见问题](#常见问题)
- [贡献指南](#贡献指南)
- [License](#license)

---

## 更改 SSH 端口

### 脚本作用

1. 交互式或自动方式修改 `sshd_config` 中的 `Port`。  
2. 自动放行防火墙（`ufw`/`firewalld`）对应端口，阻止 22 端口暴露。  
3. 重启 `sshd` 并打印新的登录命令。

### 自定义参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--port` | `2222` | 目标端口号 |
| `--no-firewall` | `false` | 跳过防火墙规则配置 |

```bash
# 示例：将 SSH 端口改为 50022 且跳过防火墙配置
bash change_ssh_port.sh --port 50022 --no-firewall
