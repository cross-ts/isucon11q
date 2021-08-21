# VS ISUCON11q

## Document
- [レギュレーション](https://isucon.net/archives/55854734.html)
- [当日マニュアル](https://gist.github.com/ockie1729/53589a0e8c979198b6231d8599153c70)

## モニタリング結果
- [alp/nginx](./monitor/results/alp.md)
- [pt-query-digest / mysql](./monitor/results/pt-query-digest.txt)

## サーバ環境
### spec
- [CPU](./monitor/results/lscpu.txt): 2 core
- [Memory](./monitor/results/free.txt): 4 GB
- mysql: 5.7

### processes
- [systemd](./monitor/results/list-unit-files.txt)
- [ps](./monitor/results/ps-aufx.txt)

## チートシートリンク
- [mysql](./prepare/mysql/README.md)
- [nginx](./prepare/nginx/README.md)
- [ruby](./prepare/ruby/README.md)
- [kernel](./prepare/kernel/README.md)
- [newrelic](./prepare/newrelic/README.md)

## 開始前対応
```
$ pbcopy < ~/.ssh/isucon_deploykey.pub
$ # deploy keyを登録
$ vim ansible/roles/git/vars/main.yml
```

## 初動
### 手元
```
$ make monitor
$ git cm -am 'make monitor' && git push
$ # monitor/results/list-unit-files.txt 確認
$ vim ansible/roles/group_vars/all.yml
$ make ansible
```

### ssh後
```
$ ssh isucon@isucon1
$ gem install stackprof-webnav
$ echo "NEW_RELIC_LICENSE_KEY=" > env.secret.sh
$ cp -r /etc/nginx/{nginx.conf,conf.d,sites-available} ~/git/isucon/nginx/
$ cp -r /etc/mysql/{mysql.cnf,conf.d,mysql.conf.d} ~/git/isucon/mysql/
$ cp -r /etc/systemd/system/<isucon service files> ~/git/isucon/systemd/
$ cp -r <path to webapp> ~/git/isucon/
$ cp ~/env.sh ~/git/isucon/
$ cd git && git cm -am 'checkin'
$ cd isucon/<path to ruby>
$ vim Gemfile
$ bundle
$ git cm -m 'bundle install'
$ git push
```

### あとは流れで
