return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>p',
      function() require('conform').format { async = true, lsp_fallback = true } end,
      desc = 'Format buffer',
    },
  },
  -- Everything in opts will be passed to setup()
  opts = {
    notify_on_error = false,
    -- Define your formatters
    formatters_by_ft = {
      graphql = { 'prettier' },
      javascript = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      sql = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      -- yaml = { 'yamlfix' },
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },
      prettier = {
        append_args = { '--ignore-path', 'null' },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
