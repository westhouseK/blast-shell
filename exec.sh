#!/bin/bash

# ------------------------------------------------
# 
# blastnを実行する
# 実行方法: sh exec.sh
# 実行条件: shまたはbashが、インストールされていること
#
# ------------------------------------------------

# 定数を宣言
# ファイル郡
readonly DB_DIR="db"
readonly QUERY_DIR="query"
readonly OUTPUT_DIR="output"
readonly RESULT_DIR="result"
readonly SEQUENCE_DIR="sequence"
readonly LOG_FILE="error.log"

# blastのオプション
readonly OUTPUT_FORMAT="7 sseqid evalue score bitscore length qseqid pident qseq sseq"
readonly NUM_ALIGN_OPTION="-num_alignments"
readonly NUM_ALIGN_OPTION_NUM="1"

# TODO: ログファイルを出力する

# 実行の確認を行う-------------------------------------------------------------------------
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
select DB_NAME in $(ls ./$DB_DIR) "exit"
do
    if [ $DB_NAME = "exit" ]; then
        echo "スクリプトを終了しました。"
        exit 1
    fi
    break
done

echo "------------------------------------"
echo "クエリを選択してください。複数選択が可能です。"
echo "Enterを押すと、再び選択肢が表示されます。"
echo "次に進みたい場合は、「that's it」を選択してください。"
echo "------------------------------------"
query_names=()
select QUERY_NAME in $(ls ./$QUERY_DIR) "that's it" "exit"
do
    case $QUERY_NAME in 
        "exit")
            echo "スクリプトを終了しました。"
            exit 1;;
        "that's it")
            if [ ${#query_names[@]} -eq 0 ]; then
                echo "クエリを選択していないため、終了しました。"
                exit 1
            fi
            echo "選択完了しました。"
            break;;
        *)
            echo "続いて選択してください。"
            query_names+=($QUERY_NAME);;
    esac
done

echo "------------------------------------"
echo "こちらで実行してもよろしいですか？ (y or Enter/n)"
echo "選択したデータベース: $DB_NAME"
echo "選択したクエリ: $(echo ${query_names[@]} | sed -e 's/ /, /g')"
echo "------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

# blast-------------------------------------------------------------------------
# 出力先のファイルをフォーマット
# ex. 2021-1-31_12:34 (実行するPCのタイムゾーンに依存。確認方法: cat /etc/sysconfig/clock)
DATE=$(date '+%Y-%m-%d_%H:%M')
# ファイル名を作成するためにMAX値を取得する
FILE_COUNT=$(find ./$OUTPUT_DIR/$RESULT_DIR -type f -not -name '.*' | wc -l | tr -d ' ')

COUNT=1
for query_name in ${query_names[@]}
do
    # blastの実行-------------------------------------------------------------------------
    OUTPUT_NAME=$DATE'_output'$(expr $FILE_COUNT + $COUNT)'.txt'
    ABSTRUCT_SEQUENCE=$DATE'_sequence'$(expr $FILE_COUNT + $COUNT)'.fasta'
    echo "blastnを実行しています。"
    blastn -db $DB_DIR/$DB_NAME/$DB_NAME -query $QUERY_DIR/$query_name -out $OUTPUT_DIR/$RESULT_DIR/$OUTPUT_NAME -outfmt "$OUTPUT_FORMAT" $NUM_ALIGN_OPTION "$NUM_ALIGN_OPTION_NUM" 2>> $LOG_FILE

    # blastが失敗した時、エラー
    if [ $? -gt 0 ]; then
        echo "blastnの実行に失敗しました。"
        exit 1
    fi

    echo "blastnの実行に成功しました！"
    echo "続いて、塩基配列の抽出を行います。"


    # 先頭に「#」がついていない行を抽出し、配列に整形したのち重複を削除する
    # NOTE: BSD grepだと「-P」オプションがないため動かない。「grep -ve '#'」にする必要がある
    unique_subject_ids=$(grep -P '^(?!#)' ./$OUTPUT_DIR/$RESULT_DIR/$OUTPUT_NAME | cut -f1 | awk '!a[$0]++' | tr -s '\n' ' ')

    # 空か判定する
    if [ -z $unique_subject_ids ]; then
        echo "blastnでヒットするものがありませんでした。"
        continue
    fi

    # ファイルの抽出-------------------------------------------------------------------------
    # fastaを読み込む
    for subject_id in ${unique_subject_ids[@]}
    do
        cat ./db/$DB_NAME/$DB_NAME | grep $subject_id -A 1 >> ./$OUTPUT_DIR/$SEQUENCE_DIR/$ABSTRUCT_SEQUENCE
    done

    echo "subject idと塩基配列の抽出に成功しました。"
    let COUNT++ # ループするためにインクリメントする
done

echo "すべての処理を終了しました。"   