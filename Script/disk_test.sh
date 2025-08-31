#!/bin/bash
file_path="./testfile"

echo "顺序读：1M 1线程 8队列"
fio --name=seq_read --rw=read --filename=$file_path --size=4G --bs=1M --numjobs=1 --iodepth=8 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "顺序写：1M 1线程 8队列"
fio --name=seq_read --rw=write --filename=$file_path --size=4G --bs=1M --numjobs=1 --iodepth=8 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "顺序读：128k 1线程 32队列"
fio --name=seq_read --rw=read --filename=$file_path --size=4G --bs=128k --numjobs=1 --iodepth=32 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "顺序写：128k 1线程 32队列"
fio --name=seq_read --rw=write --filename=$file_path --size=4G --bs=128k --numjobs=1 --iodepth=32 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "随机读: 4k 16线程 32队列"
fio --name=4k_rand_read --rw=randread --filename=$file_path --size=4G --bs=4k --numjobs=16 --iodepth=32 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "随机写：4k 16线程 32队列"
fio --name=4k_rand_write --rw=randwrite --filename=$file_path --size=4G --bs=4k --numjobs=16 --iodepth=32 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "随机读: 4k 1线程 1队列"
fio --name=4k_rand_read --rw=randread --filename=$file_path --size=4G --bs=4k --numjobs=1 --iodepth=1 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

echo "随机写：4k 1线程 1队列"
fio --name=4k_rand_write --rw=randwrite --filename=$file_path --size=4G --bs=4k --numjobs=1 --iodepth=1 --runtime=20 --time_based --group_reporting --ioengine=libaio | grep bw
echo ""

rm $file_path
