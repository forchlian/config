" nvim from vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" cscope
if has("cscope")
	set csto=0
	set cst
	if filereadable("cscope.out")
		silent cs add cscope.out
	elseif $CSCOPE_DB != ""
		silent cs add $CSCOPE_DB
	endif
endif

if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.config/nvim/plugged')

" indent-blankline
Plug 'lukas-reineke/indent-blankline.nvim'

" coc
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" nvim-tree
Plug 'kyazdani42/nvim-web-devicons' " for file icons 
Plug 'kyazdani42/nvim-tree.lua'

" tagbar
Plug 'preservim/tagbar'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" bufferline
Plug 'akinsho/bufferline.nvim'

" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

" ===
" === indent-blankline
" ===
lua << EOF
require("indent_blankline").setup{
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line = true,
  space_char_blankline = " ",
}
EOF

" ===
" === coc.nvim
" ===
let g:coc_global_extensions = [
 \	'coc-clangd',
 \	'coc-cmake',
 \	'coc-eslint',
 \	'coc-go',
 \	'coc-html',
 \	'coc-java',
 \	'coc-json',
 \	'coc-lua',
 \	'coc-phpactor',
 \	'coc-python',
 \	'coc-sh',
 \	'coc-vimlsp'
 \	]

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                             \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" ===
" === nvim-tree
" ===
nmap tt :NvimTreeToggle<CR>

lua << EOF
require'nvim-web-devicons'.setup {
  default = true;
}

require'nvim-tree'.setup()
EOF

" ===
" === tagbar
" ===
nnoremap mm : TagbarToggle<CR> 

" ===
" === telescope
" ===
lua << EOF
require'telescope'.setup{
  pickers = {
    find_files = {
      theme = "dropdown",
    }
  }
}
EOF

nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
" nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
" nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
" nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" ===
" === bufferline
" ===
lua << EOF
require("bufferline").setup{}
EOF

nnoremap <silent>[b :BufferLineCycleNext<CR>
nnoremap <silent>[p :BufferLineCyclePrev<CR>

" ===
" === nvim-treesitter
" === 
lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {
	  "c",
	  "cmake",
	  "cpp",
	  "fish",
	  "go",
	  "java",
	  "javascript", 
	  "json",
	  "llvm",
	  "perl",
	  "php",
	  "python",
	  "rust",
	  "typescript",
	  "vim",
	  "vue",
	  "yaml",
	  "lua"
	},

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  ignore_install = { "" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF
