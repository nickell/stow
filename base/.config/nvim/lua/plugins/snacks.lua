return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      animate = { enabled = true, duration = 20 },
      bufdelete = { enabled = true },
      explorer = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.picker.smart()' },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ':lua Snacks.picker.grep()' },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.picker.recent()' },
            {
              icon = ' ',
              key = 'c',
              desc = 'Config',
              action = ":lua Snacks.picker.smart({cwd = vim.fn.stdpath('config')})",
            },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
      },
      debug = { enabled = true },
      dim = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      picker = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true, timeout = 3000, level = vim.log.levels.WARN },
      notify = { enabled = true },
      profiler = { enabled = true },
      quickfile = { enabled = true },
      rename = { enabled = true },
      scope = { enabled = true },
      scratch = { enabled = true },
      scroll = { enabled = true, duration = { step = 1, total = 1 } },
      statuscolumn = { enabled = true },
      styles = {
        notification = {
          -- wo = { wrap = true } -- Wrap notifications
        },
      },
      -- terminal = { enabled = true },
      toggle = { enabled = true },
      util = { enabled = true },
      win = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
    },
    keys = {
      { '<leader><space>', function() Snacks.picker.smart() end,            desc = 'Smart Find Files' },
      { '<leader>fb',      function() Snacks.picker.buffers() end,          desc = 'Buffers' },
      { '<leader>/',       function() Snacks.picker.grep() end,             desc = 'Grep' },
      { '<leader>fw',      function() Snacks.picker.grep_word() end,        desc = 'Grep' },
      { '<leader>:',       function() Snacks.picker.command_history() end,  desc = 'Command History' },
      { '<leader>n',       function() Snacks.picker.notifications() end,    desc = 'Notification History' },
      { '<leader>e',       function() Snacks.explorer() end,                desc = 'File Explorer' },
      { '<leader>td',      function() Snacks.picker.lsp_definitions() end,  desc = 'Goto Definition' },
      { '<leader>sb',      function() Snacks.picker.lines() end,            desc = 'Buffer Lines' },
      { '<leader>sC',      function() Snacks.picker.commands() end,         desc = 'Commands' },
      { '<leader>ff',      function() Snacks.picker.recent() end,           desc = 'Recent' },
      { '<leader>fr',      function() Snacks.picker.lsp_references() end,   nowait = true,                        desc = 'References' },
      { '<leader>z',       function() Snacks.zen() end,                     desc = 'Toggle Zen Mode' },
      { '<leader>Z',       function() Snacks.zen.zoom() end,                desc = 'Toggle Zoom' },
      { '<leader>.',       function() Snacks.scratch() end,                 desc = 'Toggle Scratch Buffer' },
      { '<leader>S',       function() Snacks.scratch.select() end,          desc = 'Select Scratch Buffer' },
      { 'gd',              function() Snacks.bufdelete() end,               desc = 'Delete Buffer' },
      { '<leader>cR',      function() Snacks.rename.rename_file() end,      desc = 'Rename File' },
      { '<leader>gB',      function() Snacks.gitbrowse() end,               desc = 'Git Browse',                  mode = { 'n', 'v' } },
      { '<leader>gb',      function() Snacks.git.blame_line() end,          desc = 'Git Blame Line' },
      { '<leader>gf',      function() Snacks.lazygit.log_file() end,        desc = 'Lazygit Current File History' },
      { '<leader>gg',      function() Snacks.lazygit() end,                 desc = 'Lazygit' },
      { '<leader>gl',      function() Snacks.lazygit.log() end,             desc = 'Lazygit Log (cwd)' },
      { '<leader>un',      function() Snacks.notifier.hide() end,           desc = 'Dismiss All Notifications' },
      { '<c-/>',           function() Snacks.terminal() end,                desc = 'Toggle Terminal' },
      { '<c-_>',           function() Snacks.terminal() end,                desc = 'which_key_ignore' },
      { ']]',              function() Snacks.words.jump(vim.v.count1) end,  desc = 'Next Reference',              mode = { 'n', 't' } },
      { '[[',              function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference',              mode = { 'n', 't' } },
      {
        '<leader>N',
        desc = 'Neovim News',
        function()
          Snacks.win {
            file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = 'yes',
              statuscolumn = ' ',
              conceallevel = 3,
            },
          }
        end,
      },
    },
    -- init = function()
    --   vim.api.nvim_create_autocmd('User', {
    --     pattern = 'VeryLazy',
    --     callback = function()
    --       -- Setup some globals for debugging (lazy-loaded)
    --       _G.dd = function(...) Snacks.debug.inspect(...) end
    --       _G.bt = function() Snacks.debug.backtrace() end
    --       vim.print = _G.dd -- Override print to use snacks for `:=` command
    --
    --       -- Create some toggle mappings
    --       Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
    --       Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
    --       Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
    --       Snacks.toggle.diagnostics():map '<leader>ud'
    --       Snacks.toggle.line_number():map '<leader>ul'
    --       Snacks.toggle
    --           .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    --           :map '<leader>uc'
    --       Snacks.toggle.treesitter():map '<leader>uT'
    --       Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
    --       Snacks.toggle.inlay_hints():map '<leader>uh'
    --       Snacks.toggle.indent():map '<leader>ug'
    --       Snacks.toggle.dim():map '<leader>uD'
    --     end,
    --   })
    -- end,
  },
  -- Lua
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    },
  },
}
