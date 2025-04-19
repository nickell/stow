return {
  {
    'michaelb/sniprun',
    branch = 'master',

    build = 'sh install.sh',

    config = function()
      require('sniprun').setup {
        interpreter_options = {
          TypeScript_original = {
            interpreter = 'tsx',
          },
        },
      }
    end,
  },
}
