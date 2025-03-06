return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require 'nvim-treesitter.configs'

      configs.setup {
        highlight = { enable = true },
        indent = { enable = true, disable = { 'yaml' } },
        ensure_installed = {
          'bash',
          'c',
          'comment',
          'css',
          'diff',
          'dockerfile',
          'git_rebase',
          'gitignore',
          'graphql',
          'html',
          'http',
          'javascript',
          'jsdoc',
          'json',
          'jsonc',
          'lua',
          'luadoc',
          'luap',
          'make',
          'markdown',
          'markdown_inline',
          'nginx',
          'prisma',
          'python',
          'query',
          'regex',
          'sql',
          'toml',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'yaml',
        },
      }
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup {
        opts = { enable_close_on_slash = true },
      }
    end,
  },
}
