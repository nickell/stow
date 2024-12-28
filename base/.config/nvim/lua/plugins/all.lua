return {
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy', config = true },
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    opts = {},
  },
  'christoomey/vim-sort-motion',
  'gianarb/vim-flux',
  { 'numToStr/Navigator.nvim', config = true },
}
