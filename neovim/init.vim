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

" colorscheme
Plug 'morhetz/gruvbox'

" indent-blankline
Plug 'lukas-reineke/indent-blankline.nvim'

" nvim-tree
Plug 'kyazdani42/nvim-web-devicons' " for file icons 
Plug 'kyazdani42/nvim-tree.lua'

" tagbar
Plug 'preservim/tagbar'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" bufferline
" Plug 'akinsho/bufferline.nvim'

" nvim-cmp
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

" ===
" === colorscheme
" ===
set background=dark
colorscheme gruvbox

" ===
" === indent-blankline
" ===
lua << EOF
require("indent_blankline").setup{
  show_current_context = true,
  show_current_context_start = true,
}
EOF

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
"lua << EOF
"require("bufferline").setup{}
"EOF

"nnoremap <silent>[b :BufferLineCycleNext<CR>
"nnoremap <silent>[p :BufferLineCyclePrev<CR>

" ===
" === nvim-cmp
" ===
set completeopt=menu,menuone,noselect

lua <<EOF

  require("nvim-lsp-installer").setup({
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
      icons = {
        server_installed = "✓",
	server_pending = "➜",
        server_uninstalled = "✗"
      }
    }
  })

  -- Setup nvim-cmp.
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end

  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.fn["vsnip#available"](1) == 1 then
          feedkey("<Plug>(vsnip-expand-or-jump)", "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
  
  -- help lspconfig-all or https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md 
  local lspconfs = {'asm_lsp', 'clangd', 'cmake', 'bashls', 'dockerls', 'eslint', 'gopls', 'html', 'jsonls',
  	'java_language_server', 'marksman', 'phpactor', 'sqlls', 'yamlls'}
  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  for idx, lspconf in ipairs(lspconfs) do 
    require('lspconfig')[lspconf].setup {
      capabilities = capabilities
    }
  end
EOF

" ===
" === nvim-treesitter
" === 
lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {
	  "bash",
	  "c",
	  "cmake",
	  "cpp",
	  "fish",
	  "go",
	  "java",
	  "javascript", 
	  "json",
	  "llvm",
	  "lua",
	  "make",
	  "ninja",
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
