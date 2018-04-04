" -------------------------------------------------------------------------------------------------
" GENERAL SETTINGS
" -------------------------------------------------------------------------------------------------
filetype plugin indent on       " attempt to determine file type
syntax on                       " enable syntax highlighting
set synmaxcol=250               " only syntax highlight the first 250 columns
set wildmenu                    " visual auto complete for command menu
set report=0                    " always report changed lines
set lazyredraw                  " improves performance by not redrawing the screen during macros,...
set ttyfast                     " always assume a fast terminal
set autoread                    " reload file when changed outside vim
set splitbelow                  " open new horizontal split below the current one
set splitright                  " open new vertical split right of the current one
set visualbell                  " use visual bell instead of beeping
set backspace=indent,eol,start  " allow backspacing over auto indent, line breaks and insert action
set hidden                      " buffer becomes hidden when it is abandoned
set cmdheight=2                 " increase the height of the command bar
set nowrap                      " don't wrap
set laststatus=2                " always show the status line
set completeopt=longest,menuone " better insert mode auto completion
set mouse=a                     " enable mouse support
set autowriteall                " auto save files
set scrolloff=1                 " always keep a line from the top and the bottom to the cursor
set number                      " enable line numbers
set showmode                    " show mode in command line
set ruler                       " show line number info in status line

" read man pages inside vim (in a vertical split) via :Man <cmd>
runtime! ftplugin/man.vim
let g:ft_man_open_mode = 'vert'

" tabs and indentation
set tabstop=4     " number of visual spaces per tab
set softtabstop=4 " number of spaces per tab when editing
set expandtab     " tabs are spaces
set shiftround    " round to multiple of shift width when adjusting indentation
set shiftwidth=4  " number of spaces for each step of auto indent
set autoindent    " auto indent on a new line

" key timeouts, quickly time out on key codes, but never time out on mappings
set notimeout
set ttimeout
set ttimeoutlen=200

" non printable characters
set list                                                  " show non-printable characters
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+ " customize shown characters

" search
set incsearch  " search as characters are entered
set hlsearch   " highlight matches
set ignorecase " ignore case when searching lowercase
set smartcase  " don't ignore case when inserting uppercase characters

" backups
set nobackup   " disable backups
set noswapfile " disable swap files

" cscope
set cscopequickfix=s-,c- " enable cscope quickfix
set cscopetag            " use cscope by default for tag jumps

" wildignore
set wildignore+=*cscope*
set wildignore+=tags

" spelling (not enabled by default but can be toggled with key mapping)
set spelllang=en_us
set spellfile=~/.vim/en.utf-8.add

" use ripgrep for faster grepping if it is available
if executable("rg")
    set grepprg=rg\ --vimgrep\ -S
    set grepformat^=%f:%l:%c:%m
endif

" -------------------------------------------------------------------------------------------------
" FUNCTIONS
" -------------------------------------------------------------------------------------------------
" Toggle colorcolumn
function! ToggleColorColumn() abort
    if &colorcolumn > 0
        set colorcolumn=0
    else
        set colorcolumn=101
    endif
endfunction

" Toggle background setting to hint vim wich background color the terminal is using
function! ToggleBackground() abort
    if &background == "dark"
        set background=light
    else
        set background=dark
    endif
endfunction

" add extra syntax highlighting for c functions
function! EnhanceCSyntax() abort
    syntax match cFunction /\<\w\+\s*(/me=e-1,he=e-1
    syntax match cMacro /\<[A-Z_]\+\s*(/me=e-1,he=e-1
    highlight def link cFunction Function
    highlight def link cMacro Macro
endfunction

" load cscope database
function! LoadCscope() abort
    let db = findfile("cscope.out", ".;")
    if (!empty(db))
        let path = strpart(db, 0, match(db, "/cscope.out$"))
        set nocscopeverbose
        exe "cs add " . db . " " . path
        set cscopeverbose
    endif
endfunction

" -------------------------------------------------------------------------------------------------
" AUTO COMMANDS
" -------------------------------------------------------------------------------------------------
" enhance c syntax highlighting
augroup c_syntax_enhancements
    autocmd!
    autocmd Syntax c,cpp call EnhanceCSyntax()
augroup end

" auto load cscope database
augroup load_cscope
    autocmd!
    autocmd BufEnter /* call LoadCscope()
augroup end

" automatically cleanup fugitive buffers
augroup fugitive
    autocmd!
    autocmd BufReadPost fugitive://* set bufhidden=delete
augroup end

" source vimrc on save
augroup vimrc
    autocmd!
    autocmd BufWritePost .vimrc source $MYVIMRC
augroup end

" automatically save when a file is changed
augroup save_and_read
    autocmd!
    autocmd TextChanged, InsertLeave, FocusLost * silent! wall
    autocmd CursorHold * silent! checktime
augroup end

" markdown settings for writing prose
augroup markdown
    autocmd!
    autocmd Filetype markdown,gitcommit setlocal spell
    autocmd Filetype markdown setlocal textwidth=100
augroup end

" open quickfix and gitcommit window always at the bottom and with the full width
augroup windows
    autocmd FileType qf,gitcommit wincmd J
augroup END

" open quickfix when it is populated
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost    l* lwindow
    autocmd VimEnter            * cwindow
augroup END

" -------------------------------------------------------------------------------------------------
" ABBREVIATIONS
" -------------------------------------------------------------------------------------------------
" open help in a vertical split
cabbrev H vert h

" insert todo
iabbrev TODO /* TODO dboucken: */<left><left><left>

" -------------------------------------------------------------------------------------------------
" CUSTOM KEY MAPPINGS
" -------------------------------------------------------------------------------------------------
" map jj to escape
inoremap jj <Esc>

" map ; to :
nnoremap ; :

" always use very magic regular expressions when searching
nnoremap / /\v

" auto expand curly brackets
inoremap {<cr> {<cr>}<Esc>O

" -------------------------------------------------------------------------------------------------
" LEADER KEY MAPPINGS
" -------------------------------------------------------------------------------------------------
" use space as leader
let mapleader=" "

" clear search highlighting
nnoremap <leader>l :nohlsearch<cr>

" quickly open vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>

" delete trailing white space on a line
nnoremap <leader>dd :s/\s\+$//e<cr>

" remap <C-w>
nnoremap <leader>w <C-w>

" make
nnoremap <leader>m :make<cr>

" toggle quickfix window
nnoremap <silent> <leader>qo :copen<cr>
nnoremap <silent> <leader>qc :cclose<cr>

" search files in the working directory
nnoremap <leader>oo :e **/

" regex tags search
nnoremap <leader>tt :tj /

" recursive grep, don't return to be able to pass options and directory
nnoremap <leader>gr :grep 

" grep the word under the cursor, don't return to be able to pass options and directory
nnoremap <leader>gw :grep -w <c-r><c-w> 

" find cscope symbol under the cursor
nnoremap <leader>gs :cs find s <c-r><c-w><cr><cr>

" find callers of function under the cursor
nnoremap <leader>gc :cs find c <c-r><c-w><cr><cr>

" remap tag jump <C-]>
nnoremap <leader>] <C-]>

" easier change and replace word
nnoremap <leader>cw *Ncgn

" paste last yanked text
nnoremap <leader>pp "0p
vnoremap <leader>pp "0p

" replace word with last yanked text
nnoremap <leader>pr viw"0p

" run macro in register q
nnoremap <leader><leader> @q

" toggle spell checking
nnoremap <leader>sp :setlocal spell! spelllang=en_us<cr>

" toggle background
nnoremap <leader>tb :call ToggleBackground()<cr>

" toggle colorcolumn
nnoremap <leader>tc :call ToggleColorColumn()<cr>

" -------------------------------------------------------------------------------------------------
" LOCAL VIMRC
" -------------------------------------------------------------------------------------------------
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" -------------------------------------------------------------------------------------------------
" PLUGINS
" -------------------------------------------------------------------------------------------------
" install vim-plug if it is not installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd vimEnter * PlugInstall --sync | source $MYVIMRC
endif

" plugins should be added after this line
call plug#begin()

Plug 'tpope/vim-fugitive'                            " git wrapper
Plug 'tpope/vim-surround'                            " all about surroundings
Plug 'tpope/vim-commentary'                          " commenting
Plug 'tpope/vim-unimpaired'                          " some useful key mappings
Plug 'airblade/vim-gitgutter'                        " show git diff in gutter
Plug 'nathanalderson/yang.vim',  { 'for': 'yang' }   " yang syntax highlighting

" plugins should be added before this line
call plug#end()
