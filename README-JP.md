# DON't USE THIS
実験的段階です。
CUIモードのカラー設定は、Predefined なカラーのみサポート(色の直接指定はGUIモードのみ)。

# コレは何？
ミニマリスト向けの statuline 設定ヘルパー。

# 特徴
* ファンシーなカラーテーマはなし。
* シンプルなデザイン。Vim Scripter にとって設定しやすい。親切なエラー回避が無い。
* 条件によって動的に色を変えたり、ステータスラインのレイアウト自体を変えられる。
* 全てのステータスラインの部品(part)は、辞書関数として実装される。
* ユーザー関数よりも優先される定義済みの関数はほぼ無く、全てはユーザーの設定次第。

# スクリーン画像
* Gitブランチが master でない場合に色を変える。  
![ConditionalColor-1](https://raw.github.com/t9md/t9md/master/img/ezbar/ezbar_conditional_color1.png)  
![ConditionalColor-2](https://raw.github.com/t9md/t9md/master/img/ezbar/ezbar_conditional_color2.png)  

* 特定のプラグインのモードが発動した場合にステータスラインの他の部品を隠す(easymotion 等で使う。)  
![Fill-1](https://raw.github.com/t9md/t9md/master/img/ezbar/ezbar_fill1.png)  
![Fill-2](https://raw.github.com/t9md/t9md/master/img/ezbar/ezbar_fill2.png)  

# コンセプト
* ユーザーの設定は `g:ezbar` 辞書に保存する。
* どの部品(part)が表示されるかは、`g:ezbar.active.layout`, `g:ezbar.inactive.layout` 配列で制御する。
  ```Vim
  " アクティブウィンドウのステータスライン
  let g:ezbar.active.layout = [
        \ 'mode',
        \ 'filetype',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ ]
  " 非アクティブウィンドウのステータスライン
  let g:ezbar.inactive.layout = [
        \ 'filetype',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ ]
  ```

* レイアウトは、パート(`part`) で構成される。各パートは `g:ezbar.parts[{part}]()` 関数の呼び出し結果に対応する。
  ```Vim
  let g:ezbar.active.layout = [
        \ 'mode',        <-- g:ezbar.parts.mode()
        \ 'filetype',    <-- g:ezbar.parts.filetype()
        \ '__SEP__',     <-- g:ezbar.parts.__SEP__()
        \ 'encoding',    <-- g:ezbar.parts.encoding()
        \ 'percent',     <-- g:ezbar.parts.percent()
        \ ]
  ```

* したがって、ユーザーが設定することは、自分のパート関数を書き、その関数名をレイアウトの中で使うこと。
  ```Vim
  let g:ezbar.active.layout = [
        \ 'my_encoding', <-- g:ezbar.parts.my_encoding()
        \ ]
  function! g:ezbar.parts.my_encoding()
    return &encoding
  endfunction
  ```

* しかし、全関数を自分自身で設定するのは面倒な場合もある。その場合は、他のユーザーが書いたパーツ(partの集合)辞書をマージすれば良い。
  ```Vim
  let u = {}
  function! u.my_encoding()
    return &encoding
  endfunction
  let g:ezbar.parts = extend(ezbar#parts#default#new(), u)
  unlet u
  ```

* 各パート関数は、単なる文字列か辞書を返さなければならない。
  ```Vim
  " 単なる文字列
  function! u.my_encoding()
    return &encoding
  endfunction

  " 辞書。git ブランチが 'master' でない場合には色を変える。
  function! u.fugitive() "{{{1
    let s = fugitive#head()
    if empty(s)
      return ''
    endif
    return { 's' : s, 'c': s == 'master'
          \ ?  ['gray18', 'gray61']
          \ :  ['red4', 'gray61']
          \ }
  endfunction
  let g:ezbar.parts = extend(ezbar#parts#default#new(), u)
  unlet u
  ```

パート関数が「 空の文字列、空の辞書、's' フィールドが空の辞書 」のいずれかを返した場合、そのパートはステータスラインに表示されない。

* 上の例で見たように、パートの中で色を直接指定することが出来る。
  ```Vim
  " 色を直接指定する。['guibg', 'guifg' ]
  { 's' : "foo", 'c': ['gray18', 'gray61'] }

  " 定義済みの色(ハイライトグループ)を使う。
  { 's' : "foo", 'c': 'Statement' }

  " オプショナルとして使用可能な色に 'ac'(アクティブウィンドウ用)と 'ic'(非アクティブなウィンドウ用)がある。
  " ** どの色が適用されるかは以下の優先度で決まる。
  "   アクティブウィンドウ:   'ac' => 'c' => g:ezbar.active.default_color
  "   非アクティブウィンドウ: 'ic' => 'c' => g:ezbar.inactive.default_color
  { 's': 'bar', 'ac' : ['gray40', 'gray95'] }
  ```

* どの色が利用できるか調べるには？
`:help rgb.txt`  
`:edit misc/colortest/compact.vim` してから `%so`  
`:so misc/colortest/full.vim` してから `%so`  

* パート関数の中では、`self.__is_active` がアクティブ、非アクティブの判断に使用可能。
```Vim
  function! f.percent() "{{{1
    let s  = '%3p%%'
    " アクティブの場合のみ色をつける。
    if g:ezbar.parts.__is_active
      return { 's': s, 'c' : ['gray40', 'gray95'] }
    else
      return s
    endif
  endfunction
```

# 設定サンプル
サンプルの設定ファイルは[ここ](https://github.com/t9md/vim-ezbar/tree/master/misc/config_sample)にある。

設定を試行錯誤する時は以下のコマンドが助けになるかもしれない。  
* `:EzBarUpdate` で現在のウィンドウ(アクティブウィンドウ)のステータスラインを更新する。  
* `:EzBarDisable` は EzBar が設定する autocmd を削除する。  
* `:EzBarSet` 全ウィンドウのステータスラインを設定する。  
* `:'<,'>EzBarColorPreview` 選択した行を `matchadd()` でハイライトする。色のプレビューに使う。  
* `:echo ezbar#string('active')` or `:echo ezbar#string('inactive')` 最終的に設定されるステータスラインの文字列を返す。  

## ベーシック
  ```Vim
  let g:ezbar = {}
  let g:ezbar.active = {}
  let s:bg = 'gray25'
  let g:ezbar.active.default_color = [ s:bg, 'gray61']
  let g:ezbar.active.sep_color = [ 'gray22', 'gray61']
  let g:ezbar.inactive = {}
  let g:ezbar.inactive.default_color = [ 'gray22', 'gray57' ]
  let g:ezbar.inactive.sep_color = [ 'gray23', 'gray61']
  let g:ezbar.active.layout = [
        \ 'mode',
        \ 'textmanip',
        \ 'smalls',
        \ 'modified',
        \ 'filetype',
        \ 'fugitive',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ 'line_col',
        \ ]
  let g:ezbar.inactive.layout = [
        \ 'modified',
        \ 'filename',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ ]

  let u = {}
  function! u.textmanip() "{{{1
    let s = toupper(g:textmanip_current_mode[0])
    return { 's' : s, 'c': s == 'R'
          \ ?  [ s:bg, 'HotPink1']
          \ :  [ s:bg, 'PaleGreen1'] }
  endfunction
  function! u.smalls() "{{{1
    let s = toupper(g:smalls_current_mode[0])
    if empty(s)
      return ''
    endif
    return { 's' : 'smalls-' . s, 'c':
          \ s == 'E' ? 'SmallsCurrent' : 'Function' }
  endfunction

  function! u.fugitive() "{{{1
    let s = fugitive#head()
    if empty(s)
      return ''
    endif
    return { 's' : s, 'c': s == 'master'
          \ ?  ['gray18', 'gray61']
          \ :  ['red4', 'gray61']
          \ }
          " \ ?  ['red4', 'gray61']
  endfunction

  let g:ezbar.parts = extend(ezbar#parts#default#new(), u)
  unlet u
  ```

## 応用
  ```Vim
  let s:bg = 'gray25'

  let g:ezbar = {}
  let g:ezbar.active = {}
  let g:ezbar.active.default_color = [ s:bg, 'gray61']
  let g:ezbar.active.sep_color = [ 'gray30', 'gray61']
  let g:ezbar.inactive = {}
  let g:ezbar.inactive.default_color = [ 'gray18', 'gray57' ]
  let g:ezbar.inactive.sep_color = [ 'gray23', 'gray61']
  let g:ezbar.active.layout = [
        \ 'mode',
        \ 'textmanip',
        \ 'smalls',
        \ 'modified',
        \ 'filetype',
        \ 'fugitive',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ 'line_col',
        \ ]
  let g:ezbar.inactive.layout = [
        \ 'modified',
        \ 'filename',
        \ '__SEP__',
        \ 'encoding',
        \ 'percent',
        \ ]

  let u = {}
  function! u.textmanip() "{{{1
    return toupper(g:textmanip_current_mode[0])
  endfunction
  function! u.smalls() "{{{1
    let s = toupper(g:smalls_current_mode[0])
    if empty(s)
      return ''
    endif
    let self.__smalls_active = 1
    let color = s == 'E' ? 'SmallsCurrent' : 'SmallsCandidate'
    return { 's' : 's', 'c': color }
  endfunction

  function! u.fugitive() "{{{1
    return fugitive#head()
  endfunction

  " `_init()` は特別な関数。`g:ezbar.parts._init` が関数であれば呼ばれる。
  " 状態管理に使うフィールドを定義する場合に使う。
  function! u._init() "{{{1
    let self.__smalls_active = 0
  endfunction

  " `_filter()` は特別な関数。`g:ezbar.parts._filter` が関数であれば呼ばれる。
  " ezbar は標準化した(辞書化して 'name' フィールドを定義) レイアウトを引数として呼び出す。
  function! u._filter(layout) "{{{1
    if self.__smalls_active && self.__is_active
      " smalls がアクティブの場合は、目立つようにステータスラインを占領する(他のパートを消す。)
      return filter(a:layout, 'v:val.name == "smalls"')
    endif

    let r =  []
    " 各パート関数の中で色を設定する代わりに、ここで設定することも可能。
    for part in a:layout
      if part.name == 'fugitive'
        let part.c = part.s == 'master' ?  ['gray18', 'gray61'] : ['red4', 'gray61']
      elseif part.name == 'textmanip'
        let part.c = part.s == 'R' ? [ s:bg, 'HotPink1'] :  [ s:bg, 'PaleGreen1']
      endif
      call add(r, part)
    endfor
    return r
  endfunction

  let g:ezbar.parts = extend(ezbar#parts#default#new(), u)
  unlet u
  ```