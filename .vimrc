set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
scriptencoding utf-8

" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

"改行コード
set fileformats=unix,dos,mac

"------------------------
" 基本設定
"------------------------

"色設定
syntax on
colorscheme molokai
set t_Co=256

"タブの設定
set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab
set autoindent

"検索
set incsearch
set ignorecase
set smartcase

set number "行数表示

"コマンドラインの高さ
set cmdheight=1

"バックスペースで何でも消したい
set backspace=indent,eol,start

"タブバー常に表示
set showtabline=2

"タブ文字可視化
set list
set listchars=tab:>\ 

set noswapfile
set nobackup
set autoread

"ステータスラインの表示設定
set laststatus=2

"exモードの補完
set wildmenu
set wildmode=list:longest,full

"windwowの高さ、幅
"set winheight=100
set winwidth=78

" 下に開く
set splitbelow

set helplang=ja
set foldmethod=manual
set vb t_vb=

" Go
let g:go_fmt_command = 'goimports'
let g:go_fmt_autosave = 0
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_def_mapping_enabled = 0

set completeopt=menu,preview

"-----------------------
" autocmd
"------------------------
augroup MyAutoCmd
  autocmd!

  " 全角スペース
  highlight JpSpace cterm=underline ctermfg=red guifg=red
  au BufRead,BufNew * match JpSpace /　/

  " 行末スペース
  highlight WhitespaceEOL ctermbg=red guibg=red
  au BufRead,BufNew,WinEnter * match WhitespaceEOL /\s\+$/

  au BufNewFile,BufRead *.go set sw=4 noexpandtab ts=4
  au FileType go compiler go
  au BufNewFile,BufReadPost *.mt,*.tt,*.tx set filetype=html
  au BufNewFile,BufReadPost *.psgi,*.t,cpanfile,Daikufile set filetype=perl
  au BufNewFile,BufReadPost *.ru set filetype=ruby
  au BufNewFile,BufReadPost *.md set filetype=md
  au BufNewFile,BufReadPost Dockerfile set filetype=Dockerfile
  au BufNewFile,BufRead *.rb set sw=2 expandtab ts=2
  au FileType perl,cgi :compiler perl
  au BufNewFile,BufRead *.scala set tags+=.git/scala.tags
  au FileType perl set isfname-=- isfname-=/ isfname-=+
  au FileType perl nnoremap <Space>pr :!prove %<CR>
  au FileType html :setlocal path+=;/
  au BufNewFile *.pm call s:pm_template()
  au BufNewFile *.pl 0r $HOME/.vim/template/perl-script.txt
  au BufNewFile *.t  0r $HOME/.vim/template/perl-test.txt
  au CmdwinEnter * call s:init_cmdwin()
  au FileType scala :compiler sbt
  au QuickFixCmdPost make if len(getqflist()) != 0 | copen | endif

  " see http://vim-jp.org/vim-users-jp/2009/11/01/Hack-96.html
  au FileType *
  \   if &l:omnifunc == ''
  \ |   setlocal omnifunc=syntaxcomplete#Complete
  \ | endif
augroup END

" タブラインの設定
set tabline=%!MyTabLine()

function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " 強調表示グループの選択
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " タブページ番号の設定 (マウスクリック用)
    let s .= '%' . (i + 1) . 'T'

    " ラベルは MyTabLabel() で作成する
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " 最後のタブページの後は TabLineFill で埋め、タブページ番号をリセッ
  " トする
  let s .= '%#TabLineFill#%T'

  " カレントタブページを閉じるボタンのラベルを右添えで作成
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  return expand("#".buflist[winnr - 1].":t")
endfunction

"------------------------
" キーバインド
"------------------------
"; to :
nnoremap ; :

"単語検索
nnoremap * g*
nnoremap # g#

"タブ切り替え
nnoremap <C-l> gt
nnoremap <C-h> gT
nmap <C-t> :tabnew %:h<cr>

" 現在のタブを右へ移動
nnoremap <Tab>n :MyTabMoveRight<CR>
" 現在のタブを左へ移動
nnoremap <Tab>p :MyTabMoveLeft<CR>
command! -count=1 MyTabMoveRight call MyTabMove(<count>)
command! -count=1 MyTabMoveLeft  call MyTabMove(-<count>)
function! MyTabMove(c)
  let current = tabpagenr()
  let max = tabpagenr('$')
  let target = a:c > 1       ? current + a:c - line('.') :
             \ a:c == 1      ? current :
             \ a:c == -1     ? current - 2 :
             \ a:c < -1      ? current + a:c + line('.') - 2 : 0
  let target = target >= max ? target % max :
             \ target < 0    ? target + max :
             \ target
  execute ':tabmove ' . target
endfunction


"タブ文字（\t）を入力
inoremap <C-Tab> <C-v><Tab>

"ビジュアルモードで選択して検索
vnoremap * "zy:let @/ = @z<CR>n

"ビジュアルモードで選択して置換。とりあえず/だけエスケープしとく
vnoremap <C-s> "zy:%s/<C-r>=escape(@z,'/')<CR>/

"入力モードで削除
inoremap <C-d> <Del>
inoremap <C-h> <BackSpace>

"コマンドモードの履歴
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"コマンドモードでペースト
cnoremap <C-y> <C-r>"

"文字コード変更して再読み込み
nnoremap <silent> eu :<C-u>e ++enc=utf-8<CR>
nnoremap <silent> ee :<C-u>e ++enc=euc-jp<CR>
nnoremap <silent> es :<C-u>e ++enc=cp932<CR>

"pasteモードトグル
nnoremap <Space>tp :<C-u>set paste!<CR>

"help
nnoremap <Space>h :<C-u>vert bel h<Space>

"補完候補があってもEnterは改行
inoremap <expr> <CR> pumvisible() ? "\<C-e>\<CR>" : "\<CR>"

"スクロール
nnoremap <C-e> <C-e>j
nnoremap <C-y> <C-y>k
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

"折り返しもカーソル移動
nnoremap j gj
nnoremap k gk

" <C-u>とかのundo
inoremap <C-u>  <C-g>u<C-u>
inoremap <C-w>  <C-g>u<C-w>

" onmi補完 Ctrl+Space
imap <Nul> <C-x><C-o>

map gf <C-w>gf

"------------------------
" プラグインの設定
"------------------------

"http://hail2u.net/blog/software/support-slash-started-relative-url-in-vim-gf.html
set includeexpr=substitute(v:fname,'^\\/','','')

" align.vimのおぺれーた
vmap <Space>a <leader>tsp
vnoremap <Space>= :Align =<CR>
vnoremap <Space>h :Align =><CR>

" package名チェック
function! s:get_package_name()
  let mx = '^\s*package\s\+\([^ ;]\+\)'
  for line in getline(1, 5)
    if line =~ mx
      return substitute(matchstr(line, mx), mx, '\1', '')
    endif
  endfor
  return ""
endfunction

function! s:check_package_name()
  let path = substitute(expand('%:p'), '\\', '/', 'g')
  let name = substitute(s:get_package_name(), '::', '/', 'g') . '.pm'
  if path[-len(name):] != name
    echohl WarningMsg
    echomsg "ぱっけーじめいと、ほぞんされているぱすが、ちがうきがします！"
    echomsg "ちゃんとなおしてください＞＜"
    echohl None
  endif
endfunction

au! BufWritePost *.pm call s:check_package_name()

" パスの追加
let s:paths = split($PATH, ':')
function! g:Insert_path(path)
    let index = index(s:paths, a:path)
    if index != -1
        call remove(s:paths, index)
    endif
    call insert(s:paths, a:path)
    let $PATH = join(s:paths, ':')
endfunction

" local設定ファイル
let local_vimrc = $HOME."/.vimrc.local"
if (filereadable(local_vimrc))
    execute "source " . local_vimrc
endif

" clipboard
nnoremap <Space>p :call system("pbcopy", @")<CR>
nnoremap <Space>v :r !pbpaste<CR>

" command履歴
cnoremap <Up> <C-p>
cnoremap <Down> <C-n>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

"" neocomplecache
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

 " Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Select with <TAB>
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

let g:neocomplcache_ctags_arguments_list = {
  \ 'perl' : '-R -h ".pm"'
  \ }

let g:neocomplcache_snippets_dir = "~/.vim/snippets"
" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default'    : '',
    \ 'perl'       : $HOME . '/.vim/dict/perl.dict',
    \ 'scala'      : $HOME . '/.vim/dict/scala.dict'
    \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" for snippets
imap <expr><C-k> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<C-n>"
smap <C-k> <Plug>(neosnippet_expand_or_jump)

function! s:pm_template()
    let path = substitute(expand('%'), '.*lib/', '', 'g')
    let path = substitute(path, '[\\/]', '::', 'g')
    let path = substitute(path, '\.pm$', '', 'g')

    call append(0, 'package ' . path . ';')
    call append(1, 'use strict;')
    call append(2, 'use warnings;')
    call append(3, 'use utf8;')
    call append(4, '')
    call append(5, '')
    call append(6, '')
    call append(7, '1;')
    call cursor(6, 0)
    " echomsg path
endfunction

" command line window cf. http://vim-jp.org/vim-users-jp/2010/07/14/Hack-161.html
nnoremap <sid>(command-line-enter) q:
xnoremap <sid>(command-line-enter) q:
nnoremap <sid>(command-line-norange) q:<C-u>

function! s:init_cmdwin()
  nnoremap <buffer> q :<C-u>quit<CR>
  nnoremap <buffer> <TAB> :<C-u>quit<CR>
  inoremap <buffer><expr><CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
  inoremap <buffer><expr><C-h> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"
  inoremap <buffer><expr><BS> pumvisible() ? "\<C-y>\<C-h>" : "\<C-h>"

  " Completion.
  inoremap <buffer><expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

  startinsert!
endfunction

" tagbar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_left = 0
let g:tagbar_autofocus = 1

if !exists("g:quickrun_config")
    let g:quickrun_config={}
endif

let g:quickrun_config['_'] = {
    \ 'outputter/buffer/split' : '%{winwidth(0) * 2 < winheight(0) * 5 ? "" : "vertical belowright"}',
\ }

let g:quickrun_config['md'] = {
    \ 'type' : 'markdown',
\ }

let g:tagbar_type_scala = {
    \ 'ctagstype' : 'Scala',
    \ 'kinds'     : [
        \ 'p:packages:1',
        \ 'V:values',
        \ 'v:variables',
        \ 'T:types',
        \ 't:traits',
        \ 'o:objects',
        \ 'a:aclasses',
        \ 'c:classes',
        \ 'r:cclasses',
        \ 'm:methods'
    \ ]
\ }

let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : 'markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

" let g:auto_ctags = 1
let g:auto_ctags_directory_list = ['.git', '.svn']
let g:auto_ctags_tags_args = '--tag-relative --recurse --sort=yes'
let g:auto_ctags_filetype_mode = 1

if has('conceal')
  set conceallevel=1 concealcursor=
endif
let g:neosnippet#enable_snipmate_compatibility = 1

let g:vim_markdown_frontmatter=1
let g:vim_markdown_folding_disabled=1
let g:vim_markdown_conceal = 0

" json
let g:vim_json_syntax_conceal = 0

" open-browser
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
let g:ctrlp_user_command = 'files -A -a %s'

noremap <silent> <leader>g :<c-u>CtrlPGhq<cr>
noremap <silent> <leader>m :<c-u>CtrlPMixed<cr>

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/ctrlp-ghq'
Plug 'Shougo/neocomplcache'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'thinca/vim-ref'
Plug 'tsaleh/vim-align'
Plug 'vim-scripts/closetag.vim'
Plug 'mattn/gist-vim'
Plug 'mattn/webapi-vim'
Plug 'mattn/vimplenote-vim'
Plug 'kchmck/vim-coffee-script'
Plug 'tpope/vim-fugitive'
Plug 'taglist.vim'
Plug 'vim-perl/vim-perl'
Plug 'vim-jp/vimdoc-ja'
Plug 'airblade/vim-rooter'
Plug 'motemen/xslate-vim'
Plug 'mattn/sonictemplate-vim'
Plug 'chase/vim-ansible-yaml'
Plug 'dgryski/vim-godef'
Plug 'derekwyatt/vim-scala'
Plug 'majutsushi/tagbar'
Plug 'soramugi/auto-ctags.vim'
Plug 'gre/play2vim'
Plug 'leafgarland/typescript-vim'
Plug 'clausreinke/typescript-tools.vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'elzr/vim-json'
Plug 'tyru/open-browser.vim'
Plug 'fatih/vim-go'
Plug 'nixprime/cpsm'
Plug 'justinmk/vim-dirvish'
Plug 'itchyny/lightline.vim'

call plug#end()

filetype plugin indent on
