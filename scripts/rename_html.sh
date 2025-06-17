#!/usr/bin/env bash
# rename_one.sh  URL  原文件路径
set -e

if [ $# -ne 2 ]; then
  echo "用法: $0 <URL> <HTML文件>"
  exit 1
fi

url="$1"
oldfile="$2"

# 计算 URL 的 MD5（32 位小写十六进制）
hash=$(printf '%s' "$url" | md5sum | cut -d' ' -f1)

# 目标文件夹
dst_dir="static/archive"
mkdir -p "$dst_dir"

# 重命名并移动
mv "$oldfile" "$dst_dir/$hash.html"

echo "✔ $oldfile  →  $dst_dir/$hash.html"

