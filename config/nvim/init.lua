vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.fn.mkdir("/tmp/nvim_undo", "p")
vim.opt.undodir = "/tmp/nvim_undo"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local url_repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git", "clone", "--filter=blob:none", url_repo, "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    -- Arsenal de Lenguajes (Web + Backend)
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.python" },

    -- Linter y Formateadores
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.formatting.black" },

    -- Utilidades Tácticas y de Interfaz (Añadidas)
    { import = "lazyvim.plugins.extras.coding.yanky" },
    { import = "lazyvim.plugins.extras.editor.mini-move" },
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.coding.mini-snippets" },
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
  },
  defaults = {
    lazy = false,
    version = false, 
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true }, 
  git = { timeout = 600 },
  concurrency = 4, 
})