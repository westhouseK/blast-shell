#!/bin/bash

# ------------------------------------------------
# 
# blastを実行する
# 実行方法: sh exec.sh
# 実行条件: shまたはbashが、インストールされていること
# 実行ログを残したい時: sh exec.sh > histoy.txt
#
# ------------------------------------------------

# 定数を宣言
# ディレクトリ名
readonly DB_DIR="db"
readonly QUERY_DIR="query"
readonly OUTPUT_DIR="output"
readonly RESULT_DIR="result"
readonly SEQUENCE_DIR="sequence"
readonly LOG_FILE="error.log"

# 対話式の選択肢
readonly ENTER="Enter"
readonly ALL="All"
readonly NEXT="Next"
readonly EXIT="Exit"

# blastのオプション
readonly OUTPUT_FORMAT="7 sseqid evalue score bitscore length qseqid pident qseq sseq"
readonly NUM_ALIGN_OPTION="-num_alignments"
readonly NUM_ALIGN_OPTION_NUM="1"

# 出力ファイルのフォーマット
readonly RESULT_FILE_FORMAT="%s_output%s.txt"
readonly SEQUENCE_FILE_FORMAT="%s_sequence%s.fasta"
readonly ABSTRUCTED_FASTA_FILE_FORMAT="%s.fasta"

# 事前チェック-------------------------------------------------------------------------
echo "-----------------------------------------"
echo "blastを実行しますか？ (y or Enter/n)"
echo "-----------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

# ディレクトリが存在しない場合、エラー
if [ ! -d $DB_DIR -o ! -d $QUERY_DIR -o ! -d $OUTPUT_DIR -o ! -d $OUTPUT_DIR/$RESULT_DIR -o ! -d $OUTPUT_DIR/$SEQUENCE_DIR ]; then
    echo "ディレクトリの作成を先に行ってください。"
    echo "setup.shを実行してください。"
    exit 1
fi

# 選択-------------------------------------------------------------------------
echo "-----------------------------------------"
echo "blastを選択してください。"
echo " [$EXIT] -> 終了"
echo "-----------------------------------------"
select blast in 'blastn' 'blastx' $EXIT 
do
    if [ $blast = $EXIT ]; then
        echo "スクリプトを終了しました。"
        exit 1
    fi
    break
done

echo "-----------------------------------------"
echo "クエリを選択してください。"
echo " [$EXIT] -> 終了"
echo "-----------------------------------------"
select query_name in $(ls ./$QUERY_DIR) $EXIT 
do
    if [ $query_name = $EXIT ]; then
        echo "スクリプトを終了しました。"
        exit 1
    fi
    break
done

echo "-----------------------------------------"
echo "データベースを選択してください。"
echo " [$ENTER] -> 選択肢を表示"
echo " [$ALL]   -> すべてのDBに対してクエリを実行"
echo " [$NEXT]  -> 次に進む"
echo " [$EXIT]  -> 終了"
echo "-----------------------------------------"
db_names=()
select db_name in $ALL $(ls ./$DB_DIR) $NEXT $EXIT 
do
    case $db_name in 
        $EXIT)
            echo "スクリプトを終了しました。"
            exit 1;;
        $ALL)
            db_names=$(ls ./$DB_DIR)
            echo "すべてを選択しました。"
            echo "選択完了です。"
            break;;
        $NEXT)
            if [ ${#db_names[@]} -eq 0 ]; then
                echo "クエリを選択していないため、終了しました。"
                exit 1
            fi
            echo "選択完了です。"
            break;;
        *)
            db_names+=($db_name)
            echo "続いて選択してください。";;
    esac
done

echo "-----------------------------------------"
echo "以下の条件で実行してもよろしいですか？ (y or Enter/n)"
echo "選択したblast: $blast"
echo "選択したクエリ: $query_name"
echo "選択したデータベース: $(echo ${db_names[@]} | sed -e 's/ /, /g')"
echo "-----------------------------------------"
read input

if [ ! $input = 'y' ]; then
    echo "スクリプトを終了しました。"
    exit 1
fi

# メインの処理(blast)-------------------------------------------------------------------------
# 出力先のファイルをフォーマット
# NOTE: 2021-1-31_12:34 (実行するPCのタイムゾーンに依存。確認方法: cat /etc/sysconfig/clock)
date=$(date '+%Y-%m-%d_%H:%M')
# 結果出力ファイル名のシーケンスを行うために、MAX値+1を取得
file_sequence_num=$(find ./$OUTPUT_DIR/$RESULT_DIR -type f -not -name '.*' | wc -l | tr -d ' ' | xargs -Imax expr max + 1)
sequence=$file_sequence_num

for db_name in ${db_names[@]}
do
    # blastの実行-------------------------------------------------------------------------
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    result_file_name="$(printf $RESULT_FILE_FORMAT $date $sequence)"
    sequence_file_name="$(printf $SEQUENCE_FILE_FORMAT $date $file_sequence_num)" # 一番若い番号に集約
    echo "<$blast>を実行中[クエリ($query_name) -> データベース($db_name)]"
    $blast -db $DB_DIR/$db_name/$db_name -query $QUERY_DIR/$query_name -out $OUTPUT_DIR/$RESULT_DIR/$result_file_name -outfmt "$OUTPUT_FORMAT" $NUM_ALIGN_OPTION "$NUM_ALIGN_OPTION_NUM" 2>> $LOG_FILE

    # blastが失敗した時、エラー
    if [ $? -gt 0 ]; then
        echo "blastの実行に失敗しました。"
        exit 1
    fi

    echo "blastの実行に成功しました！"

    # 先頭に「#」がついていない行を抽出し、配列に整形したのち重複を削除する
    # NOTE: BSD grepだと「-P」オプションがないため動かない。「grep -ve '#'」にする必要がある
    unique_subject_ids=$(grep -P '^(?!#)' ./$OUTPUT_DIR/$RESULT_DIR/$result_file_name | cut -f1 | awk '!a[$0]++' | tr -s '\n' ' ')

    # 空か判定する
    if [ -z $unique_subject_ids ]; then
        echo "blastでヒットするものがありませんでした。"
        continue
    fi

    echo "続いて、$(printf $ABSTRUCTED_FASTA_FILE_FORMAT $db_name)から抽出を行います。"

    # ファイルの抽出-------------------------------------------------------------------------
    for subject_id in ${unique_subject_ids[@]}
    do
        # タンパク質の場合、不要な文字列を削除する
        if [ $blast = 'blastx' ]; then
            tmp_subject_id=$subject_id
            subject_id=$(echo "$subject_id" | cut -d '_' -f 1-4)
            echo "blastnの実行結果から塩基配列ファイルに検索をかけるため、文字列を加工する[$tmp_subject_id->$subject_id]"
        fi 
        cat ./db/$db_name/"$(printf $ABSTRUCTED_FASTA_FILE_FORMAT $db_name)" | grep $subject_id -A 1 >> ./$OUTPUT_DIR/$SEQUENCE_DIR/$sequence_file_name
    done

    echo "$(echo ${unique_subject_ids[@]} | sed -e 's/ /, /g')の${#unique_subject_ids[@]}件がヒットしました。"
    let sequence++ # ループするためにインクリメントする
done

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "すべての処理を終了しました。"   