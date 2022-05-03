set encoding=utf-8
scriptencoding utf-8

unlet! skip_default_vim
source $VIMRUNTIME/defaults.vim

set ambiwidth=double

"改行コード
set fileformats=unix,dos,mac

"------------------------
" 基本設定
"------------------------

"色設定
syntax on
colorscheme molokai
set t_Co=256
highlight Comment ctermfg=102
highlight Visual  ctermbg=236

"タブの設定
set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab
set autoindent

"検索
set ignorecase
set smartcase
set hlsearch

"コマンドラインの高さ
set cmdheight=1

"タブバー常に表示
set showtabline=2

"タブ文字可視化
set list
set listchars=tab:>\ 

set noswapfile
set nobackup
set autoread
set backupcopy=yes

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

nmap <silent> gd :LspDefinition<CR>
nmap <silent> <C-]> :LspDefinition<CR>
nmap <silent> <f2> :LspRename<CR>
nmap <silent> <Leader>d :LspTypeDefinition<CR>
nmap <silent> <Leader>r :LspReferences<CR>
nmap <silent> <Leader>i :LspImplementation<CR>
let g:lsp_diagnostics_enabled = 1
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_text_edit_enabled = 1
let g:asyncomplete_popup_delay = 200
let g:asyncomplete_remove_duplicates = 1
let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1

let g:lsp_settings = {
\  "css-languageserver": {
\    "workspace_config": {
\      "scss": {
\        "validate": v:false
\      }
\    }
\  },
\  "java-language-server": {
\    "cmd": $HOME . "/dev/src/github.com/draftcode/java-language-server/dist/lang_server_mac.sh"
\  },
\  "efm-langserver": {
\    "disabled": v:false
\  }
\}

set completeopt=menu,preview

"-----------------------
" autocmd
"------------------------
augroup MyAutoCmd
  au!
  " 全角・行末スペース
  highlight WhitespaceEOL ctermbg=red guibg=red
  au BufRead,BufNew,WinEnter * match WhitespaceEOL /\(　\|\s\+$\)/

  au BufNewFile,BufRead *.go set sw=4 noexpandtab ts=4
  au BufNewFile,BufRead *.java set sw=2 ts=2
  au BufNewFile,BufReadPost *.mt,*.tt,*.tx set filetype=html
  au BufNewFile,BufReadPost *.psgi,*.t,cpanfile,Daikufile set filetype=perl
  au BufNewFile,BufReadPost *.ru set filetype=ruby
  au BufNewFile,BufReadPost Dockerfile set filetype=Dockerfile
  au BufNewFile,BufReadPost Capfile* set filetype=ruby
  au BufNewFile,BufReadPost *.graphqls set filetype=graphql
  au BufNewFile,BufRead *.rb,*.ts,*.tsx set sw=2 expandtab ts=2
  au FileType perl set isfname-=- isfname-=/ isfname-=+
  au FileType html setlocal path+=;/
  au BufNewFile *.pm set ft=perl | call sonictemplate#apply('package', 'n')
  au BufWritePre *.ts,*.tsx,*.java,*.go call execute('LspDocumentFormatSync --server=efm-langserver')
  au BufNewFile *.pl 0r $HOME/.vim/template/perl-script.txt
  au BufNewFile *.t  0r $HOME/.vim/template/perl-test.txt
  au CmdwinEnter * call s:init_cmdwin()
  au QuickFixCmdPost make if len(getqflist()) != 0 | copen | endif
  au QuickFixCmdPost *grep* cwindow
  au User DirvishEnter let b:dirvish.showhidden = 1
  au FileType dirvish call FugitiveDetect(@%)
  au BufRead,BufNewFile nginx/*.conf set ft=nginx
augroup END

set virtualedit+=block

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
nmap <C-t> :<C-u>tabnew %:h<cr>

" 現在のタブを右へ移動
nnoremap <Tab>n :<C-u>MyTabMoveRight<CR>
" 現在のタブを左へ移動
nnoremap <Tab>p :<C-u>MyTabMoveLeft<CR>
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

if !exists("g:quickrun_config")
    let g:quickrun_config={}
endif

let g:quickrun_config['_'] = {
    \ 'outputter/buffer/split' : '%{winwidth(0) * 2 < winheight(0) * 5 ? "" : "vertical belowright"}',
\ }

if has('conceal')
  set conceallevel=1 concealcursor=
endif

" json
let g:vim_json_syntax_conceal = 0

" open-browser
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
let g:ctrlp_use_caching=0
let g:ctrlp_user_command='ag %s -i --nocolor --nogroup -g ""'

command! -nargs=1 CtrlPGrep call s:ctrlp_grep(<f-args>)

function! s:ctrlp_grep(pat)
  if a:pat != ""
    execute 'silent grep!' a:pat . ' ' . expand('%:p:h')
    if len(getqflist()) > 0
      CtrlPQuickfix
      cclose
    else
      echo 'no matches found'
    endif
    redraw!
  endif
endfunction

let g:ctrlp_map = '<Nop>'
noremap <silent> <C-p>     :<C-u>CtrlP<CR>
noremap <silent> <leader>g :<c-u>CtrlPGhq<cr>
noremap <silent> <leader>m :<c-u>CtrlPMixed<cr>
let g:ctrlp_ghq_default_action = 'e'
let g:ctrlp_ghq_cache_enabled = 1

let g:memolist_path = $HOME . "/Dropbox/memo"
let g:memolist_memo_suffix = "md"
let g:memolist_template_dir_path = $HOME . "/.vim/template/memolist"
let g:memolist_delimiter_yaml_start = "---"
let g:memolist_delimiter_yaml_end = "---"

nnoremap <silent><Space>f :<C-u>call tnite#start(["sh", "-c", "git ls-files \| peco"], "tabedit", {})<CR>

if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

let g:lightline = {
  \ 'component_function': {
  \   'filename': 'LightlineFilename',
  \ }
  \ }

function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/ctrlp-ghq'
Plug 'SirVer/ultisnips'
Plug 'thinca/vim-ref'
Plug 'tsaleh/vim-align'
Plug 'vim-scripts/closetag.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/taglist.vim'
Plug 'vim-jp/vimdoc-ja'
Plug 'airblade/vim-rooter'
Plug 'mattn/sonictemplate-vim'
Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }
Plug 'godlygeek/tabular'
Plug 'elzr/vim-json'
Plug 'tyru/open-browser.vim'
Plug 'nixprime/cpsm'
Plug 'justinmk/vim-dirvish'
Plug 'itchyny/lightline.vim'
Plug 'rhysd/ghpr-blame.vim'
Plug 'glidenote/memolist.vim'
Plug 'pocke/tnite.vim'
Plug 'b4b4r07/vim-hcl'
Plug 'chr4/nginx.vim'
Plug 'mattn/vim-asyncgrep'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'mustache/vim-mustache-handlebars'
Plug 'jparise/vim-graphql'
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'

call plug#end()

filetype plugin indent on
