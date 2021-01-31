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

# ディレクトリ構成
(例)
.
├── README.md
├── db
│   └── db_name
│       ├── db_name.fasta
│       ├── db_name.fasta.ndb
│       ├── db_name.fasta.nhr
│       ├── db_name.fasta.nin
│       ├── db_name.fasta.nog
│       ├── db_name.fasta.nos
│       ├── db_name.fasta.not
│       ├── db_name.fasta.nsq
│       ├── db_name.fasta.ntf
│       └── db_name.fasta.nto
├── exec.sh
├── output
│   └── 2021-01-31_16:56_output1.txt
├── query
│   └── query.fasta
└── setup.sh