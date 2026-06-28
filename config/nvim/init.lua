vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.fn.mkdir("/tmp/nvim_undo", "p")
vim.opt.undodir = "/tmp/nvim_undo"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local url_repo = "https://github.com/" .. "folke/lazy.nvim.git"
  vim.fn.system({
    "git", "clone", "--filter=blob:none", url_repo, "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  },
  defaults = {
    lazy = false,
    version = false, 
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, 
  
  git = { timeout = 600 },
  concurrency = 6, 
})