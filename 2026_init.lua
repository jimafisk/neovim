-- Make vim.treesitter.start safe to prevent errors when parsers aren't installed
-- This is needed because the built-in lua ftplugin calls vim.treesitter.start()
local original_ts_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang)
  local ok = pcall(original_ts_start, bufnr, lang)
  if not ok then
    -- Parser not available, silently fall back to syntax highlighting
  end
end

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
  {
    "A7Lavinraj/fyler.nvim",
    branch = "stable",
    lazy = false,
    dependencies = { "echasnovski/mini.icons" },
  },
  { "nvim-tree/nvim-web-devicons" },
  { "akinsho/bufferline.nvim", version = "*" },
  { "jimafisk/vim-bbye" },

  -- Minimap
  { "echasnovski/mini.map" },

  -- Color
  { "morhetz/gruvbox" },
  { "navarasu/onedark.nvim" },

  -- Pico
  --{ dir = "/home/jim/Projects/plentico/pico-language", config = function(plugin)
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
  { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "golang/vscode-go" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Terminal
  { "Jantcu/nvim-terminal" },

  -- Treesitter (syntax highlighting / parsing)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- Load immediately to avoid ftplugin errors
    priority = 1000,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "go", "svelte", "javascript", "html", "css" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
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
-- FILE BROWSER (fyler.nvim)
-------------------------------------------------------------------------------
-- Toggle fyler sidebar with Alt+f  
vim.keymap.set("n", "<A-f>", function()
  require("fyler").toggle({ kind = "split_left_most" })
end, { silent = true })

-------------------------------------------------------------------------------
-- TABS / BUFFERS
-------------------------------------------------------------------------------
-- https://github.com/moll/vim-bbye/issues/15#issuecomment-2142727505
vim.keymap.set("n", "<A-q>", ":Bdelete<CR>", { silent = true })
vim.keymap.set("n", "<A-s>", ":w<CR>", { silent = true })
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
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For LuaSnip users.
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
    { name = "luasnip" },
    { name = "nvim_lsp_signature_help" },
  }, {
    { name = "buffer" },
  }),
})

-- Snippet jump mappings (LuaSnip)
vim.keymap.set({ "i", "s" }, "<Tab>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-j>", function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-k>", function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  end
end, { silent = true })

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
-- fyler.nvim
-------------------------------------------------------------------------------
require('mini.icons').setup({
  extension = {
    pico  = { glyph = '󰰙', hl = 'MiniIconsBlue' },
  },
})

--[[
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
]]

-- disable default netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true -- enable 24-bit colour

-- Fyler setup - edit filesystem like a buffer with vim motions
-- i/I/A = rename (insert mode), o = new file below, dd = delete, V then x/p = cut/paste
require("fyler").setup({
  views = {
    finder = {
      close_on_select = false,  -- Keep sidebar open when selecting files
      default_explorer = true,  -- Replace netrw
      follow_current_file = true,  -- Auto-focus current file
      columns = {
        git = {
          enabled = true,
        },
      },
      win = {
        kind = "split_left_most",
        kinds = {
          split_left_most = {
            width = 30,  -- Fixed width in columns
            win_opts = {
              winfixwidth = true,
              signcolumn = "yes",  -- Adds left padding
            },
          },
        },
      },
    },
  },
})

require("bufferline").setup({
  options = {
    close_command = ":Bdelete",
    offsets = {
      { filetype = "fyler", text = "Directory" },
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
--require("pico").setup()
require('pico').setup({ lsp = true })
