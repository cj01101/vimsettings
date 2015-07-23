" vim-bookmarks mappings
nmap gm <Plug>BookmarkToggle
nmap ga <Plug>BookmarkAnnotate
nmap gs <Plug>BookmarkShowAll
nmap gn <Plug>BookmarkNext
nmap gp <Plug>BookmarkPrev
nmap gc <Plug>BookmarkClear
nmap gz <Plug>BookmarkClearAll

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

" always show at least one line above/below the cursor
if !&scrolloff
  set scrolloff=1
endif
if !&sidescrolloff
  set sidescrolloff=5
endif

"search/replace with registers
command! LineReplace execute 's//\=@s/g'
command! GlobalReplace execute '%s//\=@s/g'

set background=dark

nnoremap K <nop>

" toggle number
set number

" :e %% expands to the path of the active buffer
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'
cnoremap <expr> %_ getcmdtype() == ':' ? expand('%') : '%_'

" leader mappings
let mapleader = "\<Space>"

" select all
map <leader>a ggVG

" faster quit, etc
map <leader>q :q<CR>
map <leader>w :w<CR>

" faster only
map <leader>o :on<CR>

"map <leader>s :Sexplore<CR> # windows
map <leader>s :tabedit %%<CR>
map <leader>e :Explore<CR>

" paste into last place
map <leader>p gi<c-r>"<esc>

" Tabularize
map <leader>= :Tab /=<CR>
map <leader>> :Tab /=><CR>

" tabs
map <c-t> :tabnew<cr>:setlocal buftype=nofile<cr>
"map <leader>to :tabonly<cr>
"map <leader>tc :tabclose<cr>

" change from a scratch buffer so I can save:
map <leader>b :set buftype=<CR>

" add new lines (for Outlook webmail) and copy to windows clipboard
map <leader>c :g/^$/norm O<cr>ggVG"+y

" mysql output => csv
map <leader>m :%s/\v[\| ][\| ]+/","/g<bar>%s/^",//<bar>%s/,"$//g<cr>

" jump to schema tag
function! JumpToSchemaTag(word)
    exe "/name=\"".a:word."\""
endfunction
map <leader>x :call JumpToSchemaTag( "<c-r><c-w>" )<cr>

function! ToggleTodo()
    if getline('.') =~ '# TODO'
        exe "s/ *# TODO.*//"
    else
        exe "norm!A # TODO"
    endif
endfunction
map \T :call ToggleTodo()<cr>
inoremap \T <esc>h:call ToggleTodo()<cr>

function! ExpandDateQuery()
    exe "normal! a'\<Esc>Bi'\<Esc>itimestamp between \<Esc>l\"xyEEa and \<c-r>x\<Esc>h\<c-a>l"
endfunction
map \D :call ExpandDateQuery()<cr>
inoremap \D <esc>:call ExpandDateQuery()<cr>

" toggle paste
set pastetoggle=\\p

" breakpoint
"map <leader>b :norm! O$DB::single=1; # TODO<cr>

function! DataPrinter()
    exe "normal! Ouse Data::Printer { max_depth => 0 };\nprint p ;"
endfunction
map <leader>r :call DataPrinter()<CR>i

" center screen when jumping to a tag
map <c-]> <c-]>zz
map <c-w>] <c-w>]zz

" * for no word boundaries, # for word boundaries
nnoremap # *
nnoremap * g*

" jump to line+column
nnoremap ' `
nnoremap ` '

" repeatable "n."
nnoremap Q :normal n.<CR>

" svn shortcuts
nnoremap Ua :VCSAdd<cr>
nnoremap Ub :VCSBlame<cr>
nnoremap Uc :VCSCommit<cr>iissue #
nnoremap Ud :VCSDiff<cr>
nnoremap Ul :VCSLog<cr>
nnoremap Ur :!svn resolved %<cr>
nnoremap Us :VCSStatus<cr>
nnoremap Uu :VCSUpdate<cr>
nnoremap Uv :VCSRevert<cr>

" select last inserted text
nnoremap gV `[v`]

" mappings for quote surround updates
map g' cs"'
map g" cs'"
map g} cs{}
map g{ cs}{

" jump to end of next/previous date
map gd :call search('\v\d{4}-\d{2}-\d{2}')<cr>9l:noh<cr>
map gD B:call search('\v\d{4}-\d{2}-\d{2}', 'b')<cr>9l:noh<cr>

" break function params
map gF :s/ );$/, );<cr>$F)%ls<cr><tab><esc>:s/,/,\r/g<cr><s-v>%jj='><<:noh<cr>

" if line to block - cursor on the i in 'if'
map gb ^Wdw$hC;<esc>2jdd2kP<<Jhxjdj
map gB hs<cr><esc>ddkPWv$F;hS($xo{<esc>j>>A;<cr><s-tab>}<esc>

" undo/redo all
map gU 99999u
map gR 99999<c-r>

" persistent undo
"if exists("&undodir")
"    set undofile
"    let &undodir=&directory
"    set undolevels=500
"    set undoreload=500
"endif

" clear hlsearch too
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" determine filetype
function! GetFileType()
  let filename = tolower(bufname('%'))
  let pos = matchend(filename, '\.') - 1
  let len = strlen(filename) - pos
  let fileType = strpart(filename, pos, len)
  return fileType
endfunction

" vimux
function! MyVimuxCD(command)
    let path = expand('%:p')
    call VimuxRunCommand( "cd ".path."; ".a:command )
endfunction

function! MyVimuxRunFile()
    let filetype = GetFileType()
    let file = expand('%')
    if filetype == '.t'
        call VimuxRunCommand( 'prove --verbose --comments --recurse -Pretty '.file )
    else
        call VimuxRunCommand( '!'.file )
    endif
endfunction

function! MyVimuxPerlDebug()
    let filetype = GetFileType()
    let file = expand('%')
    call VimuxRunCommand( 'perl -d '.file )
endfunction

map =t :call VimuxRunCommand( "" )<left><left><left>
map =q :call VimuxCloseRunner()<CR>
map =p :call MyVimuxCD( '' )<CR>
map =f :call MyVimuxCD( 'fastprove' )<CR>
map =u :call MyVimuxRunFile()<CR>
map =v :call MyVimuxPerlDebug()<CR>


" don't highlight matching paren
let loaded_matchparen = 1

runtime macros/matchit.vim

"set colorscheme
"colorscheme torte
"highlight Folded term=standout ctermbg=6 ctermfg=0
colorscheme solarized

"see trailing spaces and tabs
"set list listchars=tab:\|\ ,trail:_
"match ErrorMsg /\s\+$/

"switch between windows more easily

"func! WinMove(key)
"    let t:curwin = winnr()
"    exec "wincmd ".a:key
"    if (t:curwin == winnr())
"        wincmd n
"        if (a:key == 'j')
"            wincmd x
"        endif
"        exec "wincmd ".a:key
"        exec ":setlocal buftype=nofile"
"    endif
"endfu
"
"nnoremap <silent> <C-j> :call WinMove('j')<cr>
"nnoremap <silent> <C-k> :call WinMove('k')<cr>
"
"set wmh=0
"map <c-_> <c-w>_
"inoremap <c-_> <esc><c-w>_a

nnoremap <silent> <c-n> :tabnext<cr>
nnoremap <silent> <c-p> :tabprevious<cr>

nnoremap <silent> <c-j> <c-w>j<c-_>
nnoremap <silent> <c-k> <c-w>k<c-_>

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

"don't keep a backup
set nobackup
set nowritebackup

" don't wrap in buffer
set textwidth=99999
set wrap
autocmd BufNewFile,BufRead * setlocal formatoptions=rq

" shell command
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
"  call setline(1, 'You entered:    ' . a:cmdline)
"  call setline(2, 'Expanded Form:  ' .expanded_cmdline)
"  call setline(3,substitute(getline(2),'.','=','g'))
  execute '$read !'. expanded_cmdline
  setlocal modifiable
  1
endfunction

" perl compiler
nnoremap <silent> =c :w<Enter>:!perl -wc %<Enter>
" more warnings:
nnoremap <silent> =w :w<Enter>:!perl -Wc %<Enter>
" debugger
nnoremap <silent> =d :w<Enter>:!perl -d %<Enter>

" execute
function! MyRunFile()
    let filetype = GetFileType()
    if filetype == '.t'
        " use Test::Pretty
        " execute "!prove --verbose --comments --recurse -Pretty " . expand('%')
        let cmd_to_run = "!prove --verbose --comments --recurse " . expand('%')
    else
        let cmd_to_run = "!" . expand('%')
    endif
    " put command in x register
    let @x = cmd_to_run
    execute cmd_to_run
endfunction
nnoremap <silent> =r :w<Enter>:call MyRunFile()<CR>
nnoremap <silent> =l :w<Enter>:<c-r>x<CR>


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
set tags=./tags

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

function! Sum(number)
    let g:S = g:S + a:number
    return a:number
endfunction

function! DoSum()
    let g:S = 0  "result in global variable S
    exe "normal! :%s/\\d\\+/\\=Sum(submatch(0))/\<CR>"
endfunction

function! PrintSum()
    let @x = g:S
    exe "normal! '>o\<c-r>x\<Esc>"
endfunction

nnoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
onoremap <silent> } :<C-U>call ParagraphMove( 1, 0, v:count)<CR>
" vnoremap <silent> } :<C-U>call ParagraphMove( 1, 1)<CR>
nnoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
onoremap <silent> { :<C-U>call ParagraphMove(-1, 0, v:count)<CR>
" vnoremap <silent> { :<C-U>call ParagraphMove(-1, 1)<CR>

" misc commands
command! Cluck execute "normal! k:r ~/.vim/templates/Cluck\<CR>"
command! Date execute "normal! isprintf( \"%4d-%02d-%02d\", )"
command! DateAdd execute "normal! k:r ~/.vim/templates/DateAdd\<CR>"
command! DBIAll execute "normal! k:r ~/.vim/templates/DBIAll\<CR>"
command! DBIRow execute "normal! k:r ~/.vim/templates/DBIRow\<CR>"
command! Dumper execute "normal! k:r ~/.vim/templates/Dumper\<CR>2j$hh"
command! NumberLines execute "normal! :%s/^/\\=line('.').' '/\<CR>:nohlsearch\<CR>"
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

if filereadable("/home/chrisj/.vim.work")
    so /home/chrisj/.vim.work
endif
if filereadable("_vim_work")
    so _vim_work
endif



