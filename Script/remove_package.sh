#!/bin/bash

if [ $# -eq 0 ]; then
    echo "用法: $0 <软件包1> [<软件包2> ...]"
    exit 1
fi

for pkg in "$@"; do
    if paru -Qi "$pkg" > /dev/null 2>&1; then
        echo "正在清理软件包 $pkg..."
        # 使用find安全删除文件，避免xargs处理特殊字符问题
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                sudo rm -f "$file" && echo "已删除: $file" || echo "删除失败: $file"
            fi
        done < <(paru -Ql "$pkg" | awk '{print $2}')
        
        # 删除软件包及其未被依赖的依赖项和配置文件
        if paru -Rnsu "$pkg"; then
            echo "软件包 $pkg 已成功移除"
        else
            echo "移除软件包 $pkg 失败"
        fi
    else
        echo "未找到软件包 $pkg"
    fi
done
