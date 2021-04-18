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
RESULT_DIR="result"
SEQUENCE_DIR="sequence"
LOG_FILE="error.log"

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
if [ ! -d $DB_DIR -o ! -d $QUERY_DIR -o ! -d $OUTPUT_DIR -o ! -d $OUTPUT_DIR/$RESULT_DIR -o ! -d $OUTPUT_DIR/$SEQUENCE_DIR ]; then
    echo "ディレクトリ作成がまだです。"
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
COUNT=$(find ./$OUTPUT_DIR/$RESULT_DIR -type f -not -name '.*' | wc -l | tr -d ' ')
OUTPUT_NAME=$DATE'_output'$(expr $COUNT + 1)'.txt'
ABSTRUCT_SEQUENCE=$DATE'_sequence'$(expr $COUNT + 1)'.fasta'

# 最終確認
echo "------------------------------------"
echo "こちらで実行してもよろしいですか？ (y or Enter/n)"
echo "データベース: $DB_NAME"
echo "クエリ: $QUERY_NAME" 
echo "blast結果の出力ファイル名: $OUTPUT_NAME"
echo "fastaファイルから抽出ファイル名: $ABSTRUCT_SEQUENCE"
echo "------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

OUTPUT_FORMAT="7 sseqid evalue score bitscore length qseqid pident qseq sseq"
NUM_ALIGN_OPTION="-num_alignments"
NUM_ALIGN_OPTION_NUM="1"

# blastnの実行
echo "実行中です。そのままお待ちください。"
 
# TODO: logに日付を出力する
# echo "以下のコマンドを実行します。"
# コマンドを出力するため
blastn -db $DB_DIR/$DB_NAME/$DB_NAME -query $QUERY_DIR/$QUERY_NAME -out $OUTPUT_DIR/$RESULT_DIR/$OUTPUT_NAME -outfmt "$OUTPUT_FORMAT" $NUM_ALIGN_OPTION "$NUM_ALIGN_OPTION_NUM" 2>> $LOG_FILE

# blastが失敗した時、エラー
if [ $? -gt 0 ]; then
    echo "blastnの実行に失敗しました。"
    exit 1
fi

# コマンド実行成功！
echo "blastnの実行に成功しました！"

# outputファイルから、sseqid(subject id)を抽出して、重複を取り除く
REGEX="^(\#)"

# subject_id(TRINITY_DN61_c0_g1とか??)の配列
while read output_line
do
    if [[ !($output_line =~ $REGEX) ]]; then
        # subject_idを抽出して、一時ファイルに保存する
        echo $output_line | sed -e 's/[ ].*$//' >> $DATE'_work.txt'  
    fi
done < ./$OUTPUT_DIR/$RESULT_DIR/$OUTPUT_NAME

if [ ! -e $DATE'_work.txt' ]; then
  echo "blastnでヒットするものありませんでした。"
  echo "処理を終了します。"
  exit 1
fi

echo "続いて、塩基配列の抽出を行います。"
echo "少し時間がかかりますので、しばらくお待ちください。"

# MEMO: 重複を削除して、配列に変換する
target_subject_ids=$(cat $DATE'_work.txt' | awk '!a[$0]++' | tr -s '\n' ' ')
# echo ${target_subject_ids[@]} # デバッグ用

# fastaを読み込む
for target_subject_id in ${target_subject_ids[@]}
do
    cat ./db/$DB_NAME/$DB_NAME | grep $target_subject_id -A 1 >> ./$OUTPUT_DIR/$SEQUENCE_DIR/$ABSTRUCT_SEQUENCE
done

# 一時ファイルを削除する
rm $DATE'_work.txt'

echo "subject idと塩基配列の抽出に成功しました。"
echo "処理を終了します。"