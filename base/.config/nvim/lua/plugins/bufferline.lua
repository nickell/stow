local function get_file_representation(path)
  local relative_path = vim.fn.fnamemodify(path, ':.')
  local basename = vim.fn.fnamemodify(path, ':t')

  if relative_path:match '^[^/]+$' then
    -- If the file is directly in the cwd, return the basename.
    return basename
  else
    -- If not, return the first letter of the directory + the basename.
    local directory = relative_path:match '^([^/]+)/'
    if directory == nil or directory == '' then
      return basename
    else
      return string.sub(directory, 1, 1) .. '/' .. basename
    end
  end
end

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  config = function()
    local bufferline = require 'bufferline'
    bufferline.setup {
      options = {
        separator_style = 'slant',
        sort_by = function(buffer_a, buffer_b)
          local modified_a = vim.fn.getftime(buffer_a.path)
          local modified_b = vim.fn.getftime(buffer_b.path)
          return modified_a > modified_b
        end,
        name_formatter = function(buf) -- buf contains:
          -- return buf.name
          return get_file_representation(buf.path)
          -- name                | str        | the basename of the active file
          -- path                | str        | the full path of the active file
          -- bufnr               | int        | the number of the active buffer
          -- buffers (tabs only) | table(int) | the numbers of the buffers in the tab
          -- tabnr (tabs only)   | int        | the "handle" of the tab, can be converted to its ordinal number using: `vim.api.nvim_tabpage_get_number(buf.tabnr)`
        end,
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            highlight = 'Directory',
            separator = true, -- use a "true" to enable the default, or set your own character
          },
        },
      },
    }
  end,
}
