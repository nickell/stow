local function map(mode, key, command, options)
  if options == nil then options = {} end
  options = vim.tbl_extend('error', options, { silent = true })
  vim.keymap.set(mode, key, command, options)
end

local function nmap(key, command, options) map('n', key, command, options) end

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.completeopt = 'menuone,noselect,preview'
vim.o.winborder = 'rounded'

local function completion_mappings(client, bufnr)
  ---Utility for keymap creation.
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts string|table
  ---@param mode? string|string[]
  local function keymap(lhs, rhs, opts, mode)
    opts = type(opts) == 'string' and { desc = opts }
        or vim.tbl_extend('error', opts --[[@as table]], { buffer = bufnr })
    mode = mode or 'n'
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  ---For replacing certain <C-x>... keymaps.
  ---@param keys string
  local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
  end

  ---Is the completion menu open?
  local function pumvisible()
    return tonumber(vim.fn.pumvisible()) ~= 0
  end

  -- Enable completion and configure keybindings.
  if client.supports_method('textDocument/completion') then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

    -- Use enter to accept completions.
    keymap('<cr>', function()
      return pumvisible() and '<C-y>' or '<cr>'
    end, { expr = true }, 'i')

    -- Use slash to dismiss the completion menu.
    keymap('/', function()
      return pumvisible() and '<C-e>' or '/'
    end, { expr = true }, 'i')

    -- Use <C-n> to navigate to the next completion or:
    -- - Trigger LSP completion.
    -- - If there's no one, fallback to vanilla omnifunc.
    keymap('<C-n>', function()
      if pumvisible() then
        feedkeys '<C-n>'
      else
        if next(vim.lsp.get_clients { bufnr = 0 }) then
          vim.lsp.completion.trigger()
        else
          if vim.bo.omnifunc == '' then
            feedkeys '<C-x><C-n>'
          else
            feedkeys '<C-x><C-o>'
          end
        end
      end
    end, 'Trigger/select next completion', 'i')

    -- Buffer completions.
    keymap('<C-u>', '<C-x><C-n>', { desc = 'Buffer completions' }, 'i')

    -- Use <Tab> to navigate between snippet tabstops or select the next completion.
    -- Do something similar with <S-Tab>.
    keymap('<Tab>', function()
      if pumvisible() then
        feedkeys '<C-n>'
      elseif vim.snippet.active { direction = 1 } then
        vim.snippet.jump(1)
      else
        feedkeys '<Tab>'
      end
    end, {}, { 'i', 's' })
    keymap('<S-Tab>', function()
      if pumvisible() then
        feedkeys '<C-p>'
      elseif vim.snippet.active { direction = -1 } then
        vim.snippet.jump(-1)
      else
        feedkeys '<S-Tab>'
      end
    end, {}, { 'i', 's' })

    -- Inside a snippet, use backspace to remove the placeholder.
    keymap('<BS>', '<C-o>s', {}, 's')
  end
end

local function lsp_mappings(buffer)
  nmap(
    '<Leader>tto',
    ---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
    function() vim.lsp.buf.code_action { context = { only = { 'source.organizeImports.ts' } }, apply = true } end,
    { buffer = buffer }
  )
end

local function lsp_completion(client, args)
  if client:supports_method 'textDocument/completion' then
    local chars = {}
    for i = 32, 126 do
      table.insert(chars, string.char(i))
    end
    client.server_capabilities.completionProvider.triggerCharacters = chars
    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    completion_mappings(client, args.buf)
  end
end

local function lsp_folding(client)
  if client:supports_method 'textDocument/foldingRange' then
    local win = vim.api.nvim_get_current_win()
    vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    lsp_completion(client, args)
    -- Using conform instead
    -- lsp_formatting(client, args)
    lsp_folding(client)
    lsp_mappings(args.buf)
  end,
})

return {

  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        -- 'cssls',
        -- 'denols',
        -- 'dockerls',
        -- 'eslint',
        -- 'graphql',
        -- 'html',
        -- 'jsonls',
        'lua_ls',
        -- 'marksman',
        -- 'pyright',
        -- 'tailwindcss',
        'ts_ls',
        -- 'vimls',
        -- 'yamlls',
      },
    },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      {
        'neovim/nvim-lspconfig',
        -- config = function()
        --   -- local lspconfig = require 'lspconfig'
        --   -- vim.lsp.config('denols', {
        --   --   root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
        --   -- })
        --
        --   -- vim.lsp.config('yamlls', {
        --   --   settings = {
        --   --     yaml = { customTags = { '!Ref', '!GetAtt' } },
        --   --     redhat = {
        --   --       telemetry = {
        --   --         enabled = false,
        --   --       },
        --   --     },
        --   --   },
        --   --   schemas = {
        --   --     ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
        --   --   },
        --   -- })
        -- end,
        dependencies = {
          {
            'ervandew/supertab',
            config = function() vim.g.SuperTabDefaultCompletionType = '<c-n>' end,
          },
          {
            'windwp/nvim-autopairs',
            event = { 'InsertEnter' },
            -- dependencies = { 'hrsh7th/nvim-cmp' },
            config = function()
              -- import nvim-autopairs
              local autopairs = require 'nvim-autopairs'

              -- configure autopairs
              autopairs.setup {
                map_cr = false,
                check_ts = true,                      -- enable treesitter
                ts_config = {
                  lua = { 'string' },                 -- don't add pairs in lua string treesitter nodes
                  javascript = { 'template_string' }, -- don't add pairs in javscript template_string treesitter nodes
                },
              }

              -- For inserting `(` after select function or method item
              -- local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
              -- local cmp = require 'cmp'
              -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
            end,
          }
        },
      },
    },
  },
}

-- local function lsp_formatting(client, args)
--   if
--       not client:supports_method 'textDocument/willSaveWaitUntil'
--       and client:supports_method 'textDocument/formatting'
--   then
--     vim.api.nvim_create_autocmd('BufWritePre', {
--       group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
--       buffer = args.buf,
--       callback = function()
--         vim.lsp.buf.format {
--           filter = function(c) return c.name ~= 'ts_ls' and c.name ~= 'eslint' end,
--           bufnr = args.buf,
--           id = client.id,
--           timeout_ms = 1000,
--         }
--       end,
--     })
--   end
-- end

-- grn in Normal mode maps to vim.lsp.buf.rename()
-- grr in Normal mode maps to vim.lsp.buf.references()
-- gri in Normal mode maps to vim.lsp.buf.implementation()
-- gO in Normal mode maps to vim.lsp.buf.document_symbol() (this is analogous to the gO mappings in help buffers and :Man page buffers to show a “table of contents”)
-- gra in Normal and Visual mode maps to vim.lsp.buf.code_action()
-- CTRL-S in Insert and Select mode maps to vim.lsp.buf.signature_help()
-- [d and ]d move between diagnostics in the current buffer ([D jumps to the first diagnostic, ]D jumps to the last)
--
-- [q, ]q, [Q, ]Q, [CTRL-Q, ]CTRL-Q navigate through the quickfix list
-- [l, ]l, [L, ]L, [CTRL-L, ]CTRL-L navigate through the location list
-- [t, ]t, [T, ]T, [CTRL-T, ]CTRL-T navigate through the tag matchlist
-- [a, ]a, [A, ]A navigate through the argument list
-- [b, ]b, [B, ]B navigate through the buffer list
-- [<Space>, ]<Space> add an empty line above and below the cursor
