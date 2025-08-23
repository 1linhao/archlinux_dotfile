#!/bin/bash

# 检查 fio 和 jq 是否安装
command -v fio >/dev/null 2>&1 || { echo "fio 未安装，请使用: sudo pacman -S fio"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq 未安装，请使用: sudo pacman -S jq"; exit 1; }

# 测试文件和输出目录
TEST_FILE="/mnt/tmp/test"
OUTPUT_DIR="/home/lh/log"
mkdir -p "$OUTPUT_DIR"

# 存储结果的数组
declare -A RESULTS

# 运行 fio 测试并提取带宽
run_fio() {
    local name=$1
    local rw=$2
    local bs=$3
    local numjobs=$4
    local output="$OUTPUT_DIR/${name}.json"
    echo "正在进行${name}测试"
    
    sudo fio --name="$name" --filename="$TEST_FILE" --rw="$rw" --bs="$bs" \
        --size=1G --numjobs="$numjobs" --iodepth=1 --runtime=30 --time_based \
        --group_reporting --output-format=json --output="$output" >/dev/null 2>&1
    
    # 提取带宽 (KB/s)
    if [[ "$rw" == "read" || "$rw" == "randread" ]]; then
        bw=$(jq '.jobs[0].read.bw' "$output")
    else
        bw=$(jq '.jobs[0].write.bw' "$output")
    fi
    echo "测试完成，${name}: ${bw}"
    RESULTS["$name"]=$(echo "scale=2; $bw / 1024" | bc) # 转换为 MB/s
}

# 运行测试
run_fio "顺序读取" "read" "1M" "1" && \
run_fio "顺序写入" "write" "1M" "1" && \
run_fio "4K随机读取" "randread" "4k" "1" && \
run_fio "4K随机写入" "randwrite" "4k" "1" && \
run_fio "4K随机读取64线程" "randread" "4k" "64" && \
run_fio "4K随机写入64线程" "randwrite" "4k" "64" && \
run_fio "读取延迟" "randread" "4k" "1" --latency_target=1ms --latency_window=1ms && \
run_fio "写入延迟" "randwrite" "4k" "1" --latency_target=1ms --latency_window=1ms

# 删除测试文件
sudo rm -f "$TEST_FILE"

# 以表格形式打印结果
echo "磁盘测试结果 (MB/s)"
echo "------------------------------------"
printf "| %-20s | %-10s |\n" "测试项目" "带宽"
echo "------------------------------------"
for test in "${!RESULTS[@]}"; do
    printf "| %-20s | %-10.2f |\n" "$test" "${RESULTS[$test]}"
done
echo "------------------------------------"
