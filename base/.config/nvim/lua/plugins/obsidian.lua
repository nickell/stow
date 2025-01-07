-- Custom command to move the current file to a hardcoded directory
vim.api.nvim_create_user_command('MoveNoteToZet', function()
  -- Define the hardcoded directory (replace with your desired path)
  local hardcoded_path = '/home/chad/Documents/notes/Notes/zet'

  -- Get the current buffer and its file path
  local current_buffer = vim.api.nvim_get_current_buf()
  local source_file_path = vim.api.nvim_buf_get_name(current_buffer)

  -- Check if the buffer is associated with a file
  if source_file_path == '' then
    print 'Current buffer is not associated with a file.'
    return
  end

  -- Check if the buffer is writable
  local buftype = vim.api.nvim_buf_get_option(current_buffer, 'buftype')
  if buftype ~= '' then
    print 'Current buffer is not a normal file.'
    return
  end

  -- Save the file to avoid "No write since last change" error
  vim.cmd 'silent! write'

  -- Extract the file name from the source file path
  local file_name = vim.fn.fnamemodify(source_file_path, ':t')

  -- Construct the new file path
  local new_file_path = hardcoded_path .. '/' .. file_name

  -- Move the file using os.rename
  local success = os.rename(source_file_path, new_file_path)
  if success then
    print('Moved ' .. source_file_path .. ' to ' .. new_file_path)
    -- Update the buffer with the new file path
    vim.api.nvim_buf_set_name(current_buffer, new_file_path)
    -- Reload the buffer
    vim.cmd 'edit'
  else
    print 'Failed to move the file.'
  end
end, {})

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
    { '<c-cr>', '<cmd>ObsidianToggleCheckbox<cr>', mode = { 'n' }, desc = 'Obsidian - Toggle Checkbox' },
    { '<c-cr>', '<cmd>ObsidianToggleCheckbox<cr><esc>A', mode = { 'i' }, desc = 'Obsidian - Toggle Checkbox' },
    { '<leader>on', '<cmd>exe \'e Inbox/\'.strftime("%Y-%m-%d.md")<cr>', desc = 'Obsidian - New Note (Today)' },
    { '<leader>oam', '<cmd>ObsidianTemplate Para Meeting Template.md<cr>', desc = 'Obsidian - Para Meeting Template' },
    { '<leader>orm', '<cmd>ObsidianTemplate Pro Meeting Template.md<cr>', desc = 'Obsidian - Pro Meeting Template' },
    { '<leader>oz', '<cmd>MoveNoteToZet<cr>', desc = 'Obsidian - Move note to zet folder' },
    { '<leader>ob', '<cmd>ObsidianBacklinks<cr>', desc = 'Obsidian - Backlinks' },
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
    -- disable_frontmatter = true,
    note_frontmatter_func = function(note)
      -- Add the title of the note as an alias.
      if note.title then note:add_alias(note.title) end

      local out = { created = os.date '%Y-%m-%d' }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,
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
