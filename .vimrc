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
"highlight Comment ctermfg=darkcyan guifg=darkcyan
"highlight Special ctermfg=magenta guifg=magenta
highlight ExtraWhitespace ctermbg=red guibg=red
highlight ColorColumn ctermbg=233 guibg=grey7
highlight Visual ctermfg=white guifg=white

" Show trailing whitespace and spaces before a tab
match ExtraWhitespace /\s\+$\|^ \+\ze\t/

set showcmd			" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set autoread        " Automatically load changes
set mouse=a			" Enable mouse usage (all modes)
set ruler			" Show current line/column in status line
set modeline		" Enable scan for Vim options at end of buffers
set modelines=5		" Number of mode lines to scan
set tabstop=4		" Vim will interpret TABs to have this width.
set softtabstop=4	" Set number of columns for a TAB
set shiftwidth=4	" Set width of indents (<< and >>)
set expandtab		" Expand TABs to spaces
set hlsearch		" Enable highlighting during searches
let &colorcolumn="".join(range(80,999),",")  " Color column limit

" Simpler symbol for commands
nnoremap ; :

" Prevent stupid window from popping up
nnoremap q: :q

" Delete trailing whitespaces
nnoremap <silent> <F4> :%s/\(\t\\| \)\+$//g<CR>

" Clear terminal
nnoremap <silent> <S-F4> :!clear<CR><CR>

" Search highlighted word
nnoremap <silent> <F5> /<C-R><C-W><CR><S-n>

" Search and replace
nnoremap <silent> <S-F5> :%s//g<Left><Left>

" Remove search highlight
nnoremap <silent> <F6> :nohlsearch<CR>

" Toggle spell checking
nnoremap <silent> <F7> :set spell! spelllang=en<CR>
nnoremap <silent> <S-F7> :set spell! spelllang=es<CR>

" Set aspell spell checker
nnoremap <silent> <F8> :w!<CR>:!aspell -l en_US -c %<CR>:e! %<CR>
nnoremap <silent> <S-F8> :w!<CR>:!aspell -l es -c %<CR>:e! %<CR>

" Toggle hidden characters
" eol:U+23ce,tab:U+25b6-,space:U+00b7,extends:U+25b6,precedes:U+25c0,nbsp:U+23b5
set listchars=eol:⏎,tab:▶-,space:·,trail:~,extends:▶,precedes:◀,nbsp:⎵
nnoremap <silent> <F9> :set list!<CR>

" Toggle line numbers
nnoremap <silent> <F10> :set number!<CR>

" Move between buffers in normal mode
nnoremap <silent> <F11> :bp<CR>
nnoremap <silent> <F12> :bn<CR>

