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
blastn -db $DB_DIR/$DB_NAME/$DB_NAME -query $QUERY_DIR/$QUERY_NAME -out $OUTPUT_DIR/$OUTPUT_NAME -outfmt "$OUTPUT_FORMAT" $NUM_ALIGN_OPTION "$NUM_ALIGN_OPTION_NUM" 2>> $LOG_FILE

# blastが失敗した時、エラー
if [ $? -gt 0 ]; then
    echo "blastnの実行に失敗しました。"
    exit 1
fi

# コマンド実行成功！
echo "blastnの実行に成功しました！"
echo "続いて、塩基配列の抽出を行います。"
echo "少し時間がかかりますので、しばらくお待ちください。"

# outputファイルから、sseqid(subject id)を抽出して、重複を取り除く
REGEX="^(\#)"

# subject_id(TRINITY_DN61_c0_g1とか??)の配列
target_subject_ids=()
while read output_line
do
    if [[ !($output_line =~ $REGEX) ]]; then
        subject_id=$(echo $output_line | sed -e 's/[ ].*$//')
        # MEMO: 配列よりファイル出力の方がいい??
        # echo $output_line | sed -e 's/[ ].*$//' >> ./_tmp_output.txt
        # subject_idを配列に詰める
        target_subject_ids+=($subject_id)
    fi
done < ./$OUTPUT_DIR/$OUTPUT_NAME
# echo ${subject_id_list[@]} # デバッグ用


# MEMO: 【wip】重複を削除
# awk '!a[$0]++' tmp1.txt >> .tmp2.txt
# arr=$(cat .tmp2.txt | tr -s '\n' ' ')
# echo ${arr[@]}


# 塩基配列の列であるかのフラグ
is_sequence_line=false

# fastaを読み込む
for target_subject_id in ${target_subject_ids[@]}
do
    while read fasta
    do

        # 塩基配列の列か判定する
        if "${is_sequence_line}"; then
            echo $fasta >> ./$OUTPUT_DIR/$ABSTRUCT_SEQUENCE
            # 次のループは塩基配列の情報ではないので、フラグを折る
            is_sequence_line=false
            continue
        fi

        # 先頭に「>」である列がsubject_idのみを判定し、処理速度を向上させる
        if [ $(echo ${fasta:0:1}) != '>' ]; then
            continue
        fi

        # MEMO: 先頭の「>」を取り除ける処理
        # fasta_line=$(echo $fasta | sed -e 's/>//')

        # 目的にsubject_idの列か判定する
        echo $fasta | grep $target_subject_id > /dev/null

        if [ $? -eq 0 ]; then
            echo $fasta >> ./$OUTPUT_DIR/$ABSTRUCT_SEQUENCE
            # 次のループは塩基配列の情報なので、フラグを立てる
            is_sequence_line=true
        fi
    done < ./db/$DB_NAME/$DB_NAME
done

echo "subject idと塩基配列の抽出に成功しました。"
echo "これで処理を終了しました。"