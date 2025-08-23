vim.opt.number = true -- 显示行数
vim.opt.relativenumber = true -- 相对行数

vim.opt.cursorline = true -- 高亮当前行
-- vim.opt.colorcolumn = "80" -- 高亮第80列

vim.opt.expandtab = true -- 将tap替换为空格
vim.opt.tabstop = 2 -- 一个tap对应2个空格 
-- neovim默认开启了smarttab
-- smarttab功能之一：在开头按下tap时，添加shiftwidth个空格
-- shiftwidth默认为8
vim.opt.shiftwidth = 0 -- 将shiftwidth设置为和tabstop相同的值

vim.opt.autoread = true -- 自动重载文件

vim.opt.splitbelow = true -- 在下方打开新窗口
vim.opt.splitright = true -- 在右方打开新窗口

-- 如果查找的内容中不存在大写，则大小写不敏感
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 不要在查找之后继续高亮匹配结果
vim.opt.hlsearch = false

-- 不使用neovim自带的状态栏
vim.opt.showmode = false

-- 自增自减对字母生效<C-a>
vim.opt.nrformats = "bin,hex,alpha"

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*/waybar/config",
  callback = function()
    vim.bo.filetype = "json"
  end,
})

