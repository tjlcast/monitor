#!/bin/bash

echo "$(date)"
echo "${BASH_SOURCE[0]}"
result=""

for file in *; do
    if [[ -f "$file" ]] && [[ "$file" != *.sh ]] && [[ "$file" != *.log ]] && [[ "$file" != *.md ]]; then
        echo "Checking $file"
        curl_command=$(cat "$file")
        start_time=$(date +%s%3)
        response=$(eval "$curl_command -s")
        end_time=$(date +%s%3)
        duration=$((end_time - start_time))
        field=$(echo $file | cut -d "." -f 2-)
        if [[ "$field" == "stream" ]]; then
            field_value=$(echo $response | grep "data: ")
        else
            has_field_value=$(echo "$response" | jq "has(\"$field\")")
            if [ "$has_field_value" == "true" ]; then
                # 存在检查字段
                field_value=$(echo "$response" | jq -r ".${field}")
                field_value=${field_value:0:110}
            else
                # 不存在检查字段,赋值空
                field_value=""
            fi
        fi

        msg=""
        if [[ ! -z "$field_value"  ]]; then
            msg="Cost: '$duration'ms Monitoring object '$file': Field '$field' has a value of '$field_value'."
        else
            msg="[FAIL] Monitoring object '$file': Field '$field' does not exist in the response or the response is empty."
        fi
        result+="$msg\n\n"
    fi
done

echo ">>>>>> RESULT >>>>>>>"
echo $result | awk 'BEGIN{RS="\\\\n\\\\n"}{printf "%s\n\n", $0}'
