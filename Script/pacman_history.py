#!/usr/bin/env python3

import subprocess  # 用于执行 shell 命令
import datetime    # 用于处理日期和时间
import argparse    # 用于解析命令行参数


class PackageInfo:
    """定义一个类来存储软件包信息"""
    def __init__(self) -> None:
        self.name: str = ""        # 软件包名称
        self.time: float = 0.0     # 软件包安装时间的 Unix 时间戳


def main():
    """主函数，处理软件包信息的获取、排序和输出"""
    # 创建命令行参数解析器
    parser = argparse.ArgumentParser()

    # 添加 -e/--explicit 参数，用于仅列出显式安装的软件包
    parser.add_argument(
        "-e",
        "--explicit",
        action="store_true",
        help="仅列出显式安装的软件包",
    )

    # 解析命令行参数
    args = parser.parse_args()

    # 执行 pacman -Qi 命令，获取软件包的名称、安装日期和安装原因
    info = subprocess.check_output(
        "pacman -Qi | grep '^Name\\|Install Date\\|Install Reason'",
        text=True,
        shell=True,
    ).strip()

    # 初始化软件包信息列表
    package_list: list[PackageInfo] = []
    current = PackageInfo()  # 当前处理的软件包信息对象

    # 逐行解析 pacman 输出，每三行对应一个软件包的信息
    for index, line in enumerate(info.splitlines()):
        if index % 3 == 0:
            # 第一行：软件包名称
            current.name = line.split(":")[1].strip()
        elif index % 3 == 1:
            # 第二行：安装日期，转换为 Unix 时间戳
            t = line.split(":", maxsplit=1)[1].strip()
            current.time = datetime.datetime.strptime(
                t, "%a %d %b %Y %I:%M:%S %p %Z"
            ).timestamp()
        else:
            # 第三行：安装原因
            # 如果未指定 --explicit 或者软件包为显式安装，则添加到列表
            if (
                not args.explicit
                or line.split(":")[1].strip() == "Explicitly installed"
            ):
                package_list.append(current)
            current = PackageInfo()  # 重置为新的软件包对象

    # 按安装时间排序软件包列表
    package_list.sort(key=lambda m: m.time)

    # 输出软件包名称和安装日期（格式：YYYY-MM-DD）
    for package in package_list:
        time = datetime.datetime.fromtimestamp(package.time).strftime("%Y-%m-%d")
        print(f"{package.name:<50}{time}")


if __name__ == "__main__":
    """脚本入口，运行主函数"""
    main()
