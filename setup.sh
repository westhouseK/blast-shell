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
    if [ $? -eq 0 ]; then
        echo $DB_DIR"ディレクトリを作成しました。"
    fi
fi

# queryディレクトリを作成する
if [ ! -d "$QUERY_DIR" ]; then
    mkdir $QUERY_DIR
    if [ $? -eq 0 ]; then
        echo $QUERY_DIR"ディレクトリを作成しました。"
    fi
fi

# outputディレクトリを作成する
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir $OUTPUT_DIR
    if [ $? -eq 0 ]; then
        echo $DB_DIR"ディレクトリを作成しました。"
    fi
fi

# output/resultディレクトリを作成する
if [ ! -d "$OUTPUT_DIR/$RESULT_DIR" ]; then
    mkdir $OUTPUT_DIR/$RESULT_DIR
    if [ $? -eq 0 ]; then
        echo $OUTPUT_DIR"/"$RESULT_DIR"ディレクトリを作成しました。"
    fi
fi

# output/sequneceディレクトリを作成する
if [ ! -d "$OUTPUT_DIR/$SEQUENCE_DIR" ]; then
    mkdir $OUTPUT_DIR/$SEQUENCE_DIR
    if [ $? -eq 0 ]; then
        echo $OUTPUT_DIR"/"$SEQUENCE_DIR"ディレクトリを作成しました。"
    fi
fi

echo "ディレクトリ作成を完了しました。"