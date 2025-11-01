vim.g.mapleader = ' '
vim.g.netrw_banner = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
vim.o.number = true
vim.o.relativenumber = true
vim.o.winborder = 'solid'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.sidescrolloff = 10
vim.o.endofline = false
vim.o.fixendofline = false
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.wrap = false
vim.o.statusline = ' %f' .. '%r' .. '%m' .. '%= ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. ' %#PmenuSel# %{&filetype}%*' .. '%#PmenuSel#[%{&fileformat}] %*' .. '%#Search# %l:%c %*'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.o.rtp = lazypath .. ',' .. vim.o.rtp

require('lazy').setup({
    { 'nvim-lua/plenary.nvim', commit = '857c5ac' },
    { 'folke/tokyonight.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'saghen/blink.cmp', version = '1.*' },
    { 'neovim/nvim-lspconfig' },
    { 'mason-org/mason.nvim' },
    { 'ThePrimeagen/harpoon', branch = 'harpoon2' },
    { 'j-hui/fidget.nvim' },
    { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate' }
}, {
    ui = {
        icons = {
            cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
            keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
            source = '📄', start = '🚀', task = '📌', lazy = '💤 '
        }
    }
})

require('tokyonight').setup({
    styles = { comments = { italic = false }, keywords = { italic = false }},
    on_colors = function(colors)
        colors.bg = '#16161e'
        colors.bg_statusline = '#292e42'
        colors.bg_float = '#222228'
    end
})

vim.cmd.syntax('off')
vim.cmd.colorscheme('tokyonight-night')

local telescope_main = require('telescope')
telescope_main.setup({
    extensions = {[ 'ui-select' ] = require('telescope.themes').get_dropdown()},
    pickers = {
        find_files = { previewer = false },
        diagnostics = { previewer = false },
        buffers = {
            previewer = false,
            mappings = { n = {[ 'dd' ] = 'delete_buffer' }}
        }
    }
})
telescope_main.load_extension('ui-select')

local telescope = require('telescope.builtin')
local harpoon = require('harpoon')
harpoon.setup()

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>')
vim.keymap.set('n', '<C-l>', '<C-w><C-l>')
vim.keymap.set('n', '<C-j>', '<C-w><C-j>')
vim.keymap.set('n', '<C-k>', '<C-w><C-k>')
vim.keymap.set('n', '<S-l>', '<cmd>bn<CR>')
vim.keymap.set('n', '<S-h>', '<cmd>bp<CR>')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'gra')
vim.keymap.set('n', '<leader>sf', telescope.find_files)
vim.keymap.set('n', '<leader>sg', function() telescope.live_grep({ additional_args = { '--fixed-strings' }}) end)
vim.keymap.set('n', '<leader>sd', telescope.diagnostics)
vim.keymap.set('n', '<leader>sr', telescope.resume)
vim.keymap.set('n', '<leader><leader>', telescope.buffers)
vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end)

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local telescope = require('telescope.builtin')
        vim.keymap.set('n', 'gd', telescope.lsp_definitions, { buffer = event.buf })
        vim.keymap.set('n', 'gr', telescope.lsp_references, { buffer = event.buf })
        vim.keymap.set('n', 'gI', telescope.lsp_implementations, { buffer = event.buf })
        vim.keymap.set('n', '<leader>ss', telescope.lsp_document_symbols, { buffer = event.buf })
        vim.keymap.set('n', '<leader>sw', telescope.lsp_dynamic_workspace_symbols, { buffer = event.buf })
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set({ 'n', 'v' }, '<leader>q', vim.lsp.buf.code_action, { buffer = event.buf })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { buffer = event.buf })

        vim.lsp.get_client_by_id(event.data.client_id).server_capabilities.semanticTokensProvider = nil
    end
})

vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
        local cursor = vim.fn.getpos('.')
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos('.', cursor)
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function(event)
        local parser_name = vim.treesitter.language.get_lang(event.match)

        if parser_name then
            pcall(vim.treesitter.start, event.buf, parser_name)
        end
    end
})

vim.diagnostic.config({ virtual_text = true })
vim.lsp.config('jdtls', { settings = { java = {
    format = { insertSpaces = true },
    sources = { organizeImports = { starThreshold = 1, staticStarThreshold = 1 }}
}}})

require('fidget').setup()
require('mason').setup()

local registry = require('mason-registry')
local package_to_lsp_names = {}

for _, pkg_spec in ipairs(registry.get_all_package_specs()) do
    package_to_lsp_names[pkg_spec.name] = vim.tbl_get(pkg_spec, 'neovim', 'lspconfig')
end

for _, package_name in ipairs(registry.get_installed_package_names()) do
    vim.lsp.enable(package_to_lsp_names[package_name])
end

require('blink.cmp').setup({
    cmdline = { enabled = false },
    sources = { default = { 'lsp', 'buffer' }},
    signature = { enabled = true },
    completion = {
        accept = { auto_brackets = { enabled = false }},
        documentation = { auto_show = true, auto_show_delay_ms = 0 },
        list = { selection = { auto_insert = false }},
        menu = {
            auto_show = false,
            max_height = 30,
            draw = { columns = {{ 'label', 'label_description', gap = 1 }, { 'kind' }}}
        }
    },
    keymap = {
        preset = 'default',
        [ '<C-k>' ] = { 'select_prev', 'fallback' },
        [ '<C-j>' ] = { 'select_next', 'fallback' }
    }
})
