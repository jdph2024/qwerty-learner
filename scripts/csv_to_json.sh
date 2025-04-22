#!/bin/bash

# 定义输入和输出目录
INPUT_DIR="/Users/zhuhao/IdeaProjects/qwerty-learner/scripts"
OUTPUT_DIR="/Users/zhuhao/IdeaProjects/qwerty-learner/scripts"

# 检查输入目录是否存在
if [ ! -d "$INPUT_DIR" ]; then
    echo "错误：输入目录 $INPUT_DIR 不存在"
    exit 1
fi

# 检查输出目录是否存在，不存在则创建
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# 遍历所有 CSV 文件
for file in "$INPUT_DIR"/*.csv; do
    if [ -f "$file" ]; then
        # 获取文件名（不含路径和扩展名）
        basename=$(basename "$file" .csv)
        # 定义输出 JSON 文件路径
        OUTPUT_FILE="$OUTPUT_DIR/$basename.json"

        # 开始 JSON 数组
        echo "[" > "$OUTPUT_FILE"

        # 首次条目标志
        first_entry=1

        # 逐行读取 CSV 文件
        while IFS=, read -r col1 col2 col3 rest; do
            # 处理所有非空行（第一列非空）
            if [ -n "$col1" ]; then
                # 移除第一列中的 ZWNBSP (BOM) 字符
                col1=$(echo "$col1" | sed 's/^\xEF\xBB\xBF//')
                # 移除第三列中的换行符和回车符
                col3=$(echo "$col3" | tr -d '\n\r')

                # 非首个条目前添加逗号
                if [ $first_entry -eq 0 ]; then
                    echo "," >> "$OUTPUT_FILE"
                else
                    first_entry=0
                fi

                # 写入 JSON 对象
                echo "    {" >> "$OUTPUT_FILE"
                echo "        \"name\": \"$col1\"," >> "$OUTPUT_FILE"
                echo "        \"trans\": [\"$col2\"]," >> "$OUTPUT_FILE"
                echo "        \"notation\": \"$col3\"" >> "$OUTPUT_FILE"
                echo "    }" >> "$OUTPUT_FILE"
            fi
        done < "$file"

        # 关闭 JSON 数组
        echo "]" >> "$OUTPUT_FILE"

        echo "输出已写入 $OUTPUT_FILE"
    fi
done