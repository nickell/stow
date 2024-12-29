return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    { 'nvim-neotest/nvim-nio', tag = 'v1.9.0' },
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'marilari88/neotest-vitest',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-vitest',
      },
    }
  end,
  keys = {
    {
      '<leader>ts',
      function() require('neotest').summary.toggle() end,
      'Open test summary',
    },
    {
      '<leader>tt',
      function() require('neotest').output.open { auto_close = true, quiet = true } end,
      'Open test output',
    },
    {
      '<leader>tr',
      function() require('neotest').run.run() end,
      'Run tests',
    },
    {
      '<leader>tw',
      function() require('neotest').watch.toggle() end,
      'Watch tests',
    },
    {
      '<leader>to',
      '<cmd>:AV<cr>',
      'Alternative test output?',
    },
  },
}
