"------------------------
" 基本設定
"------------------------

"色設定
syntax on
colorscheme mycolor

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
set nohlsearch

"行数表示
set number

"対応する括弧表示しない
set noshowmatch

"コマンドラインの高さ
set cmdheight=1

"バックスペースで何でも消したい
set backspace=indent,eol,start

"タブバー常に表示
set showtabline=2

"タブ文字可視化
set list
set listchars=tab:>\ 

"swapファイル作らない
set noswapfile

"backupしない
set nobackup

"他で編集されたら読み込み直す
set autoread

"ステータスラインの表示設定
set laststatus=2
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']['.&ft.']'}%=%l,%c%V%8P

"exモードの補完
set wildmenu
set wildmode=list:longest,full

"補完
set complete=.,w,b,u,k
"set completeopt=menu,preview,longest
set pumheight=20

"ftplugin有効
filetype plugin on

" 新規windowを右側に開く
nnoremap <C-w>v :<C-u>belowright vnew<CR>

"windwowの高さ、幅
"set winheight=100
set winwidth=78

" 下に開く
set splitbelow

" 全角スペース
highlight JpSpace cterm=underline ctermfg=red guifg=red
au BufRead,BufNew * match JpSpace /　/

" 行末スペース
highlight WhitespaceEOL ctermbg=red guibg=red
au BufRead,BufNew,WinEnter * match WhitespaceEOL /\s\+$/

set helplang=ja

"-----------------------
" autocmd
"------------------------
augroup MyAutoCmd
  autocmd!
augroup END

"mtとttをhtmlに
autocmd MyAutoCmd BufNewFile,BufReadPost *.mt,*.tt set filetype=html

"psgiとtはperl
autocmd MyAutoCmd BufNewFile,BufReadPost *.psgi,*.t set filetype=perl

"ruをrubyに
autocmd MyAutoCmd BufNewFile,BufReadPost *.ru set filetype=ruby

"asをactionscriptに
autocmd MyAutoCmd BufNewFile,BufReadPost *.as set filetype=actionscript

"markdownのfiletypeをセット
autocmd MyAutoCmd BufNewFile,BufReadPost *.md set filetype=md

"なぜかnoexpandtabになることがあるので
"autocmd MyAutoCmd BufNewFile,BufReadPost * set expandtab

"ディレクト自動移動
autocmd MyAutoCmd BufNewFile,BufReadPost *
\ execute ":lcd " . substitute(substitute(expand("%:p:h"), ' ', '\\ ', 'g'), '#', '\\#', 'g')

" カレントバッファのファイルを再読み込み。filetypeがvimかsnippetsのときだけ。
nnoremap <silent> <Space>r :<C-u>
\ if &ft == 'vim' <Bar>
\     source % <Bar>
\ elseif &ft == 'snippet' <Bar>
\     call SnipMateReload() <Bar>
\ endif<CR>

" s:snippetsを外からunletできないので以下の関数をplugin/snipMate.vimに書く
function! SnipMateReload()
    if &ft == 'snippet'
        let ft = substitute(expand('%'), '.snippets', '', '')
        call ResetSnippet(ft)
        silent! call GetSnippets(g:snippets_dir, ft)
    endif
endfunction


" オレオレgrep
command! -complete=file -nargs=+ Grep call s:grep(<q-args>)
function! s:grep(args)
    execute 'vimgrep' '/' . a:args . '/j **/*'
    if len(getqflist()) != 0 | copen | endif
endfunction

autocmd FileType perl,cgi :compiler perl

"-----------------------
" 文字コードとかの設定
"------------------------
set termencoding=utf-8
set encoding=utf-8
set fileencoding=utf-8

" □とか○の文字があってもカーソル位置がずれないようにする
"if exists('&ambiwidth')
"  set ambiwidth=double
"endif

"改行コード
set fileformats=unix,dos,mac

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

" 開いてるファイルにのディレクトリに移動
command! -nargs=0 CD :execute 'lcd ' . expand("%:p:h")

"------------------------
" キーバインド
"------------------------
"; to :
nnoremap ; :

"単語検索
nnoremap * g*
nnoremap # g#

"サーチハイライトトグル
nnoremap <silent> <Space>th :set hlsearch!<CR>

"タブ切り替え
nnoremap <C-l> gt
nnoremap <C-h> gT
nmap <C-t> :tabnew .<cr>

"タブ文字（\t）を入力
inoremap <C-Tab> <C-v><Tab>

"ビジュアルモードで選択して検索
vnoremap * "zy:let @/ = @z<CR>n

"ビジュアルモードで選択して置換。とりあえず/だけエスケープしとく
vnoremap <C-s> "zy:%s/<C-r>=escape(@z,'/')<CR>/

"入力モードで削除
inoremap <C-d> <Del>
inoremap <C-h> <BackSpace>

"コマンドモードでemacsチックに
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-h> <BackSpace>

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

"git
nnoremap <Space>g :<C-u>!git<Space>

"行末まで削除
inoremap <C-k> <C-o>D

"補完候補があってもEnterは改行
inoremap <expr> <CR> pumvisible() ? "\<C-e>\<CR>" : "\<CR>"

"スクロール
nnoremap <C-e> <C-e>j
nnoremap <C-y> <C-y>k
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" <C-u>とかのundo
inoremap <C-u>  <C-g>u<C-u>
inoremap <C-w>  <C-g>u<C-w>

" 行末までyank
nnoremap Y y$

" text object
nnoremap gc `[v`]
onoremap gc :normal gc<CR>

onoremap <silent> q
\      :for i in range(v:count1)
\ <Bar>   call search('.\&\(\k\<Bar>\_s\)\@!', 'W')
\ <Bar> endfor<CR>

" コピペ
nnoremap y "xy
vnoremap y "xy
nnoremap d "xd
vnoremap d "xd
nnoremap c "xc
vnoremap c "xc
vnoremap p "xp
nnoremap <C-p> :<C-u>set opfunc=OverridePaste<CR>g@
nnoremap <C-p><C-p> :<C-u>set opfunc=OverridePaste<CR>g@g@

function! OverridePaste(type, ...)
    if a:0
        silent execute "normal! `<" . a:type . "`>\"xp"
    elseif a:type == 'line'
        silent execute "normal! '[V']\"xp"
    elseif a:type == 'block'
        silent execute "normal! `[\<C-V>`]\"xp"
    else
        silent execute "normal! `[v`]\"xp"
    endif
endfunction

" インデント選択
function! VisualCurrentIndentBlock(type)
    let current_indent = indent('.')
    let current_line   = line('.')
    let current_col    = col('.')
    let last_line      = line('$')

    let start_line = current_line
    while start_line != 1 && current_indent <= indent(start_line) || getline(start_line) == ''
        let start_line -= 1
    endwhile
    if a:type ==# 'i'
        let start_line += 1
    endif

    let end_line = current_line
    while end_line != last_line && current_indent <= indent(end_line) || getline(end_line) == ''
        let end_line += 1
    endwhile
    if a:type ==# 'i'
        let end_line -= 1
    endif

    call cursor(start_line, current_col)
    normal! V
    call cursor(end_line, current_col)
endfunction

nnoremap vii :call VisualCurrentIndentBlock('i')<CR>
nnoremap vai :call VisualCurrentIndentBlock('a')<CR>
onoremap ii :normal vii<CR>
onoremap ai :normal vai<CR>

nnoremap gs :<C-u>setf<Space>

" onmi補完 Ctrl+Space
imap <Nul> <C-x><C-o>

map gf <C-w>gf
autocmd FileType perl set isfname-=-

"------------------------
" プラグインの設定
"------------------------

autocmd FileType perl nnoremap <Space>pr :Prove<CR>

" jslint
function! Jslint()
    let msg = system('/usr/local/bin/jsl -process ' . expand('%:p'))
    let m = matchlist(msg, '\(\d\+\) error(s), \(\d\+\) warning(s)')
    let error = m[1]
    let warn  = m[2]
    if (error == 0 && warn == 0)
        echo 'syntax ok'
    else
        let msgs = split(msg, '\n')
        let errors = []
        for line in msgs
            let m = matchlist(line, expand('%:p').'(\(\d\+\)): \(.*\)')
            if len(m) != 0
                call add(errors, printf('%s:%s: %s',
                \                        expand('%:p'), m[1], m[2]))
            endif
        endfor
        setlocal errorformat=%f:%l:%m
        cgetexpr join(errors, "\n")
        copen
    endif
endfunction
autocmd! FileType javascript nnoremap <Space>jl :<C-u>call Jslint()<CR>

"http://hail2u.net/blog/software/support-slash-started-relative-url-in-vim-gf.html
set includeexpr=substitute(v:fname,'^\\/','','')
autocmd FileType html :setlocal path+=;/

" align.vimのおぺれーた
vmap <Space>a <leader>tsp
vnoremap <Space>= :Align =><CR>

" ウインドウ単位で開いたファイルの履歴をたどる
" なんかvimgrepでバグる
function! FileJumpPush()
    if !exists('w:histories')
        let w:histories = []
    endif
    let buf = bufnr('%')
    if count(w:histories, buf) == 0
        call add(w:histories, buf)
    endif
endfunction

function! FileJumpPrev()
    if exists('w:histories')
        let buf = bufnr('%')
        let current = match(w:histories, '^'.buf.'$')
        if current != 0 && exists('w:histories[current - 1]')
            execute 'buffer ' . w:histories[current - 1]
        endif
    endif
endfunction

function! FileJumpNext()
    if exists('w:histories')
        let buf = bufnr('%')
        let current = match(w:histories, '^'.buf.'$')
        if exists('w:histories[current + 1]')
            execute 'buffer ' . w:histories[current + 1]
        endif
    endif
endfunction

augroup FileJumpAutoCmd
    autocmd!
augroup END


" see http://vim-users.jp/2009/11/hack96/
autocmd FileType *
\   if &l:omnifunc == ''
\ |   setlocal omnifunc=syntaxcomplete#Complete
\ | endif

" perl-completion.vim
"let g:def_perl_comp_bfunction = 1
"let g:def_perl_comp_packagen  = 1
"let g:acp_behaviorPerlOmniLength = 0

" smartchr.vim
"inoremap <expr> = smartchr#one_of(' = ', ' == ', ' === ', '=')
"inoremap <expr> => smartchr#one_of(' => ', '=>')

" rename
function! DoRename(file)
    execute "file " . a:file
    call delete(expand('#'))
    write!
endfunction
function! Rename(file, bang)
    if filereadable(a:file)
        if a:bang == '!'
            call DoRename(a:file)
        else
            echohl ErrorMsg
            echomsg 'File exists (add ! to override)'
            echohl None
        endif
    else
        call DoRename(a:file)
    endif
endfunction
command! -nargs=1 -bang -complete=file Rename call Rename(<q-args>, "<bang>")


"zen-coding
let g:user_zen_leader_key = '<C-f>'
let g:user_zen_settings = {
\  'indentation' : '    ',
\  'html': {
\     'close_empty_element': 0,
\     'snippets': {
\        'html:5': "<!DOCTYPE html>\n"
\                ."<html lang=\"${lang}\">\n"
\                ."<head>\n"
\                ."    <meta charset=\"${charset}\">\n"
\                ."    <title></title>\n"
\                ."</head>\n"
\                ."<body>\n\t${child}|\n</body>\n"
\                ."</html>"
\     }
\  }
\}

set virtualedit+=block

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
function! g:insert_path(path)
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


" ディレクトリが存在しなくてもディレクトリつくってファイル作成
function! s:newFileOpen(file)
    let dir = fnamemodify(a:file, ':h')
    if !isdirectory(dir)
        call mkdir(dir, 'p')
    endif
    execute 'edit ' . a:file
endfunction
command! -nargs=1 -complete=file New call s:newFileOpen(<q-args>)

" MarkdownをHTMLにする
function! s:markdown(line1, line2)
    let markdown_insalled = s:exec_perl('
    \   eval { require Text::Markdown };
    \   print $@ ? 0 : 1;
    \')

    if !markdown_insalled
        call s:error('Text::Markdown not installed')
        return
    endif

    let md_text = join(getline(a:line1, a:line2), "\n")
    let md_text = substitute(md_text, "'", "\\\\'", 'g')
    let perl_code = "
    \   use Text::Markdown qw/markdown/;
    \   my $html;
    \   eval { $html = markdown('" . md_text . "'); };
    \   print $@ ? '' : $html;
    \"

    try
        let html = s:exec_perl(perl_code)
        if html == ''
            throw 'parse error'
        endif
    catch /shell error/
        call s:error('perl code invalid')
        return
    catch /parse error/
        call s:error('parse error')
        return
    endtry

    let html = substitute(html, "\n</code></pre>", "</code></pre>", 'g')

    " replace
    "silent execute a:line1 . ',' . a:line2 . 'delete _'
    "call append(a:line1 - 1, split(html, "\n"))

    " scratch window
    execute 'new'
    setlocal bufhidden=unload
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal noswapfile
    nnoremap <buffer> <silent> q <C-w>c
    call append(0, split(html, "\n"))
    1
endfunction

function! s:exec_perl(perl_code)
    let ret = system('perl', a:perl_code)
    if v:shell_error
        throw 'shell error'
    endif

    return ret
endfunction

function! s:error(msg)
    echohl ErrorMsg
    echomsg a:msg
    echohl None
endfunction

" errormarker
let g:errormarker_errortext     = '!!'
let g:errormarker_warningstext  = '??'
let g:errormarker_errorgroup    = 'Error'
let g:errormarker_warning_group = 'Todo'
"let g:errormarker_erroricon = expand('~/.vim/signs/err.png')
"let g:errormarker_erroricon = expand('~/.vim/signs/warn.png')

"if !exists('g:flymake_enabled')
"    let g:flymake_enabled = 1
"    autocmd BufWritePost *.pl,*.pm,*.psgi,*.t silent make %
"endif


" vundle
set rtp+=~/.vim/vundle.git/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/unite.vim'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-quickrun'
Bundle 'mattn/perl-completion.vim'
Bundle 'tsaleh/vim-align'
Bundle 'vim-scripts/closetag.vim'
Bundle 'thinca/vim-quickrun'
Bundle 'vim-scripts/errormarker.vim'
Bundle 'ack.vim'
filetype plugin indent on     " required!


