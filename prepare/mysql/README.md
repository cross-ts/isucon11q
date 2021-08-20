# MySQLのconfig周りのチューニング

## NOTE
- 8.0ではquery cacheが存在しないためselect過多なアプリでは注意
- サーバ単位での細かいチューニングポイントは書いてるから読んで

## other
### クエリキャッシュのヒットレート計算
- ヒットレートが悪い場合はキャッシュを増やしてもオーバーヘッドが増える場合がある
- information_schema切ってると動かないかも
```
SELECT (SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'QCACHE_HITS')/(SELECT SUM(VARIABLE_VALUE)
FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME IN ('QCACHE_HITS','QCACHE_INSERTS','QCACHE_NOT_CACHED'))*100 AS CACHE_HIT_RATE;
```

### キャッシュから削除された割合
- これが低い場合はquery_cache_sizeを上げることを検討
```
(SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'QCACHE_LOWMEM_PRUNES') /
(SELECT VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME = 'QCACHE_INSERTS') * 100;
```

### slowログ設定が当たってるかの確認
```
SHOW VARIABLES LIKE 'slow_query%';
```

## etc
### pt-query-digest
```
# Query 1: 1.57 QPS, 0.24x concurrency, ID 0x8A15962AFE6DC78E at byte 54907278
# This item is included in the report because it matches --limit.
# Scores: V/M = 0.32
# Time range: 2021-08-09T04:01:03 to 2021-08-09T04:02:03
# Attribute    pct   total     min     max     avg     95%  stddev  median
# ============ === ======= ======= ======= ======= ======= ======= =======
# Count         10      94
# Exec time     22     15s    11ms      1s   154ms   552ms   224ms    48ms
# Lock time      0    11ms    74us   248us   117us   144us    26us   113us
# Rows sent     41   4.28k       0      50   46.62   49.17   10.80   49.17
# Rows examine   6 620.42k      25  31.25k   6.60k  28.66k   7.62k   3.52k
# Query size     0  36.99k     340     487     403  441.81   26.34  400.73
# String:
# Databases    isuumo
# Hosts        localhost
# Users        isucon
# Query_time distribution
#   1us
#  10us
# 100us
#   1ms
#  10ms  ################################################################
# 100ms  ############################
#    1s  ##
#  10s+
# Tables
#    SHOW TABLE STATUS FROM `isuumo` LIKE 'estate'\G
#    SHOW CREATE TABLE `isuumo`.`estate`\G
# EXPLAIN /*!50100 PARTITIONS*/
SELECT ...
```
- かかった時間のオーダーを確認する
- Rows sent, Rows examineを確認
  - sent, examineに大きな差がある場合
    - indexで解決できない絞り込みが多い
    - countクエリの場合はフルスキャンになるためカウントテーブルを用意することも考える
    - cache等も考える
  - ほとんど差がないがslowに上がってきている場合
    - クエリ自体が遅いのでEXPLAINを確認する
- Scores: V/Mを確認
  - クエリ実行時間の標準偏差
  - 値が小さい場合
    - クエリの実行時間のばらつきが少ない
    - 全体的にクエリが遅い
  - 値が大きい場合
    - 同一クエリだが実行時間が変動する場合がある
    - 特定の場合にindexが効いていない/rows_examinedが大きくなるなど
    - nginxのログ等からも判断する

### mysqltuner
- See: https://github.com/major/MySQLTuner-perl
