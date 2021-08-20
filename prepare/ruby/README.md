# Ruby周りのチューニング

## コーディング周り
### Rcator
- See
  - [Document](https://github.com/ruby/ruby/blob/master/doc/ractor.md)
  - [Cookpad Developers' Blog](https://techlife.cookpad.com/entry/2020/12/26/131858)
- Ruby 3.0から導入された並列処理を気軽に書くための仕組み
  - experimentalなのは留意すること
  - またRactorは新規スレッドを作成しそこで実行する
  - Rubyのスレッド実装はネイティブスレッドなので注意
  - またGVLがあるのでそれも注意

#### code sample
- 適当なコード周りはこんな感じ
- Document, クックパッド開発者ブログの解説記事も見て
```
def fib(n)
  return n if n < 2
  fib(n - 1) + fib(n - 2)
end

2.times.map { Ractor.new { fib(40) } }.map(&:take)

r = Ractor.new do
  Ractor.receive
end

r.send(:ok)
p r.take

r = Ractor.new do
  Ractor.receive_if do |msg|
    case msg
    when 100
      break msg * 2
    when 200
      break msg * 4
    end
  end
end

r.send 100
p r.take
```

## jemalloc
- Rubyのメモリ周りの改善に
  - Ractor使いまくってるとメモリ食う可能性が

### enable
#### LD_PRELOADを使う場合
- See: https://techracho.bpsinc.jp/hachi8833/2017_12_28/50109

#### ビルドしなおす場合
```
$ git clone https://github.com/tagomoris/xbuild.git
$ RUBY_CONFIGURE_OPTS=--with-jemalloc xbuild/ruby-install 3.0.2 ~/local/ruby3
$ ruby -r rbconfig -e 'puts RbConfig::CONFIG["MAINLIBS"]' # check
```

## stackprof
- webnavも合わせることでRubyのcallgraph/framegraphをいい感じにwebで確認できるようになる
- 使い方は見ればわかるので割愛

### enable
```
gem 'stackprof'
```

- Rack周りに下記を追加
```
use StackProf::Middleware, enalbed: true,
                           mode: :wall,
                           interval: 1000,
                           save_every: 5,
                           raw: true,
                           path: '/home/isucon/stackprof/'
```

```
$ : # nginxでいい感じにするとかは自由に
$ bundle exec stackprof-webnav -d /home/isucon/stackprof
```
