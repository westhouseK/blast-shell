# 概要
- blastnをローカル環境で実行するためのシェル
 - blastnの実行結果が出力される
 - blastnでヒットしたsubject idの塩基配列が出力される

## バージョン
- 2021/01/31 v1.0.0
- 2021/05/16 v1.1.0
- 2021/06/23 v1.2.0 クエリを実行するDBを複数選択することができるようにする

## 実行環境
- bash
- blast
がインストールされていること

# 使用方法
## 手順
1. `bash setup.sh`を実行する
1. db,output,queryディレクトリが作成される
1. `cd db`でディレクトリに移動する
1. `mkdir <DBを保存するディレクトリ名>` でディレクトリを作成する
1. 作成したディレクトリの中に、DB用fastaファイルを保存する
1. `cd <DBを保存するディレクトリ名>`
1. `makeblastdb -in <保存したfastaファイル>.fasta -out <DBを保存するディレクトリ> -dbtype nucl -parse_seqids`を実行する
1. `cd ../../`を行う
1. `bash exec.sh`を実行する

# 実行後のディレクトリ構成例
```bash
.
├── README.md
├── db
│   └── xxx
│       ├── xxx.fasta
│       ├── xxx.nhr
│       ├── xxx.nin
│       ├── xxx.nog
│       ├── xxx.nsd
│       ├── xxx.nsi
│       └── xxx.nsq
├── error.log
├── exec.sh // メインのシェルスクリプト
├── output
│   ├── result
│   │   ├── 2021-06-24_00:34_output1.txt
│   │   ├── 2021-06-24_00:34_output2.txt
│   │   ├── 2021-06-24_00:34_output3.txt
│   │   └── 2021-06-24_00:34_output4.txt
│   └── sequence
│       └── 2021-06-24_00:34_sequence1.fasta // outputの一番若い番号になる
│       
├── query
│   └── query.txt
├── setup.sh
└── test.sh

```

# シェルについて
## 仕様
- dbは複数選択することができる
- blastnに失敗した場合、error.logに追記されていく

## 出力フォーマット
- 結果 -> YYYY-MM-DD_HH:SS_output〇〇.txt
- 配列 -> YYYY-MM-DD_HH:SS_sequence〇〇.fasta

## 注意点
- 日時は実行するPCのタイムゾーンに依存する。確認方法: cat /etc/sysconfig/clock
- ./db配下に「db名.fasta」ファイルを配置する必要がある
> ex) ./db/hoge/hogehoge.fasta ← DB作成に使ったfastaファイルを配置

# 困っている点
- blastnオプション「-culling_limit」の仕様がドキュメントを読んでもよくわからない

# 直したい点
- logファイルを時間を出力するようにしたい

# 参考
- [blantnのオプションについて](https://www.ncbi.nlm.nih.gov/books/NBK279684/)
- [makeblastdbについて](https://bi.biopapyrus.jp/seq/blast/makeblastdb.html)
