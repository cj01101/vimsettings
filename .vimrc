set backspace=indent,start,eol

" autoindent same as last line
set autoindent
" expand tabs to spaces
set expandtab
" set tabs
set ts=4
" set autoindent
set sw=4

set nocompatible

"show cursor position at all times
set ruler

"set foldmethod=marker

"syntax highlighting
syntax enable

"move while searching
set incsearch

"highlight search term
set hlsearch

set background=dark


set number

" don't highlight matching paren
let loaded_matchparen = 1

"set colorscheme
colorscheme torte
highlight Folded term=standout ctermbg=6 ctermfg=0

"see trailing spaces and tabs
"set list listchars=tab:\|\ ,trail:_
"match ErrorMsg /\s\+$/

"switch between windows more easily
map <c-j> <c-w>j<c-w>_
map <c-k> <c-w>k<c-w>_
"map <c-h> <c-w>h<c-w>\|
"map <c-l> <c-w>l<c-w>\|
set wmh=0
set noequalalways " do not resize windows on split/close

" resize when new window under file
map <c-w>f <c-w>f<c-w>_

" my custom bookmarks
map :b<CR> :e ~/.vim/bookmarks<CR>

" open a perl module under cursor
setlocal isfname+=:

" Lineup on =
map <c-l> :Lineup =<CR>


" Tab completion.
function! InsertTabWrapper(direction)
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    elseif "backward" == a:direction
        return "\<c-p>"
    else
        return "\<c-n>"
    endif
endfunction

inoremap <S-Tab> <C-H><C-H><C-H><C-H>
"inoremap <s-tab> <c-r>=InsertTabWrapper ("forward")<cr>
inoremap <tab> <c-r>=InsertTabWrapper ("backward")<cr>

" only look at current file(s) for autocomplete
:set complete-=i

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Turn on/off with z/ (or key of your choice)
:map z/ :call Mosh_Auto_Highlight_Toggle()<CR>

:function! Mosh_Auto_Highlight_Cword()
    :exe "let @/='\\<".expand("<cword>")."\\>'"
:endfunction

function! Mosh_Auto_Highlight_Toggle()
    :if exists("#CursorHold#*")
    :  au! CursorHold *
    :  let @/=''
    :else
    :  set hlsearch
    :  set updatetime=500
    :  au! CursorHold * nested call Mosh_Auto_Highlight_Cword()
    :endif
endfunction

" move the current line up or down
nmap <c-p> :m+<CR>
nmap <c-o> :m-2<CR>
imap <c-p> <C-O>:m+<CR><C-O>
imap <c-o> <C-O>:m-2<CR><C-O>

" move the selected block up or down
vmap <c-p> :m'>+<CR>gv
vmap <c-o> :m'<-2<CR>gv

"don't keep a backup
set nobackup
set nowritebackup

set textwidth=80
set wrap

" perl compiler
nnoremap <silent> =c :w<Enter>:!perl -wc %<Enter>
" debugger
nnoremap <silent> =d :w<Enter>:!perl -d %<Enter>
" perl critic
nnoremap <silent> =p :w<Enter>:!perlcritic %<Enter>
" execute
au BufEnter * if match( getline(1) , '^\#!') == 0 |
\ execute("let b:interpreter = getline(1)[2:]") |
\endif
fun! CallInterpreter()
    if exists("b:interpreter")
         exec ("!".b:interpreter." %")
    endif
endfun
nnoremap <silent> =r :w<Enter>:call CallInterpreter()<CR>

" Executes a command (across a given range) and restores the search register
" when done.
" http://vim.wikia.com/wiki/Execute_commands_without_changing_the_search_register
function! SafeSearchCommand(line1, line2, theCommand)
  let search = @/
  execute a:line1 . "," . a:line2 . a:theCommand
  let @/ = search
endfunction
com! -range -nargs=+ SS call SafeSearchCommand(<line1>, <line2>, <q-args>)
" A nicer version of :s that doesn't clobber the search register
com! -range -nargs=* S call SafeSearchCommand(<line1>, <line2>, 's' . <q-args>)

" determine filetype for comments
function! GetFileType()
: let filename = tolower(bufname('%'))
: let pos = matchend(filename, '\.') - 1
: let len = strlen(filename) - pos
: let fileType = strpart(filename, pos, len)
: return fileType
:endfunction

let filetype = GetFileType()
if filetype == '.py'
    map - :S/^\(\ *\)\([^\ ]\)/\1#\2/<CR>
    map _ :S/^\(\ *\)#/\1/<CR>
elseif filetype == '.sql'
    map - :S/^/--/<CR>
    map _ :S/^--//<CR>
else
    " default to perl comments
    map - :S/^/#/<CR>
    map _ :S/^#//<CR>
endif

filetype plugin on

" stop auto-inserting comments
au FileType * setlocal comments=

" don't use replace mode
map R <Nop>
map r <Nop>

" search will center on the line it's found in.
map N Nzz
map n nzz

" less keystrokes
nnoremap ; :

" jump to line+column
nnoremap ' `
nnoremap ` '

" ctags dir
set tags=./tags,/u/tags

" { thing } => {thing}
function! Braces()
    let curr_line = getline( '.' )
    let replacement = substitute( curr_line, '{ ', '{', 'g' )
    let replacement = substitute( replacement, ' }', '}', 'g' )
    call setline( '.', replacement )
:endfunction
map \braces :call Braces()<CR>

" increment
map \a <C-a>

" save/load folds
"au BufWinLeave *? mkview
"au BufWinEnter *? silent loadview

" fix :W typo
command! W execute ":w"

" fix :Q typos
command! Q execute ":q"
command! Qa execute ":qa"

" set working dir to dir of current file
nnoremap ,cd :cd %:p:h<CR>

" curly should jump to lines with only spaces
function! ParagraphMove(delta, visual, count)
    normal m'
    normal |
    if a:visual
        normal gv
    endif

    if a:count == 0
        let limit = 1
    else
        let limit = a:count
    endif

    let i = 0
    while i < limit
        if a:delta > 0
            " first whitespace-only line following a non-whitespace character
            let pos1 = search("\\S", "W")
            let pos2 = search("^\\s*$", "W")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%$", "W")
            endif
        elseif a:delta < 0
            " first whitespace-only line preceding a non-whitespace character
            let pos1 = search("\\S", "bW")
            let pos2 = search("^\\s*$", "bW")
            if pos1 == 0 || pos2 == 0
                let pos = search("\\%^", "bW")
            endif
        endif
        let i += 1
    endwhile
    normal |
endfunction

nnoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
onoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
" vnoremap <silent> } :<C-U>call ParagraphMove( 1, 1)<CR>
nnoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
onoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
" vnoremap <silent> { :<C-U>call ParagraphMove(-1, 1)<CR>

" misc commands
command! Breakpoint execute "normal! O$DB::single=1;"
command! Cluck execute "normal! k:r ~/.vim/templates/Cluck\<CR>"
command! Date execute "normal! isprintf \"%4d-%02d-%02d\", "
command! DBIAll execute "normal! k:r ~/.vim/templates/DBIAll\<CR>"
command! DBIRow execute "normal! k:r ~/.vim/templates/DBIRow\<CR>"
command! Dumper execute "normal! k:r ~/.vim/templates/Dumper\<CR>2j$hh"
command! Parent execute "normal! :let _s=@/\<CR>/^use [base|parent]\<CR>WWl\<C-w>f:let @/=_s\<CR>\<C-w>_"
command! Printer execute "normal! k:r ~/.vim/templates/Printer\<CR>j$"
command! Sub execute "normal! k:r ~/.vim/templates/Sub\<CR>W"
command! Time execute "normal! k:r ~/.vim/templates/Time\<CR>"
command! Use execute "normal! :let _s=@/\<CR>mvlBy$G?^use\<CR>o\<Esc>P0iuse \<Esc>/[^A-Za-z: ]\<CR>C;\<Esc>:let @/=_s\<CR>"


" from http://stackoverflow.com/a/14651443/59867:
" Motion for "next object". For example, "din(" would go to the next "()" pair
" and delete its contents.
 
onoremap an :<c-u>call <SID>NextTextObject('a')<cr>
xnoremap an :<c-u>call <SID>NextTextObject('a')<cr>
onoremap in :<c-u>call <SID>NextTextObject('i')<cr>
xnoremap in :<c-u>call <SID>NextTextObject('i')<cr>
 
function! s:NextTextObject(motion)
  echo
  let c = nr2char(getchar())
  exe "normal! f".c."v".a:motion.c
endfunction

if filereadable("/home/chrisj/.vim.work")
    so /home/chrisj/.vim.work
endif
