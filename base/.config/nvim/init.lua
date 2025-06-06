vim.g.mapleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  change_detection = {
    enabled = true,
    notify = false,
  },
})

local o = vim.opt

o.autoindent = true
o.clipboard = 'unnamedplus'
o.expandtab = true
o.ignorecase = true
o.number = true
o.relativenumber = true
o.shiftwidth = 2
o.smartcase = true
o.softtabstop = 2
o.tabstop = 2
o.termguicolors = true
o.wildignorecase = true
o.wrap = false

o.backup = true
o.backupskip = '/tmp/*,/private/tmp/*'
o.swapfile = false
o.writebackup = true

o.history = 100
o.sessionoptions = 'blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions'
o.undofile = true
o.undolevels = 100

o.foldcolumn = '1'
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true

o.backupdir = vim.fn.expand '~/.config/nvim/backup/'
o.directory = vim.fn.expand '~/.config/nvim/swap/'
o.undodir = vim.fn.expand '~/.config/nvim/undo/'

o.conceallevel = 2

o.fillchars:append { diff = '╱' }

local function map(mode, key, command, options)
  if options == nil then options = {} end
  options = vim.tbl_extend('error', options, { noremap = true, silent = true })
  vim.keymap.set(mode, key, command, options)
end

local function nmap(key, command, options) map('n', key, command, options) end
local function vmap(key, command, options) map('v', key, command, options) end
local function cmap(key, command, options) map('c', key, command, options) end

nmap('-', 'dd')
nmap('<A-j>', ':m .+1<CR>')
nmap('<A-k>', ':m .-2<CR>')
nmap('<C-h>', '<CMD>NavigatorLeft<CR>')
nmap('<C-j>', '<CMD>NavigatorDown<CR>')
nmap('<C-k>', '<CMD>NavigatorUp<CR>')
nmap('<C-l>', '<CMD>NavigatorRight<CR>')
nmap('<CR>', 'i<CR><ESC>')
nmap('<Leader><CR>', ':noh<CR>')
nmap('<Leader>bo', ':%bd|e#|bd#<CR>')
nmap('<Leader>j', function() vim.diagnostic.jump { count = 1, float = true } end)
nmap('<Leader>k', function() vim.diagnostic.jump { count = -1, float = true } end)
nmap('<Leader>q', vim.diagnostic.setloclist)
nmap('<Leader>w', ':write<CR>')
nmap('<Leader>x', ':bd<CR>')
nmap('<Leader>X', "<cmd>call delete(expand('%')) | bdelete!<CR>")
nmap('L', 'zO')
nmap('H', 'zC')
nmap('zL', 'L')
nmap('zH', 'H')
nmap('QQ', ':quit<CR>')
nmap('X', ':bd<CR>')
nmap('gn', '<cmd>BufferLineCycleNext<CR>')
nmap('gp', '<cmd>BufferLineCyclePrev<CR>')

vmap('<', '<gv')
vmap('<A-j>', ":m '>+1<CR>gv=gv")
vmap('<A-k>', ":m '<-2<CR>gv=gv")
vmap('>', '>gv')

cmap('w!!', ':w !sudo tee > /dev/null %')
