return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  event = {
    'BufReadPre /home/chad/Documents/notes/Notes/*.md',
    'BufNewFile /home/chad/Documents/notes/Notes/*.md',
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<c-cr>', '<cmd>ObsidianToggleCheckbox<cr>', mode = { 'n' }, 'Obsidian toggle checkbox' },
    { '<c-cr>', '<cmd>ObsidianToggleCheckbox<cr><esc>A', mode = { 'i' } },
    { '<leader>on', '<cmd>exe \'e Inbox/\'.strftime("%Y-%m-%d.md")<cr>' },
    { '<leader>oam', '<cmd>ObsidianTemplate Para Meeting Template.md<cr>' },
    { '<leader>orm', '<cmd>ObsidianTemplate Pro Meeting Template.md<cr>' },
    { '<leader>oz', '<cmd>ObsidianTemplate Pro Meeting Template.md<cr>' },
    { '<leader>ob', '<cmd>ObsidianBacklinks<cr>' },
  },
  opts = {
    templates = {
      folder = 'Templates',
      date_format = '%Y-%m-%d',
    },
    workspaces = {
      {
        name = 'personal',
        path = '/home/chad/Documents/notes/Notes',
      },
    },
    disable_frontmatter = true,
    ui = {
      checkboxes = {
        [' '] = { char = '☐', hl_group = 'ObsidianTodo' },
        ['x'] = { char = '', hl_group = 'ObsidianDone' },
      },
    },
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ''
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        -- suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
        suffix = title
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      -- return tostring(os.time()) .. '-' .. suffix
      return suffix
    end,
  },
  config = function(_, opts)
    vim.cmd [[
      augroup WrapLinesInObsidian
        autocmd BufReadPre,BufNewFile /home/chad/Documents/notes/Notes/*.md setlocal wrap linebreak
      augroup END
    ]]

    require('obsidian').setup(opts)
  end,
}
