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
RESULT_DIR="result"
SEQUENCE_DIR="sequence"

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

# output/resultディレクトリを作成する
if [ ! -d "$OUTPUT_DIR/$RESULT" ]; then
    mkdir $OUTPUT_DIR/$RESULT
fi

# output/sequneceディレクトリを作成する
if [ ! -d "$OUTPUT_DIR/$SEQUENCE" ]; then
    mkdir $OUTPUT_DIR/$SEQUENCE
fi

echo "ディレクトリを作成しました。"