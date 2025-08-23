-- 自动补全
-- https://cmp.saghen.dev/
return {
  "saghen/blink.cmp",
  version = "*", -- 设置version后才可以下载额外的一些资源
  event = "VeryLazy",
  dependencies = {
    -- 添加snipper（代码模板）
    'rafamadriz/friendly-snippets', -- 常用的代码模板，如idea中的psvm，sout等
    "L3MON4D3/LuaSnip",  -- lua代码模板
    "saghen/blink.compat",  -- nvim-cmp兼容层
    "epwalsh/obsidian.nvim",  -- obsidian.nvim代码模板
  },
  opts = {
    sources = {
      -- 代码补全来源
      -- path:输入路径时补全
      -- snippets:从代码模板补全
      -- buffer:从当前buffer中选取内容补全
      -- lsp:基于lsp的代码补全
      default = { 
        "obsidian",
        "obsidian_new",
        "obsidian_tags",
        "path",
        "snippets",
        "buffer",
        "lsp"
      },
      providers = {
        obsidian = { name = "obsidian", module = "blink.compat.source" },
        obsidian_new = { name = "obsidian_new", module = "blink.compat.source" },
        obsidian_tags = { name = "obsidian_tags", module = "blink.compat.source" },
        lsp = { name = "lsp" },
        path = { name = "path" },
        snippets = { name = "snippets" },
        buffer = { name = "buffer" },
      },
    },
    cmdline = { 
      -- 命令行补全
      sources = function()
        local cmd_type = vim.fn.getcmdtype()
          if cmd_type == "/" or cmd_type == "?" then -- 查找时使用buffer源
            return { "buffer" }
          end
          if cmd_type == ":" then -- 输入命令时使用cmdline源
            return { "cmdline" }
          end
          return {}
      end,
      keymap = {
        -- <C-e>关闭补全窗口
        -- <C-p/n>切换到上/下一个补全项
        -- <Tap>确定当前选中的补全
        preset = "super-tab",
      },
      completion = {
        menu = {
          -- 光标移动到项目上时，自动显示帮助文档
          auto_show = true,
        },
      },
    },
  }
}

