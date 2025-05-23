local function map(mode, key, command, options)
  if options == nil then options = {} end
  options = vim.tbl_extend('error', options, { silent = true })
  vim.keymap.set(mode, key, command, options)
end

local function nmap(key, command, options) map('n', key, command, options) end

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.completeopt = 'menuone,noselect,preview'
map('i', '<cr>', function()
  if vim.fn.pumvisible() == 1 then return '<c-y>' end
  return '<cr>'
end, { expr = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method 'textDocument/completion' then
      local chars = {}
      for i = 32, 126 do
        table.insert(chars, string.char(i))
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    if
        not client:supports_method 'textDocument/willSaveWaitUntil'
        and client:supports_method 'textDocument/formatting'
    then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
        buffer = args.buf,
        callback = function()
          if client.name == 'ts_ls' then
            ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
            vim.lsp.buf.code_action { context = { only = { 'source.organizeImports.ts' } }, apply = true }
          end
          vim.lsp.buf.format {
            filter = function(c) return c.name ~= "ts_ls" end,
            bufnr = args.buf,
            id = client.id,
            timeout_ms = 1000,
          }
        end,
      })
    end

    if client:supports_method 'textDocument/foldingRange' then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    local _opts = { buffer = args.buf }
    nmap('<Leader>lr', vim.lsp.buf.rename, _opts)
    nmap('<Leader>lca', vim.lsp.buf.code_action, _opts)

    if client.name == 'ts_ls' then
      nmap(
        '<Leader>tto',
        ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
        function() vim.lsp.buf.code_action { context = { only = { 'source.organizeImports.ts' } }, apply = true } end,
        _opts
      )
    end
  end,
})

return {
  {
    'ervandew/supertab',
    config = function() vim.g.SuperTabDefaultCompletionType = '<c-n>' end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require 'lspconfig'
      vim.lsp.config('denols', {
        root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
      })

      vim.lsp.config('yamlls', {
        settings = {
          yaml = { customTags = { '!Ref', '!GetAtt' } },
          redhat = {
            telemetry = {
              enabled = false,
            },
          },
        },
        schemas = {
          ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        },
      })
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'cssls',
        'denols',
        'dockerls',
        'eslint',
        'graphql',
        'html',
        'jsonls',
        'lua_ls',
        'marksman',
        'pyright',
        'tailwindcss',
        'ts_ls',
        'vimls',
        'yamlls',
      },
    },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'neovim/nvim-lspconfig',
    },
  },
}
