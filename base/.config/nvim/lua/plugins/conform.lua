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
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      javascript = { 'prettier', 'prettierd' },
      json = { 'prettier', 'prettierd' },
      jsonc = { 'prettier', 'prettierd' },
      typescriptreact = { 'prettier', 'prettierd' },
      typescript = { 'prettier', 'prettierd' },
      sql = { 'prettier' },
      yaml = { 'yamlfix' },
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { '-i', '2' },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
