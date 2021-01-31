#!/bin/bash

# ------------------------------------------------
# 
# blastnを実行するためのセットアップ
# 実行方法: sh setup.sh
# 実行条件: shまたはbashが、インストールされていること
#
# ------------------------------------------------

# 定数を宣言
DB_DIR="db"
QUERY_DIR="query"
OUTPUT_DIR="output"

# DBディレクトリを作成する
if [ ! -d $DB_DIR ]; then
    mkdir $DB_DIR
fi

# queryディレクトリを作成する
if [ ! -d "$QUERY_DIR" ]; then
    mkdir $QUERY_DIR
fi

# outputディレクトリを作成する
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir $OUTPUT_DIR
fi

echo "ディレクトリを作成しました。"