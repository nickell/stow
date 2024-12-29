return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy find files' } },
      { '<A-l>', '<cmd>Telescope<cr>' },
      { '<A-;>', '<cmd>Telescope resume<cr>' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>' },
      {
        '<leader>fs',
        function() require('telescope.builtin').lsp_document_symbols { ignore_symbols = 'property' } end,
      },
      {
        '<leader>fw',
        function() require('telescope.builtin').live_grep { default_text = vim.fn.expand '<cword>' } end,
      },
      { '<leader>fr', '<cmd>Telescope lsp_references<cr>' },
      -- { '<leader>fb', function() require('neogit').action('branch', 'checkout_local_branch')() end },
      { '<leader>fb', '<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>' },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local telescopeConfig = require 'telescope.config'
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, '--hidden')
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!**/.git/*')

      require('telescope').setup {
        defaults = {
          path_display = { 'smart' },
          vimgrep_arguments = vimgrep_arguments,
          preview = {
            filesize_limit = 1,
          },
          theme = 'dropdown',
          mappings = {
            i = {
              ['<C-h>'] = 'which_key',
              ['<C-a>'] = 'select_all',
              ['<C-q'] = actions.send_selected_to_qflist + actions.open_qflist,
            },
            n = {
              ['<C-a>'] = 'select_all',
              ['<C-q'] = actions.send_selected_to_qflist + actions.open_qflist,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
            theme = 'dropdown',
          },
          live_grep = {
            mappings = {
              i = {
                ['<c-f>'] = actions.to_fuzzy_refine,
                ['<c-space>'] = actions.to_fuzzy_refine,
                ['<C-q'] = actions.send_selected_to_qflist + actions.open_qflist,
              },
              n = {
                ['f'] = actions.to_fuzzy_refine,
                ['<C-q'] = actions.send_selected_to_qflist + actions.open_qflist,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          },
        },
      }

      telescope.load_extension 'fzf'
      telescope.load_extension 'file_browser'
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  },
  {
    'FeiyouG/commander.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    keys = {
      { '<leader>f', '<CMD>Telescope commander<CR>', mode = 'n' },
      { '<leader>fc', '<CMD>Telescope commander<CR>', mode = 'n' },
    },
    config = function()
      require('commander').setup {
        components = {
          'DESC',
          'KEYS',
          'CAT',
        },
        sort_by = {
          'DESC',
          'KEYS',
          'CAT',
          'CMD',
        },
        integration = {
          telescope = {
            enable = true,
          },
          lazy = {
            enable = true,
            set_plugin_name_as_cat = true,
          },
        },
      }
    end,
  },
}
