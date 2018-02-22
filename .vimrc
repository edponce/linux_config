" Vim TIPS
"
" * Visual mode
"    v - character-by-character visual mode
"    V - line-by-line visual mode
"    d,y,c - delete, yank, change commands
"
" * Visual block mode
"    CTRL+v - visual block mode, select block
"    SHIFT+i - write text to insert before every line
"    SHIFT+a - write text to append after every line
"    ESC - apply text
"
" * Make command
"    :make - run make command and captures output, a Makefile must exist
"    :cn - go to line causing next error
"    :cc - view current error message
"
" * Word completion
"    Begin typing a partial word
"    CTRL+p - previous match
"    CTRL+n - next match
"
" * Tag navigation
"    ctags *.c - generate 'tags' file
"    ctags -x *.c - print 'tags'
"    vi -t <tag> - open file and position cursor at tag
"    :ta <tag> - open file and position cursor at tag
"    CTRL-] - go to tag under cursor
"    CTRL-T - return to previous tag

" Vundle and Plugins
set nocompatible  " be iMproved, required
filetype off      " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Code-completion engine for C/C++/Python and others
" https://valloric.github.io/YouCompleteMe/#diagnostic-display
Plugin 'Valloric/YouCompleteMe'

" Markdown preview support
" https://github.com/JamshedVesuna/vim-markdown-preview
Plugin 'JamshedVesuna/vim-markdown-preview'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.

" All of your Plugins must be added before the following line
call vundle#end()          " required
"filetype plugin indent on  " required
" To ignore plugin indent changes, instead use:
filetype plugin on

" YouCompleteMe configuration
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_error_symbol = 'E>'
let g:ycm_warning_symbol = 'W>'
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_max_diagnostics_to_display = 30
let g:ycm_filetype_blacklist = {
    \ 'notes' : 1,
    \ 'markdown' : 1,
    \ 'text' : 1,
    \ 'pandoc' : 1,
    \ 'mail' : 1
    \}
"highlight YcmErrorSign guibg=#3f0000
"highlight YcmWarningSign guibg=#3f0000
"highlight YcmErrorLine guibg=#3f0000
"highlight YcmWarningLine guibg=#3f0000
"highlight SyntasticErrorSign guibg=#3f0000
"highlight SyntasticWarningSign guibg=#3f0000
"highlight SyntasticErrorLine guibg=white
"highlight SyntasticWarningLine guibg=white

" Markdown-preview configuration
let g:vim_markdown_preview_toggle=1  " 0 = display on hotkey map, uses /tmp directory
                                     " 1 = display on hotkey map, uses current directory
                                     " 2 = display on buffer write, uses current directory
                                     " 3 = display on buffer write, uses /tmp directory
let g:vim_markdown_preview_hotkey='<C-p>'  " hotkey for generating html preview
let g:vim_markdown_preview_temp_file=0  " 0 = keep html file
                                        " 1 = remove html file
let g:vim_markdown_preview_github=1  " requires Python grip
let g:vim_markdown_preview_perl=0  " requires John Gruber's Markdown.pl
let g:vim_markdown_preview_pandoc=0  " requires John MacFarlane's Pandoc
let g:vim_markdown_preview_browser='Mozilla Firefox'  " for other than Google Chrome,
" need to run 'sudo update-alternatives --config x-www-browser' ('gnome-www-browser')
let g:vim_markdown_preview_use_xdg_open=1  " (enable/disable) use xdg-open to view html

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" See :h vundle for more details or wiki for FAQ

" Set color scheme from /usr/share/vim/vim74/colors, ~/.vim/colors
"colorscheme blue
"colorscheme darkblue
"colorscheme default
"colorscheme delek
"colorscheme desert
colorscheme elflord
"colorscheme evening
"colorscheme industry
"colorscheme koehler
"colorscheme morning
"colorscheme murphy
"colorscheme pablo
"colorscheme peachpuff
"colorscheme ron
"colorscheme shine
"colorscheme slate
"colorscheme torte
"colorscheme zellner
"colorscheme dracula

" Enable syntax highlighting
syntax on

" Get last cursor position
function! LastCursorPos()
    if (line("'\"") > 1) && (line("'\"") <= line("$"))
        exe "normal! g'\""
    endif
endfunction

" Jump to the last position when reopening a file
autocmd BufReadPost * call LastCursorPos()

" Change color of specific groups
highlight Comment ctermfg=darkcyan guifg=darkcyan
highlight Special ctermfg=magenta guifg=magenta
highlight ExtraWhitespace ctermbg=red guibg=red
highlight ColorColumn ctermbg=233 guibg=grey7
highlight Visual ctermfg=white guifg=white

" Show trailing whitespace and spaces before a tab
match ExtraWhitespace /\s\+$\|^ \+\ze\t/

set showcmd			" show (partial) command in status line
set showmatch		" show matching brackets
set ignorecase		" do case insensitive matching
set smartcase		" do smart case matching
set incsearch		" incremental search
set autowrite		" automatically save before commands like :next and :make
set autoread        " automatically load changes
set mouse=a			" enable mouse usage (all modes)
set ruler			" show current line/column in status line
set modeline		" enable scan for Vim options at end of buffers
set modelines=5		" number of mode lines to scan
set tabstop=4		" Vim will interpret TABs to have this width
set softtabstop=4	" set number of columns for a TAB
set shiftwidth=4	" set width of indents (<< and >>)
set expandtab		" expand TABs to spaces
set hlsearch		" enable highlighting during searches
"let &colorcolumn="".join(range(80,999),",")  " color column limit
let &colorcolumn="80"  " color column limit

" Simpler symbol for commands
nnoremap ; :

" Prevent stupid window from popping up
nnoremap q: :q

" Delete trailing whitespaces
nnoremap <silent> <F4> :%s/\(\t\\| \)\+$//g<CR>

" Search highlighted word
nnoremap <silent> <F5> /<C-R><C-W><CR><S-n>

" Search and replace
nnoremap <silent> <S-F5> :%s//gn<Left><Left>

" Remove search highlight
nnoremap <silent> <F6> :nohlsearch<CR>

" Remove overlaid terminal messages
nnoremap <silent> <S-F6> :!<CR><CR>

" Toggle spell checking
nnoremap <silent> <F7> :set spell! spelllang=en<CR>
nnoremap <silent> <S-F7> :set spell! spelllang=es<CR>

" Set aspell spell checker
nnoremap <silent> <F8> :w!<CR>:!aspell -l en_US -c %<CR>:e! %<CR>
nnoremap <silent> <S-F8> :w!<CR>:!aspell -l es -c %<CR>:e! %<CR>

" Count number of printed lines, words, characters
nnoremap <silent> <F9> :!wc %<CR>
nnoremap <silent> <S-F9> :!detex % \| wc<CR>

" Toggle line numbers
nnoremap <silent> <F10> :set number!<CR>

" Toggle hidden characters
" eol:U+23ce,tab:U+25b6-,space:U+00b7,extends:U+25b6,precedes:U+25c0,nbsp:U+23b5
set listchars=eol:⏎,tab:▶-,space:·,trail:~,extends:▶,precedes:◀,nbsp:⎵
nnoremap <silent> <S-F10> :set list!<CR>

" Move between buffers in normal mode
nnoremap <silent> <F11> :bp<CR>
nnoremap <silent> <F12> :bn<CR>

