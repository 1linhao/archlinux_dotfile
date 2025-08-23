-- markdown渲染
return {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' }, -- 在markdown文件上加载此插件
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        -- position = 'inline', -- 取消标题缩进
        sign = false, -- 取消标题标识
        -- icons = {'󰼏 ', '󰎨 '}, -- 修改标题图标
      },
      render_modes = true, -- 在所有模式下获得渲染视图
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
      sign = {
        enabled = false -- 关闭所有标识
      },
      code = {
        style = 'full',
        -- 代码块左边距
        left_pad = 2,
        border = 'full',
      },
    },
}
