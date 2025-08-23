-- 主题插件
return {
  -- 插件由github仓库链接去掉`https://github.com/`后得到
  'folke/tokyonight.nvim', -- 主题插件
  -- 配置插件属性的配置
  -- 插件的属性可以在仓库的README文档中找到
  opts = {
    style = "moon",
  },
  -- lazy默认会对插件执行`require("<plugin-name>").setop(opts)`操作
  -- config函数可以手动接管上面的操作
  -- config第一个参数基本没有作用，用`_`代替，第二个参数为`opts`
  config = function (_, opts)
    -- 执行lazy的默认操作
    require("tokyonight").setup(opts)
    -- 调用api: vim.cmd，执行neovim命令
    vim.cmd("colorscheme tokyonight")
  end,
}
