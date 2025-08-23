-- 设置lazy的安装位置
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- lazy不存在则重新下载
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
-- 将lazy的安装路径添加到runtimepath，以供nvim可以require到lazy
vim.opt.rtp:prepend(lazypath)

-- 请求lazy的setup方法启动lazy
require("lazy").setup({
  spec = { -- 多维table
    -- 导入 plugins 模块，读取`../plugins/`文件夹中的配置文件
    -- `plugins`文件夹下的文件名无须与实际插件名一致
    { import = "plugins" },
  },
  -- install = { colorscheme = { "tokyonight" } },
})

