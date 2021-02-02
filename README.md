# 概要
- blastnをローカル環境で実行するためのシェル

## バージョン
- 2021/01/31 v1.0.0

## 実行環境
- shまたはbash
- blast
がインストールされていること

# 使用方法
## 手順
1. `sh setup.sh`を実行する
1. db,output,queryディレクトリが作成される
1. `cd db`でディレクトリに移動する
1. `mkdir <DBを保存するディレクトリ名>` でディレクトリを作成する
1. 作成したディレクトリの中に、DB用fastaファイルを保存する
1. `cd <DBを保存するディレクトリ名>`
1. `makeblastdb -in <保存したfastaファイル>.fasta -out <DBを保存するディレクトリ> -dbtype nucl -parse_seqids`を実行する
1. `cd ../../`を行う
1. `sh exec.sh`を実行する

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
│   └── 2021-02-02_23:15_output1.txt
├── query
│   └── 16s.fasta
└── setup.sh

```

# 仕様
- YYYY-MM-DD_HH:SS_output〇〇.txtのフォーマットで出力される
  - 日時は実行するPCのタイムゾーンに依存。確認方法: cat /etc/sysconfig/clock
- blastnに失敗した場合、log.txtに追記されていく

# 困っている点
- blastnオプション「-outfmt」でどの項目を指定したらよいかわからない
- blastnオプション「-culling_limit」が、純粋に件数表示の挙動をしないっぽい？？

# 直したい点
- logファイルを時間を出力するようにしたい
- blastnの実行に失敗しても、outputファイルが出力してしまうので直したい
- 

# 参考
- [blantnのオプションについて](https://www.ncbi.nlm.nih.gov/books/NBK279684/)
- [makeblastdbについて](https://bi.biopapyrus.jp/seq/blast/makeblastdb.html)
