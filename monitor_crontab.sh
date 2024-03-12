#!/bin/bash

HOME=/Users/jialtang/Code/monitor

cd $HOME

if [ ! -f "./log.log" ]; then
    # 如果文件不存在，使用 touch 命令创建
    touch log.log
fi
if [ ! -f "./error.log" ]; then
    # 如果文件不存在，使用 touch 命令创建
    touch error.log
fi

# 检查文件大小，超过额定进行清空
FILE=$HOME/log.log
if [ $(du -m "$FILE" | awk '{print $1}') -gt 5 ]; then
    # 如果文件大于5MB，清空文件
    echo "" > $HOME/log.log
    echo "" > $HOME/error.log
fi

log_info=$($HOME/monitor.sh)
awk -F '\n' '{print $0}' <<< "$log_info"  >> $HOME/log.log
awk -F '\n' '{print $0}' <<< "$log_info"  | grep -i -e 'fail' -e 'CST' >> $HOME/error.log

# 检查的是否开启 im 通知
if [ -n "${im_key}" ]; then
    # 统计error.log 日志
    # 如果尾部日志中尾部6行中有出现异常，而且不全是异常时通知飞浪；
    LOG_CONTENT=$(tail -15 error.log)
    log2=$(echo $LOG_CONTENT | awk -F 'CST' '{print $(NF-1)}')
    log1=$(echo $LOG_CONTENT | awk -F 'CST' '{print $(NF)}')

    # 使用进程替换和awk提取Monitoring object
    var1=$(echo "$log1" | grep -oP "Monitoring object \K[^:]+(?=:)" | sort)
    var2=$(echo "$log2" | grep -oP "Monitoring object \K[^:]+(?=:)" | sort)

    declare -A dict1
    for item in $var1; do
        dict1[$item]=1
    done

    declare -A dict2
    for item in $var2; do
        dict2[$item]=1
    done

    im_message=""
    # 输出仅在dict1中出现的key
    for key in "${!dict1[@]}"; do
        if [ -z "${dict2[$key]}" ]; then
            im_message=$im_message"$key, "
        fi 
    done

    if [[ -z $im_message ]]; then
        echo "im_message is empty"
    else
        echo "im_message is "$im_message
        # curl --request POST \
        # --url http://158.1.9.177:7001/imUser/IM/thirdNew/messageToIM \
        # --header 'ak: '"$im_key" \
        # --header 'Content-Type: multipart/form-data' \
        # --form sendID=tangjialiang \
        # --form recvID=tangjialiang,yingyue \
        # --form senderPlatformID=46 \
        # --form 'content=出现异常检查：'"$im_message"
    fi
fi