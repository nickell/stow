local source_buffer = nil

-- Function to list directories in the current working directory
local function get_directories_in_cwd()
  local cwd = vim.fn.getcwd()
  local handle = io.popen('find "' .. cwd .. '" -type d')
  if not handle then return {} end

  local result = {}
  for line in handle:lines() do
    -- Convert to relative path
    local relative_path = vim.fn.fnamemodify(line, ':.')
    if relative_path == cwd then relative_path = '/' end
    table.insert(result, relative_path)
  end
  handle:close()
  return result
end

-- Custom picker for directories
local function move_file_to_directory_picker()
  -- Capture the source buffer
  source_buffer = vim.api.nvim_get_current_buf()

  -- Get the list of directories
  local directories = get_directories_in_cwd()

  -- Use Telescope to display the directories
  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Move File to Directory',
      finder = require('telescope.finders').new_table {
        results = directories,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry,
            ordinal = entry,
          }
        end,
      },
      sorter = require('telescope.config').values.generic_sorter {},
      attach_mappings = function(prompt_bufnr, map)
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        -- Custom action to move the file
        local function move_file()
          -- Ensure source_buffer is valid
          if not source_buffer then
            print 'Source buffer not tracked.'
            return
          end

          -- Get the selected directory
          local selection = action_state.get_selected_entry()
          if not selection or not selection.value then
            print 'No valid selection.'
            return
          end

          local destination_directory = selection.value

          -- Get the source file path
          local source_file_path = vim.api.nvim_buf_get_name(source_buffer)
          if source_file_path == '' then
            print 'Source buffer is not associated with a file.'
            return
          end

          -- Extract the file name from the source file path
          local file_name = vim.fn.fnamemodify(source_file_path, ':t')

          -- Construct the new file path
          local new_file_path = destination_directory .. '/' .. file_name

          -- Move the file using os.rename
          local success = os.rename(source_file_path, new_file_path)
          if success then
            print('Moved ' .. source_file_path .. ' to ' .. new_file_path)
            -- Update the buffer with the new file path
            vim.api.nvim_buf_set_name(source_buffer, new_file_path)
            -- Reload the buffer
          else
            print 'Failed to move the file.'
          end

          -- Close the picker
          actions.close(prompt_bufnr)
          vim.cmd 'edit'
        end

        -- Map <CR> to move the file
        map('i', '<CR>', move_file)
        map('n', '<CR>', move_file)

        return true
      end,
    })
    :find()
end

-- Create a user command to open the custom picker
vim.api.nvim_create_user_command('MoveFileToDirectory', function() move_file_to_directory_picker() end, {})

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    keys = {
      -- { '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy find files' } },
      { '<A-l>', '<cmd>Telescope<cr>' },
      { '<A-;>', '<cmd>Telescope resume<cr>' },
      -- { '<leader>fg', '<cmd>Telescope live_grep<cr>' },
      -- {
      --   '<leader>fs',
      --   function() require('telescope.builtin').lsp_document_symbols { ignore_symbols = 'property' } end,
      -- },
      -- {
      --   '<leader>fw',
      --   function() require('telescope.builtin').live_grep { default_text = vim.fn.expand '<cword>' } end,
      -- },
      -- { '<leader>fr', '<cmd>Telescope lsp_references<cr>' },
      { '<leader>fm', '<cmd>MoveFileToDirectory<cr>' },
      -- { '<leader>fb', function() require('neogit').action('branch', 'checkout_local_branch')() end },
      -- { '<leader>fb', '<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>' },
      -- { '<leader>fc', '<cmd>Telescope find_files<cr>', { desc = 'Fuzzy find files' } },
    },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local telescope_config = require 'telescope.config'
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }

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
              -- Mapping to move the current file behind the picker
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
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*', '--sortr=modified' },
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
