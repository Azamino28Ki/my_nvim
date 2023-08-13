" ----- visual/ -----
set number
" ----- /visual -----

" ----- install dein.vim/ -----
let $CACHE = expand('~/.cache')
if !isdirectory($CACHE)
  call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
  let s:dein_dir = fnamemodify('dein.vim', ':p')
  if !isdirectory(s:dein_dir)
    let s:dein_dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'
    if !isdirectory(s:dein_dir)
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    endif
  endif
  execute 'set runtimepath^=' .. substitute(
        \ fnamemodify(s:dein_dir, ':p') , '[/\\]$', '', '')
endif
" ----- /install dein.vim -----

" ----- config dein.vim/ -----
" Ward off unexpected things that your distro might have made, as
" well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Set dein base path (required)
let s:dein_base = '~/.cache/dein/'

" Set dein source path (required)
let s:dein_src = '~/.cache/dein/repos/github.com/Shougo/dein.vim'

" Set dein runtime path (required)
execute 'set runtimepath+=' .. s:dein_src

" Call dein initialization (required)
call dein#begin(s:dein_base)

call dein#add(s:dein_src)

" プラグインリストを収めた TOML ファイル
" 予め TOML ファイル（後述）を用意しておく
let g:rc_dir    = expand("~/.config/nvim")
let s:toml      = g:rc_dir . '/dein.toml'
let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'
" TOML を読み込み、キャッシュしておく
call dein#load_toml(s:toml,      {'lazy': 0})
call dein#load_toml(s:lazy_toml, {'lazy': 1})

" Finish dein initialization (required)
call dein#end()

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
if has('syntax')
  syntax on
endif

" Uncomment if you want to install not-installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
" ----- /config dein.vim -----

" ----- nvim-lspconfig+mason.nvim+mason-lspconfig/ -----
lua << EOF
 local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  local set = vim.keymap.set
   set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
   set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
   set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
   set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
   set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
   set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
   set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
   set('n', 'gx', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
   set('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
   set('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
   set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
 end
 vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
 vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

 require("mason").setup()
 
 local mason_lspconfig = require('mason-lspconfig')
 local nvim_lsp = require('lspconfig')
 mason_lspconfig.setup_handlers({ function(server_name)
     	local opts = {}
	opts.on_attach = on_attach
	nvim_lsp[server_name].setup(opts)
 end })
 mason_lspconfig.setup {
 	ensure_installed = {'clangd'}
 }
EOF

" ----- /nvim-lspconfig+mason.nvim+mason-lspconfig -----

" /----- nvim-cmp -----
lua << EOF
 local cmp = require("cmp")
 cmp.setup({
 	snippet = {
		expand = function(args)
		    vim.fn["vsnip#anonymous"](args.body)
		end,
  	},
	sources = {
		{ name = "nvim_lsp" },
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		['<C-l>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm { select = true },
	}),
	experimental = {
		ghost_text = true,
	},
 })
EOF
" ----- nvim-cmp -----/

