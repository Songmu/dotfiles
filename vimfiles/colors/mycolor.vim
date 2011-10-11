" mymacvim colorscheme
"

highlight clear

" Reset String -> Constant links etc if they were reset
if exists("syntax_on")
  syntax reset
endif

let colors_name = "mycolor"


"
" First list all groups common to both 'light' and 'dark' background.
"

" `:he highlight-groups`
hi DiffAdd      guibg=MediumSeaGreen
hi Directory    guifg=SkyBlue ctermfg=cyan
hi ErrorMsg     guibg=Firebrick2 guifg=White
hi FoldColumn   guibg=Grey guifg=DarkBlue
hi Folded       guibg=#333333 guifg=NONE
hi IncSearch    gui=reverse
hi ModeMsg      gui=bold
hi MoreMsg      gui=bold guifg=SeaGreen4
hi NonText      gui=bold guifg=Blue
hi Pmenu        guifg=black guibg=#CCCCCC ctermbg=white ctermfg=black
hi PmenuSbar    guibg=Grey ctermfg=black
hi PmenuSel     guifg=White guibg=SkyBlue4 ctermbg=magenta ctermfg=white
hi PmenuThumb   gui=reverse
hi Question     gui=bold guifg=Chartreuse4
hi SignColumn   guibg=Grey guifg=DarkBlue
hi SpecialKey   guifg=DarkBlue ctermfg=darkcyan
hi SpellBad     guisp=Firebrick2 gui=undercurl
hi SpellCap     guisp=Blue gui=undercurl
hi SpellLocal   guisp=DarkCyan gui=undercurl
hi SpellRare    guisp=Magenta gui=undercurl
hi StatusLine   gui=NONE guifg=White guibg=DarkSlateGray ctermfg=blue ctermbg=gray term=none cterm=none
hi StatusLineNC gui=NONE guifg=black guibg=Gray90 ctermfg=black ctermbg=gray term=none cterm=none
hi TabLine      gui=underline guibg=LightGrey
hi TabLineFill  gui=reverse
hi TabLineSel   gui=bold ctermfg=white
hi Title        gui=bold guifg=#a1338b ctermfg=magenta cterm=bold
hi VertSplit    gui=NONE guifg=DarkSlateGray guibg=Gray90
hi visual       guibg=#102253 ctermfg=white ctermbg=blue cterm=none
hi warningmsg   guifg=firebrick2 ctermfg=red

" syntax items (`:he group-name` -- more groups are available, these are just
" the top level syntax items for now).
hi error        gui=none guifg=white guibg=NONE ctermbg=none
hi identifier   gui=none guifg=Cyan4 guibg=NONE ctermfg=cyan
hi Ignore       gui=NONE guifg=bg guibg=NONE
hi PreProc      gui=NONE guifg=DodgerBlue3 guibg=NONE
hi Special      gui=NONE guifg=Grey80 guibg=NONE ctermfg=brown
hi String       gui=NONE guifg=#89A2A6 guibg=NONE ctermfg=magenta cterm=none
hi Underlined   gui=underline guifg=SteelBlue1

hi Boolean      gui=NONE guifg=skyBlue3 guibg=NONE
hi Comment      gui=NONE guifg=#8F3E3E ctermfg=darkred
hi Constant     gui=NONE guifg=Grey80 guibg=NONE ctermfg=magenta cterm=none
hi Cursor       guibg=#999999 guifg=bg
hi CursorColumn guibg=Gray20
hi CursorIM     guibg=LightSlateGrey guifg=bg
hi CursorLine   guibg=#222222
hi DiffChange   guibg=MediumPurple4
hi DiffDelete   gui=bold guifg=White guibg=SlateBlue
hi DiffText     gui=NONE guifg=White guibg=SteelBlue
hi LineNr       guifg=DarkYellow guibg=Grey5 ctermfg=green cterm=none
hi matchParen   guifg=White guibg=Magenta
hi Normal       guifg=Grey80 guibg=Grey8
hi Search       guibg=#c5ba24 guifg=black
hi Statement    gui=bold guifg=#9F632E guibg=NONE
hi Todo         gui=NONE guifg=Red guibg=NONE
hi Type         gui=bold guifg=#577FF2 guibg=NONE
hi WildMenu     guibg=SkyBlue guifg=White ctermfg=yellow ctermbg=black cterm=none term=none
hi lCursor      guibg=LightSlateGrey guifg=bg
"hi Keyword      guifg=white guibg=#CC0000

"
" Change the selection color on focus change (but only if the "macvim"
" colorscheme is active).
"
if has("gui_macvim") && !exists("s:augroups_defined")
  au FocusLost * if exists("colors_name") && colors_name == "macvim" | hi Visual guibg=MacSecondarySelectedControlColor | endif
  au FocusGained * if exists("colors_name") && colors_name == "macvim" | hi Visual guibg=MacSelectedTextBackgroundColor | endif

  let s:augroups_defined = 1
endif

" vim: sw=2
