syntax on
set number ruler
filetype plugin indent on
autocmd FileType yaml setlocal et ts=2 ai sw=2 nu sts=0
set cursorline
set number
syntax enable
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim
