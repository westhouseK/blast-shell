# 概要
blastnをローカル環境で実行するためのシェル

# バージョン
2021/01/31 v1.0.0

# 実行環境
- shまたはbash
- blast
がインストールされていること

# 使用方法
+ sh setup.shを実行する
+ db,output,queryディレクトリが作成される
+ cd dbでディレクトリに移動する
+ mkdir <DBを保存するディレクトリ> でディレクトリを作成する
+ 作成したディレクトリの中に、DB用fastaファイルを保存する
+ cd <DBを保存するディレクトリ>
+ makeblastdb -in <保存したfastaファイル>.fasta -out <DBを保存するディレクトリ> -dbtype nucl -parse_seqidsを実行する
+ cd ../../
+ sh exec.shを実行する

# 仕様
- 2021-1-31_12:34_output1.txtのフォーマットで出力される