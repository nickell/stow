return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local configs = require 'nvim-treesitter.configs'

      configs.setup {
        highlight = {
          enable = true,
          -- Disable slow treesitter highlight for large files
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
        },
        -- indent = { enable = true, disable = { 'yaml' } },
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
