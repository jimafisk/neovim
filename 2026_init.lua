-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugins
require("lazy").setup({
  -- File Search
  { "junegunn/fzf", dir = "~/.fzf", build = "./install --all" },
  { "junegunn/fzf.vim" },

  -- File Browser
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*" },
  { "jimafisk/vim-bbye" },

  -- Minimap
  { "echasnovski/mini.map" },

  -- Color
  { "morhetz/gruvbox" },
  { "navarasu/onedark.nvim" },

  -- Pico
  { "plentico/pico-language", config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/neovim")
  end },

  -- Golang
  { "fatih/vim-go", build = ":GoUpdateBinaries" },

  -- Svelte
  { "othree/html5.vim" },
  { "pangloss/vim-javascript" },
  { "evanleck/vim-svelte", branch = "main" },

  -- Templ
  { "joerdav/templ.vim" },

  -- Autocomplete
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp-signature-help" },

  -- Snippets
  { "hrsh7th/cmp-vsnip" },
  { "hrsh7th/vim-vsnip" },
  { "golang/vscode-go" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Terminal
  { "Jantcu/nvim-terminal" },
})

-------------------------------------------------------------------------------
-- COPY/PASTE
-------------------------------------------------------------------------------
-- Increases the memory limit from 50 lines to 1000 lines
vim.opt.viminfo = "'100,<1000,s10,h"
vim.opt.clipboard:append("unnamedplus")

-------------------------------------------------------------------------------
-- NUMBERING
-------------------------------------------------------------------------------
vim.opt.number = true

-------------------------------------------------------------------------------
-- INDENTATION
-------------------------------------------------------------------------------
-- Highlights code for multiple indents without reselecting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-------------------------------------------------------------------------------
-- WRAPPING
-------------------------------------------------------------------------------
vim.opt.wrap = false

-------------------------------------------------------------------------------
-- TABS/SPACE
-------------------------------------------------------------------------------
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.list = true
vim.opt.listchars = { tab = "  ", lead = "·", trail = "·", nbsp = "␣" }
vim.opt.expandtab = true
vim.opt.softtabstop = 4

-------------------------------------------------------------------------------
-- COLOR
-------------------------------------------------------------------------------
vim.g.onedark_config = { style = "deep" }
vim.cmd.colorscheme("onedark")

-------------------------------------------------------------------------------
-- AUTO IMPORT (vim-go)
-------------------------------------------------------------------------------
vim.g.go_fmt_command = "goimports"

-------------------------------------------------------------------------------
-- FILE SEARCH (FZF)
-------------------------------------------------------------------------------
-- allows FZF to open by pressing CTRL-P
vim.keymap.set("n", "<C-p>", ":FZF<CR>", { silent = true })
-- allow FZF to search hidden 'dot' files
vim.env.FZF_DEFAULT_COMMAND = "find -L"

-------------------------------------------------------------------------------
-- FILE BROWSER (nvim-tree)
-------------------------------------------------------------------------------
-- https://github.com/nvim-tree/nvim-tree.lua/issues/1493#issuecomment-2111092995
vim.g.nvim_tree_open = 0
if vim.fn.isdirectory(vim.fn.argv(0) or "") == 1 then
  vim.g.nvim_tree_open = 1
end

local function NvimTreeToggleAll()
  local current_tab = vim.fn.tabpagenr()
  if vim.g.nvim_tree_open == 1 then
    vim.cmd("tabdo NvimTreeClose")
    vim.g.nvim_tree_open = 0
  else
    vim.cmd("tabdo NvimTreeOpen")
    vim.g.nvim_tree_open = 1
  end
  vim.cmd("tabnext " .. current_tab)
end

vim.keymap.set("n", "nt", NvimTreeToggleAll, { silent = true })

-------------------------------------------------------------------------------
-- TABS / BUFFERS
-------------------------------------------------------------------------------
-- https://github.com/moll/vim-bbye/issues/15#issuecomment-2142727505
vim.keymap.set("n", "<C-q>", ":Bdelete<CR>", { silent = true })
vim.keymap.set("n", "<C-s>", ":w<CR>", { silent = true })
vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>", { silent = true })
vim.keymap.set("n", "gt", ":BufferLineCycleNext<CR>", { silent = true })
vim.opt.hidden = true

-------------------------------------------------------------------------------
-- SHORTCUTS
-------------------------------------------------------------------------------
-- Open file at same line last closed
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-------------------------------------------------------------------------------
-- SOURCING
-------------------------------------------------------------------------------
-- Automatically reloads neovim configuration file on write (w)
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "init.lua",
  command = "source %",
})

-------------------------------------------------------------------------------
-- MOUSE
-------------------------------------------------------------------------------
-- Allow using mouse helpful for switching/resizing windows
vim.opt.mouse:append("a")

-------------------------------------------------------------------------------
-- TEXT SEARCH
-------------------------------------------------------------------------------
-- Makes Search Case Insensitive
vim.opt.ignorecase = true

-------------------------------------------------------------------------------
-- SWAP
-------------------------------------------------------------------------------
vim.opt.directory = vim.fn.expand("~/.local/share/nvim/swap/")

-------------------------------------------------------------------------------
-- SYNTAX HIGHLIGHTING
-------------------------------------------------------------------------------
vim.cmd("syntax on")

-------------------------------------------------------------------------------
-- HIGHLIGHTING
-------------------------------------------------------------------------------
-- <Ctrl-l> redraws the screen and removes any search highlighting.
vim.keymap.set("n", "<C-l>", ":nohl<CR><C-l>", { silent = true })
-- Highlight the current line the cursor is on
vim.opt.cursorline = true

-------------------------------------------------------------------------------
-- AUTOCOMPLETE (nvim-cmp)
-------------------------------------------------------------------------------
local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  mapping = cmp.mapping({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "nvim_lsp_signature_help" },
  }, {
    { name = "buffer" },
  }),
})

-- Snippet jump mappings (vsnip)
local function jump_next()
  if vim.fn["vsnip#jumpable"](1) == 1 then
    return "<Plug>(vsnip-jump-next)"
  end
end

local function jump_prev()
  if vim.fn["vsnip#jumpable"](-1) == 1 then
    return "<Plug>(vsnip-jump-prev)"
  end
end

for _, key in ipairs({ "<Tab>", "<C-j>" }) do
  vim.keymap.set({ "i", "s" }, key, function()
    return jump_next() or key
  end, { expr = true, remap = true })
end

for _, key in ipairs({ "<S-Tab>", "<C-k>" }) do
  vim.keymap.set({ "i", "s" }, key, function()
    return jump_prev() or key
  end, { expr = true, remap = true })
end

-------------------------------------------------------------------------------
-- LSP CONFIG
-------------------------------------------------------------------------------
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- go install golang.org/x/tools/gopls@latest
vim.lsp.config("gopls", {
  capabilities = capabilities,
})
vim.lsp.enable("gopls")

-- npm install -g svelte-language-server
vim.lsp.config("svelte", {
  capabilities = capabilities,
})
vim.lsp.enable("svelte")

-- go install github.com/a-h/templ/cmd/templ@latest
vim.lsp.config("templ", {
  capabilities = capabilities,
})
vim.lsp.enable("templ")

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
  end,
})

-------------------------------------------------------------------------------
-- nvim-tree
-------------------------------------------------------------------------------
require("nvim-web-devicons").setup({
  override_by_extension = {
    pico = {
      icon = "󰗀",
      color = "#1c7fc7",
      cterm_color = "39",
      name = "Pico",
    },
  },
  color_icons = true,
})

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
      { filetype = "NvimTree", text = "Directory" },
    },
    left_mouse_command = function(bufnum)
      vim.fn.win_gotoid(vim.g.main_win)
      vim.cmd("buffer " .. bufnum)
    end,
  },
})

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "hgb", function()
      gitsigns.blame_line({ full = true })
    end)
    map("n", "hgtb", gitsigns.toggle_current_line_blame)
    map("n", "hgd", gitsigns.diffthis)
    map("n", "hgtd", function()
      gitsigns.diffthis("~")
    end)
    map("n", "hgm", gitsigns.toggle_deleted)
  end,
})

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
  },
})
map.open()
vim.keymap.set("n", "mm", MiniMap.toggle)

-------------------------------------------------------------------------------
-- Pico
-------------------------------------------------------------------------------
require("pico").setup()
vim.g.vsnip_snippet_dirs = { vim.fn.expand("~/.local/share/nvim/lazy/pico-language/neovim/snippets") }
