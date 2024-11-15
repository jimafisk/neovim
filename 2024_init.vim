if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd!
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.config/nvim/plugged')
"File Search:
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
"File Browser:
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'jimafisk/vim-bbye'
"Minimap:
Plug 'echasnovski/mini.map'
"Color:
Plug 'morhetz/gruvbox'
Plug 'navarasu/onedark.nvim'
"Golang:
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
"Svelte:
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
"Templ:
Plug 'joerdav/templ.vim'
"Autocomplete:
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
"Snippets:
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'golang/vscode-go'
"Git:
Plug 'lewis6991/gitsigns.nvim'
"Terminal:
Plug 'Jantcu/nvim-terminal'
call plug#end()

"COPY/PASTE:
"-----------
"Increases the memory limit from 50 lines to 1000 lines
:set viminfo='100,<1000,s10,h
set clipboard+=unnamedplus

"NUMBERING:
"----------
:set number

"INDENTATION:
"------------
"Highlights code for multiple indents without reselecting
vnoremap < <gv
vnoremap > >gv

"TABS/SPACE:
"-----------
set shiftwidth=4
set tabstop=4
set list
set listchars=tab:\ ,lead:·,trail:·,nbsp:␣
"set listchars=eol:↵,trail:~,space:·,extends:\#

"COLOR:
"------
"colorscheme gruvbox
let g:onedark_config = {
    \ 'style': 'deep',
\}
colorscheme onedark

"AUTO IMPORT:
"------------
let g:go_fmt_command = "goimports"

"FILE SEARCH:
"------------
"allows FZF to open by pressing CTRL-F
map <C-p> :FZF<CR>
"allow FZF to search hidden 'dot' files
let $FZF_DEFAULT_COMMAND = "find -L"

"FILE BROWSER:
"-------------
" https://github.com/nvim-tree/nvim-tree.lua/issues/1493#issuecomment-2111092995
function! NvimTreeToggleAll()
	let current_tab = tabpagenr()
	if g:nvim_tree_open
		tabdo NvimTreeClose
		let g:nvim_tree_open = 0
	else
		tabdo NvimTreeOpen
		let g:nvim_tree_open = 1
	endif
	execute 'tabnext' current_tab
endfunction
let g:nvim_tree_open = 0
if isdirectory(argv(0))
	let g:nvim_tree_open = 1
endif
nnoremap nt :call NvimTreeToggleAll()<CR>

"TABS / BUFFERS:
"---------------
" https://github.com/moll/vim-bbye/issues/15#issuecomment-2142727505
map <silent> <C-q> :Bdelete<CR>
map <silent> <C-s> :w<CR>
nnoremap gT :BufferLineCyclePrev<CR>
nnoremap gt :BufferLineCycleNext<CR>
set hidden

"SHORTCUTS:
"----------
"Open file at same line last closed
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
  \| exe "normal! g'\"" | endif
endif

"SOURCING:
"---------
"Automatically reloads neovim configuration file on write (w)
autocmd! bufwritepost init.vim source %

"MOUSE:
"------
"Allow using mouse helpful for switching/resizing windows
set mouse+=a
if &term =~ '^screen'
  " tmux knows the extended mouse mode
  set ttymouse=xterm2
endif

"TEXT SEARCH:
"------------
"Makes Search Case Insensitive
set ignorecase

"SWAP:
"-----
set dir=~/.local/share/nvim/swap/

"SYNTAX HIGHLIGHTING:
"--------------------
syntax on

"HIGHLIGHTING:
"-------------
" <Ctrl-l> redraws the screen and removes any search highlighting.
nnoremap <silent> <C-l> :nohl<CR><C-l>
" Highlight the current line the cursor is on
set cursorline

"ERRORS:
"-------
"function! ToggleError()
"	if g:error_open
"		:lua vim.diagnostic.close_float() <CR>
"		let g:error_open = 0
"	else
"		:lua vim.diagnostic.open_float() <CR>
"		let g:error_open = 1
"	endif
"endfunction
"let g:error_open = 0
"map <silent> <C-m> :call ToggleError()<CR>

"AUTOCOMPLETE:
"-------------
lua <<EOF
-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
		vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
		end,
	},
	mapping = cmp.mapping({
	-- mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		{ name = 'nvim_lsp_signature_help' }, -- https://github.com/hrsh7th/nvim-cmp/discussions/993
	}, {
		{ name = 'buffer' },
	})
})

-- Load LSPs
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- go install golang.org/x/tools/gopls@latest
require('lspconfig')['gopls'].setup {
	capabilities = capabilities
}
-- npm install -g svelte-language-server
require('lspconfig')['svelte'].setup {
	capabilities = capabilities
}
-- go install github.com/a-h/templ/cmd/templ@latest
require('lspconfig')['templ'].setup {
	capabilities = capabilities
}

-- Set reveal definition / docs to CTRL+K (matches nvim-tree defaults)
-- https://vi.stackexchange.com/questions/37225/how-do-i-close-a-hovered-window-with-lsp-information-escape-does-not-work
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.keymap.set("n", "<C-k>", function()
			local base_win_id = vim.api.nvim_get_current_win()
			local windows = vim.api.nvim_tabpage_list_wins(0)
			for _, win_id in ipairs(windows) do
				if win_id ~= base_win_id then
					local win_cfg = vim.api.nvim_win_get_config(win_id)
					if win_cfg.relative == "win" and win_cfg.win == base_win_id then
						vim.api.nvim_win_close(win_id, {})
						return
					end
				end
			end
			vim.lsp.buf.hover()
		end, { remap = false, silent = true, buffer = ev.buf, desc = "Toggle hover" })
		-- Probably lots of other keymaps...
	end
})

---------------
-- nvim-tree --
---------------
-- disable default netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true -- enable 24-bit colour
require("nvim-tree").setup({
	open_on_tab = true,
	update_focused_file = {
		enable = true,
	},
	git = {
		ignore = false,
	},
	renderer = {
		-- https://github.com/NvChad/NvChad/issues/1956#issuecomment-1523128023
		root_folder_label = false,
	},
})
require("bufferline").setup({
	options = {
		close_command = ":Bdelete",
		offsets = {
			{ filetype = 'NvimTree', text = 'Directory' },
		},
		left_mouse_command = function(bufnum)
			vim.fn.win_gotoid(vim.g.main_win)
			vim.cmd('buffer ' .. bufnum)
		end,
	}
})
require('gitsigns').setup({
	on_attach = function(bufnr)
		local gitsigns = require('gitsigns')
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map('n', 'hgb', function() gitsigns.blame_line{full=true} end)
		map('n', 'hgtb', gitsigns.toggle_current_line_blame)
		map('n', 'hgd', gitsigns.diffthis)
		map('n', 'hgtd', function() gitsigns.diffthis('~') end)
		map('n', 'hgm', gitsigns.toggle_deleted)
	end
})

-- require('mini.map').setup({
local map = require("mini.map")
map.setup({
	window = {
		focusable = true,
		zindex = 1,
	},
	integrations = {
		map.gen_integration.gitsigns({
			add = "GitSignsAdd",
			change = "GitSignsChange",
			delete = "GitSignsDelete",
		}),
	},
	symbols = {
		encode = map.gen_encode_symbols.dot("3x2"),
	}
})
map.open()
vim.keymap.set('n', 'mm', MiniMap.toggle)

EOF
