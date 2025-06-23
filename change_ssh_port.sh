#!/usr/bin/env bash
# 用法：sudo ./change_ssh_port.sh 01234567890123456
set -euo pipefail

NEW_PORT="${1:-}"
if [[ -z "$NEW_PORT" || ! "$NEW_PORT" =~ ^[0-9]+$ || "$NEW_PORT" -le 1024 || "$NEW_PORT" -gt 65535 ]]; then
  echo "❌ 请输入 1025-65535 之间的端口号，例如：sudo $0 2222"
  exit 1
fi

echo "🔧 正在将 SSH 端口改为 $NEW_PORT …"

# 1) 备份配置
cp /etc/ssh/sshd_config /etc/ssh/sshd_config."$(date +%F_%H%M%S).bak"

# 2) 修改 /etc/ssh/sshd_config （有则改，无则加）
if grep -qE '^[#]?Port ' /etc/ssh/sshd_config; then
  sed -ri "s|^[#]?Port .*|Port ${NEW_PORT}|g" /etc/ssh/sshd_config
else
  echo "Port ${NEW_PORT}" >> /etc/ssh/sshd_config
fi

# 3) SELinux（CentOS / Rocky / Alma）
if command -v semanage &>/dev/null && sestatus | grep -q "enabled"; then
  semanage port -a -t ssh_port_t -p tcp "${NEW_PORT}" 2>/dev/null || \
  semanage port -m -t ssh_port_t -p tcp "${NEW_PORT}"
fi

# 4) 防火墙
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port=${NEW_PORT}/tcp
  firewall-cmd --reload
fi

if command -v ufw &>/dev/null; then
  ufw allow "${NEW_PORT}/tcp"
fi

if command -v iptables &>/dev/null; then
  iptables -I INPUT  -p tcp --dport "${NEW_PORT}" -j ACCEPT
  ip6tables -I INPUT -p tcp --dport "${NEW_PORT}" -j ACCEPT
  iptables-save   >/dev/null
  ip6tables-save  >/dev/null
fi

# 5) 重启 sshd
systemctl restart sshd
echo "✅ 端口已改。请马上测试：ssh -p ${NEW_PORT} <用户名>@<服务器IP或域名>"
