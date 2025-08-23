-- 改善neovim内置的lsp体验
-- Finder: 查找器，高级lsp标志搜索界面
-- diagnostice: 诊断，在诊断间跳转并显示窗口
-- peek definition/type definition: 查看定义/类型定义
-- hover: 悬停，更美观的悬停操作
-- rename: 重命名，lsp重命名以及异步项目搜索替换功能
-- callhierarchy incoming/outgoing calls: 调用层次，查看传入传出的调用关系
-- lightbulb: 灯泡提示，类似vscode的灯泡图标，提示可能的代码操作
-- outline: 大纲视图，类似ide的符号轮廓展示
-- implement: 实现功能，轻松查看实现数量并快速跳转
-- float term: 浮动终端，一个简单的浮动终端
-- miscellaneous: 杂项设置，全局功能设置
-- 官方文档：https://nvimdev.github.io/lspsaga/ 
return {
    "nvimdev/lspsaga.nvim",
    cmd = "Lspsaga",
    opts = {
        finder = {
            keys = {
                -- 设置在查看一个变量的refence时，按哪个键跳转到引用处
                toggle_or_open = "<CR>",
            },
        },
        symbol_in_winbar = {
          enable = true, -- 启用 breadcrumbs，支持大纲
        }
    },
    keys = {
        { "<leader>lr", ":Lspsaga rename<CR>" }, -- 重命名
        { "<leader>lc", ":Lspsaga code_action<CR>" }, -- code action
        { "<leader>ld", ":Lspsaga definition<CR>" }, -- 跳转到定义
        { "<leader>lh", ":Lspsaga hover_doc<CR>" }, -- 查看文档
        { "<leader>lR", ":Lspsaga finder<CR>" }, -- 查看变量引用
        { "<leader>ln", ":Lspsaga diagnostic_jump_next<CR>" }, -- 跳转到下一个诊断
        { "<leader>lp", ":Lspsaga diagnostic_jump_prev<CR>" }, -- 跳转到上一个诊断
    }
}
