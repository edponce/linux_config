syntax on

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

" Change color of specific groups
hi Comment ctermfg=darkcyan guifg='darkcyan'
hi Special ctermfg=magenta guifg='magenta'

" Enable modline, vim options at begin/end of files
set modeline
"set modelines=5

" Set width of TABs, still considered a \t
" vim will interpret TABs to have this width.
set tabstop=4

" Set width of indents
set shiftwidth=4

" Set number of columns for a TAB
set softtabstop=4

" Expand TABs to spaces
set expandtab

" Simpler symbol for commands 
nnoremap ; :

" Prevent stupid window from popping up
nnoremap q: :q

" Search and replace shortcut
nnoremap <silent> <F5> :%s//gc<Left><Left><Left>

" Toggle search highlight
set hlsearch
nnoremap <silent> <F6> :nohlsearch<CR>

" Enable spell checking
nnoremap <silent> <F8> :set spell! spelllang=en<CR>
nnoremap <silent> <S-F8> :set spell! spelllang=es<CR>

" Set aspell spell checker
nnoremap <silent> <F9> :w!<CR>:!aspell -l en_US -c %<CR>:e! %<CR>
nnoremap <silent> <S-F9> :w!<CR>:!aspell -l es -c %<CR>:e! %<CR>
  
" Toggle line numbers
nnoremap <silent> <F10> :set number!<CR>

" Move between buffers in normal mode
nnoremap <silent> <F12> :bn<CR>
nnoremap <silent> <S-F12> :bp<CR>

