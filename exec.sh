#!/bin/bash

# ------------------------------------------------
# 
# blastnを実行する
# 実行方法: sh exec.sh
# 実行条件: shまたはbashが、インストールされていること
#
# ------------------------------------------------

# 定数を宣言
DB_DIR="db"
QUERY_DIR="query"
OUTPUT_DIR="output"

# TODO: ログファイルを出力する

# 実行の確認を行う
echo "------------------------------------"
echo "blastnを実行しますか？ (y or Enter/n)"
echo "------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

# ディレクトリが存在しない場合、エラー
if [ ! -d $DB_DIR -o ! -d $QUERY_DIR -o ! -d $OUTPUT_DIR ]; then
    echo "setup.shを実行してください。"
    exit 1
fi

# データベースが存在しない場合、エラー
if [ -z "$(ls ./$DB_DIR)" ]; then 
    echo "データベースが存在しません。"
    exit 1
fi

# クエリが存在しない場合、エラー
if [ -z "$(ls ./$QUERY_DIR)" ]; then 
    echo "クエリが存在しません。"
    exit 1
fi

echo "------------------------------------"
echo "データベースを選択してください。"
echo "------------------------------------"
select DB_NAME in $(ls ./$DB_DIR) exit
do
    if [ $DB_NAME = 'exit' ]; then
        echo "スクリプトを終了しました。"
        exit 1
    fi
    break
done

echo "------------------------------------"
echo "クエリを選択してください。"
echo "------------------------------------"
select QUERY_NAME in $(ls ./$QUERY_DIR) exit
do
    if [ $QUERY_NAME = 'exit' ]; then
        echo "スクリプトを終了しました。"
        exit 1
    fi
    break
done

# 出力先のファイルをフォーマット
# ex. 2021-1-31_12:34 (実行するPCのタイムゾーンに依存。確認方法: cat /etc/sysconfig/clock)
DATE=$(date '+%Y-%m-%d_%H:%M')
# ファイル名を作成するためにMAX値を取得する
COUNT=$(find ./$OUTPUT_DIR -type f -not -name '.*' | wc -l | tr -d ' ')
OUTPUT_NAME=$DATE'_output'$(expr $COUNT + 1)'.txt'

# 最終確認
echo "------------------------------------"
echo "こちらで実行してもよろしいですか？ (y or Enter/n)"
echo "データベース: $DB_NAME"
echo "クエリ: $QUERY_NAME" 
echo "出力ファイル名: $OUTPUT_NAME"
echo "------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

# blastnの実行
echo "実行中です。そのままお待ちください。"
# FIXME: blastnコマンドの変更と連動したい
echo "コマンド: blastn -db $DB_DIR/$DB_NAME/$DB_NAME -query $QUERY_DIR/$QUERY_NAME -out $OUTPUT_DIR/$OUTPUT_NAME -outfmt \"7 sseqid evalue score bitscore length qseqid pident qseq sseq\" -culling_limit \"15\""
echo "を実行しました。"

# TODO: logに日付を出力する
# FIXME: -outfmtの指定の仕方がよくわからない！
blastn -db $DB_DIR/$DB_NAME/$DB_NAME -query $QUERY_DIR/$QUERY_NAME -out $OUTPUT_DIR/$OUTPUT_NAME -outfmt "7 sseqid evalue score bitscore length qseqid pident qseq sseq" -culling_limit "15" 2>> log.txt

# blastが失敗した時、エラー
if [ $? -gt 0 ]; then
    echo "blastnの実行に失敗しました。"
    exit 1
fi

# コマンド実行成功！
echo "blastnの実行に成功しました！"