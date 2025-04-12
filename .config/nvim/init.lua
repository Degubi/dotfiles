vim.g.mapleader = ' '
vim.g.have_nerd_font = false
vim.g.netrw_banner = 0
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

vim.o.number = true
vim.o.relativenumber = true
vim.o.winborder = 'rounded'
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 1000
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'
vim.o.cursorline = true
vim.o.scrolloff = 5
vim.o.sidescrolloff = 10
vim.o.endofline = false
vim.o.fixendofline = false
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.statusline = table.concat({
    ' %f',
    '%r',
    '%m',
    '%=',
    ('%%#PmenuSel#%s%%*'):format(' %{&filetype}'),
    ('%%#PmenuSel#[%s] %%*'):format('%{&fileformat}'),
    ('%%#Search#%s%%*'):format(' %l:%c ')
})
vim.cmd.syntax('off')

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

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function()
        local cursor = vim.fn.getpos('.')
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos('.', cursor)
    end
})

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = event.buf })
        vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = event.buf })
        vim.keymap.set('n', 'gI', builtin.lsp_implementations, { buffer = event.buf })
        vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { buffer = event.buf })
        vim.keymap.set('n', '<leader>sw', builtin.lsp_dynamic_workspace_symbols, { buffer = event.buf })
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = event.buf })
        vim.keymap.set({ 'n', 'v' }, '<leader>q', vim.lsp.buf.code_action, { buffer = event.buf })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { buffer = event.buf })

        vim.lsp.get_client_by_id(event.data.client_id).server_capabilities.semanticTokensProvider = nil
    end
})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.o.rtp = lazypath .. ',' .. vim.o.rtp

require('lazy').setup({
    { 'nvim-lua/plenary.nvim' },
    {
        'nvim-telescope/telescope.nvim',
        config = function()
            local telescope = require('telescope')

            telescope.setup({
                extensions = {
                    [ 'ui-select' ] = require('telescope.themes').get_dropdown()
                },
                pickers = {
                    find_files = { previewer = false },
                    diagnostics = { previewer = false },
                    buffers = {
                        previewer = false,
                        mappings = { n = { [ 'dd' ] = 'delete_buffer' }}
                    }
                }
            })

            pcall(telescope.load_extension, 'fzf')
            pcall(telescope.load_extension, 'ui-select')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>sf', builtin.find_files)
            vim.keymap.set('n', '<leader>sg', function() builtin.live_grep({ additional_args = { '--fixed-strings' } }) end)
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics)
            vim.keymap.set('n', '<leader>sr', builtin.resume)
            vim.keymap.set('n', '<leader><leader>', builtin.buffers)
        end
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    {
        'saghen/blink.cmp',
        version = '1.*',
        opts = {
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
        }
    },
    { 'neovim/nvim-lspconfig' },
    { 'williamboman/mason.nvim', opts = {} },
    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require('lspconfig')

            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        local options = server_name ~= 'jdtls' and { capabilities = capabilities } or {
                            capabilities = capabilities,
                            settings = {
                                java = {
                                    format = { insertSpaces = true },
                                    sources = {
                                        organizeImports = { starThreshold = 1, staticStarThreshold = 1 }
                                    }
                                }
                            }
                        }

                        lspconfig[server_name].setup(options)
                    end
                }
            })
        end
    },
    { 'j-hui/fidget.nvim', opts = {} },
    { 'echasnovski/mini.ai', opts = { n_lines = 500 } },
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        opts = {
            styles = { comments = { italic = false }, keywords = { italic = false }},
            on_colors = function(colors)
                colors.bg = '#16161e'
                colors.bg_statusline = '#292e42'
            end
        },
        init = function()
            vim.cmd.colorscheme('tokyonight-night')
            vim.cmd.hi('Comment gui=none')
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        main = 'nvim-treesitter.configs',
        opts = {
            auto_install = true,
            highlight = { enable = true, additional_vim_regex_highlighting = false }
        }
    }
}, {
    ui = {
        icons = {
            cmd = '⌘', config = '🛠', event = '📅', ft = '📂', init = '⚙',
            keys = '🗝', plugin = '🔌', runtime = '💻', require = '🌙',
            source = '📄', start = '🚀', task = '📌', lazy = '💤 '
        }
    }
})
