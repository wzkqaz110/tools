#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# 检查 root 权限
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# 检查操作系统
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}不支持当前操作系统，请使用 CentOS、Debian 或 Ubuntu！${plain}\n" && exit 1
fi

SERVICE_NAME="XrayR"

start() {
    systemctl start ${SERVICE_NAME}
    if [ $? -eq 0 ]; then
        echo -e "${green}XrayR 启动成功！${plain}"
    else
        echo -e "${red}XrayR 启动失败！${plain}"
    fi
}

stop() {
    systemctl stop ${SERVICE_NAME}
    if [ $? -eq 0 ]; then
        echo -e "${green}XrayR 停止成功！${plain}"
    else
        echo -e "${red}XrayR 停止失败！${plain}"
    fi
}

restart() {
    systemctl restart ${SERVICE_NAME}
    if [ $? -eq 0 ]; then
        echo -e "${green}XrayR 重启成功！${plain}"
    else
        echo -e "${red}XrayR 重启失败！${plain}"
    fi
}

status() {
    systemctl status ${SERVICE_NAME}
}

enable() {
    systemctl enable ${SERVICE_NAME}
    if [ $? -eq 0 ]; then
        echo -e "${green}XrayR 设置开机自启成功！${plain}"
    else
        echo -e "${red}XrayR 设置开机自启失败！${plain}"
    fi
}

disable() {
    systemctl disable ${SERVICE_NAME}
    if [ $? -eq 0 ]; then
        echo -e "${green}XrayR 取消开机自启成功！${plain}"
    else
        echo -e "${red}XrayR 取消开机自启失败！${plain}"
    fi
}

log() {
    journalctl -u ${SERVICE_NAME} -f
}

version() {
    echo -e "XrayR 管理脚本版本: ${green}${version}${plain}"
}

install() {
    echo "请根据实际需求完善安装逻辑"
}

uninstall() {
    echo "请根据实际需求完善卸载逻辑"
}

setup_cron() {
    echo -e "${yellow}是否添加自动更新数据库的计划任务？(y/n)${plain}"
    read -r answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo -e "${yellow}请输入自动更新时间，格式为 HH:MM（24小时制），默认 03:00，直接回车默认：${plain}"
        read -r time_input
        if [[ -z "$time_input" ]]; then
            time_input="03:00"
        fi

        if ! [[ $time_input =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
            echo -e "${red}时间格式错误，自动使用默认时间 03:00${plain}"
            time_input="03:00"
        fi

        hour=${time_input%%:*}
        minute=${time_input##*:}

        cron_cmd="/bin/bash $(realpath "$0") update-db >/dev/null 2>&1"

        crontab -l 2>/dev/null | grep -v -F "$cron_cmd" | crontab -

        (crontab -l 2>/dev/null; echo "$minute $hour * * * $cron_cmd") | crontab -

        echo -e "${green}计划任务添加成功！每天 $time_input 自动更新数据库。${plain}"
    else
        echo "未添加计划任务。"
    fi
}

update_database() {
    echo "正在下载 geoip.dat"
    wget -q -N --no-check-certificate \
        -O /usr/local/XrayR/geoip.dat \
        https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat \
    || { echo -e "${red}下载 geoip.dat 失败，请检查网络${plain}"; exit 1; }

    echo "正在下载 geosite.dat"
    wget -q -N --no-check-certificate \
        -O /usr/local/XrayR/geosite.dat \
        https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat \
    || { echo -e "${red}下载 geosite.dat 失败，请检查网络${plain}"; exit 1; }

    echo -e "${green}数据库更新完成！${plain}"

    setup_cron
}

show_menu() {
    echo -e "${green}========== XrayR 管理脚本 ==========${plain}"
    echo "1) 启动 XrayR"
    echo "2) 停止 XrayR"
    echo "3) 重启 XrayR"
    echo "4) 查看 XrayR 状态"
    echo "5) 设置开机自启"
    echo "6) 取消开机自启"
    echo "7) 查看日志"
    echo "8) 更新 geoip.dat 和 geosite.dat 数据库"
    echo "9) 安装 XrayR"
    echo "10) 卸载 XrayR"
    echo "11) 查看脚本版本"
    echo "0) 退出"
    echo -e "${green}==================================${plain}"
}

while true; do
    show_menu
    read -rp "请输入数字选择操作: " choice
    case $choice in
        1) start ;;
        2) stop ;;
        3) restart ;;
        4) status ;;
        5) enable ;;
        6) disable ;;
        7) log ;;
        8) update_database ;;
        9) install ;;
        10) uninstall ;;
        11) version ;;
        0) echo "退出脚本."; exit 0 ;;
        *) echo -e "${red}无效输入，请输入有效数字。${plain}" ;;
    esac
    echo
    read -rp "按回车键返回菜单..."
done
