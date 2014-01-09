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

"Rolodex mode
set winheight=999

"search/replace with registers
command! LineReplace execute 's//\=@s/g'
command! GlobalReplace execute '%s//\=@s/g'

set background=dark

" toggle number
set number
map \n :set nonumber!<CR>

" select all
map \a ggVG

" faster quit
map \q :q<CR>

" faster only
map \o :on<CR>

map \s :Sexplore<CR>
map \e :Explore<CR>
map \- :Explore<CR>-

" increment/decrement
"map \a <C-a>
"map \x <C-x>

" Tabularize
map \= :Tab /=<CR>
map \> :Tab /=><CR>

" search will center on the line it's found in.
map N Nzz
map n nzz

" * for no word boundaries, # for word boundaries
nnoremap # *
nnoremap * g*

" jump to line+column
nnoremap ' `
nnoremap ` '

" toggle paste
set pastetoggle=<leader>p

" breakpoint
function! ToggleBreakpoint()
    if getline(".") =~ 'DB::single=1'
        exe "normal! dd"
    else
        exe "normal! O$DB::single=1;"
    endif
endfunction
map \b :call ToggleBreakpoint()<CR>

function! DataPrinter()
    exe "normal! Ouse Data::Printer { max_depth => 0 };\nprint p ;"
endfunction
map \r :call DataPrinter()<CR>

" clear hlsearch too
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" vimux
function! MyVimuxCD(command)
    let path = expand('%:h')
    call VimuxRunCommand( "cd ".path."; ".a:command )
endfunction

function! MyVimuxRunFile(flag)
    let file = expand('%')
    call VimuxRunCommand( 'perl '.a:flag.' '.file )
endfunction

map =t :call VimuxRunCommand( "" )<left><left><left>
map =l :call VimuxRunLastCommand()<CR>
map =q :call VimuxCloseRunner()<CR>
map =p :call MyVimuxCD( '' )<CR>
map =f :call MyVimuxCD( 'fastprove' )<CR>
map =u :call MyVimuxRunFile('')<CR>
map =v :call MyVimuxRunFile('-d')<CR>


" don't highlight matching paren
let loaded_matchparen = 1

runtime macros/matchit.vim

"set colorscheme
colorscheme torte
highlight Folded term=standout ctermbg=6 ctermfg=0

"see trailing spaces and tabs
"set list listchars=tab:\|\ ,trail:_
"match ErrorMsg /\s\+$/

"switch between windows more easily
map <c-j> <c-w>j<c-w>_
map <c-k> <c-w>k<c-w>_
map <c-_> <c-w>_
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

" ack
":set grepprg=ack\ --nogroup\ --column\ $*
":set grepformat=%f:%l:%c:%m

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
"nmap <c-p> :m+<CR>
"nmap <c-o> :m-2<CR>
"imap <c-p> <C-O>:m+<CR><C-O>
"imap <c-o> <C-O>:m-2<CR><C-O>
"
"" move the selected block up or down
"vmap <c-p> :m'>+<CR>gv
"vmap <c-o> :m'<-2<CR>gv

"don't keep a backup
set nobackup
set nowritebackup

set textwidth=0
set wrap

" perl compiler
nnoremap <silent> =c :w<Enter>:!perl -wc %<Enter>
" debugger
nnoremap <silent> =d :w<Enter>:!perl -d %<Enter>
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


" save/load folds
"au BufWinLeave *? mkview
"au BufWinEnter *? silent loadview

" fix :W typos
command! W execute ":w"
command! Wq execute ":wq"

" fix :Q typos
command! Q execute ":q"
command! Qa execute ":qa"

" sudo save
command! Sudo execute ":w !sudo tee %"

" put path in unnamed register
command! Path let @" = expand("%:h")

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
command! Cluck execute "normal! k:r ~/.vim/templates/Cluck\<CR>"
command! Date execute "normal! isprintf \"%4d-%02d-%02d\", "
command! DateAdd execute "normal! k:r ~/.vim/templates/DateAdd\<CR>"
command! DBIAll execute "normal! k:r ~/.vim/templates/DBIAll\<CR>"
command! DBIRow execute "normal! k:r ~/.vim/templates/DBIRow\<CR>"
command! Dumper execute "normal! k:r ~/.vim/templates/Dumper\<CR>2j$hh"
"command! FastProve execute "normal! :!prove % -rs -j3 --state=save; prove -r --state=failed,save\<CR>"
"command! Failed execute "normal! :!prove % --state=failed --dry"
command! Newscratch execute "normal! :new\<CR>:setlocal buftype=nofile\<CR>"
command! Parent execute "normal! :let _s=@/\<CR>/^use [base|parent]\<CR>WWl\<C-w>f:let @/=_s\<CR>\<C-w>_"
command! Sub execute "normal! k:r ~/.vim/templates/Sub\<CR>W"
command! Time execute "normal! k:r ~/.vim/templates/Time\<CR>"
command! Use execute "normal! :let _s=@/\<CR>mvlBy$G?^use\<CR>o\<Esc>P0iuse \<Esc>/[^A-Za-z: ]\<CR>C;\<Esc>:let @/=_s\<CR>"

" workaround for: VCSCommit doesn't work on all open windows
command! DumpFileName execute "normal! :let @\" = expand(\"%\")\<CR>\<C-w>ko\<Esc>p"
command! StageFile execute "normal! :DumpFileName\<CR>\<C-w>j:quit\<CR>"
command! CommitFiles execute "normal! ggj\<S-v>}JIsvn commit \<Esc>0v$h\"vy:!\<C-r>v\<CR>"


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

" bash-style tab complete
set wildmode=longest,list

" :e %% expands to the path of the active buffer
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <expr> %_ getcmdtype() == ':' ? expand('%') : '%_'

if filereadable("/home/chrisj/.vim.work")
    so /home/chrisj/.vim.work
endif

