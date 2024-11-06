#!/bin/bash

# 安装依赖项
install_dependencies() {
    apt update
    apt install wget curl -y
}

# 获取最新内核版本的下载链接
get_latest_kernel_urls() {
    local arch
    arch=$(uname -m)

    # 将 x86_64 和 arm64 转换为对应的内核包名
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *) echo "不支持的架构: $arch"; exit 1 ;;
    esac

    # 获取与架构匹配的下载链接
    curl -s "https://api.github.com/repos/angrydust/Latest-Kernel-BBR3/releases/latest" \
    | grep "browser_download_url" \
    | grep "$arch" \
    | grep -v "linux-libc-dev" \
    | cut -d '"' -f 4
}

# 下载内核
download_kernels() {
    local urls=("$@")
    mkdir -p /root/bbr3
    for url in "${urls[@]}"; do
        wget -P /root/bbr3 "$url"
    done
}

# 安装内核
install_kernels() {
    dpkg -i /root/bbr3/*.deb
}

# 主程序
main() {
    install_dependencies
    local kernel_urls
    kernel_urls=($(get_latest_kernel_urls))
    if [ ${#kernel_urls[@]} -gt 0 ]; then
        download_kernels "${kernel_urls[@]}"
        install_kernels
        echo "安装完成，请重启以启用新内核。"
    else
        echo "无法获取内核下载链接，请检查网络连接或稍后重试。"
        exit 1
    fi
}

main
