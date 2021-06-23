# 概要
- blastnをローカル環境で実行するためのシェル
 - blastnの実行結果がresultに出力される
 - blastnでヒットしたsubject idの塩基配列がsequenceに出力される

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
│   └── 16S_ribosomal_RNA ← ここの名前と配下のファイル名が同じでないといけない
│       ├── 16S_ribosomal_RNA.ndb
│       ├── 16S_ribosomal_RNA.nhr
│       ├── 16S_ribosomal_RNA.nin
│       ├── 16S_ribosomal_RNA.nnd
│       ├── 16S_ribosomal_RNA.nni
│       ├── 16S_ribosomal_RNA.nog
│       ├── 16S_ribosomal_RNA.nos
│       ├── 16S_ribosomal_RNA.not
│       ├── 16S_ribosomal_RNA.nsq
│       ├── 16S_ribosomal_RNA.ntf
│       ├── 16S_ribosomal_RNA.nto
│       ├── 16S_ribosomal_RNA.tar.gz
│       ├── 16S_ribosomal_RNA.tar.gz.md5
│       ├── taxdb.btd
│       └── taxdb.bti
├── exec.sh
├── log.txt
├── output
│   ├── result
│   │   └── 2021-04-18_17:22_output1.txt
│   └── sequence
│       └── 2021-04-18_17:22_sequence1.fasta
├── query
│   └── 16s.fasta
└── setup.sh

```

# 仕様
- YYYY-MM-DD_HH:SS_output〇〇.txtのフォーマットで出力される
  - 日時は実行するPCのタイムゾーンに依存する。確認方法: cat /etc/sysconfig/clock
- blast1にヒットした場合、塩基配列の抽出ファイルがYYYY-MM-DD_HH:SS_sequence〇〇.fastaのフォーマットで出力される
- ./db配下にDB名と同じ、生のfastaファイルを配置する必要がある
> ex) ./db/hogehoge_gene.fasta/hogehoge_gene.fasta ← fastaの生ファイルを配置
- blastnに失敗した場合、log.txtに追記されていく
- クエリは複数選択することができる

# 困っている点
- blastnオプション「-culling_limit」の仕様がドキュメントを読んでもよくわからない

# 直したい点
- logファイルを時間を出力するようにしたい

# 参考
- [blantnのオプションについて](https://www.ncbi.nlm.nih.gov/books/NBK279684/)
- [makeblastdbについて](https://bi.biopapyrus.jp/seq/blast/makeblastdb.html)
