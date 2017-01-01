set background=dark

"ツールバーなし
set guioptions-=T
"メニューバーなし
set guioptions-=m
"下スクロールバーなし
set guioptions-=b

"set formatoptions+=mM
set textwidth=0

" デフォルトvimrc_exampleのtextwidth設定上書き
autocmd FileType text setlocal textwidth=0
