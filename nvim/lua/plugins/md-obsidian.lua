-- 自动补全
-- https://cmp.saghen.dev/
return {
  "saghen/blink.cmp",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "L3MON4D3/LuaSnip",
    "saghen/blink.compat",
    "epwalsh/obsidian.nvim",
  },
  opts = {
    completion = {
      documentation = {
        auto_show = true,
      },
    },
    keymap = {
      preset = "super-tab",
    },
    sources = {
      default = {
        "obsidian",
        "obsidian_new",
        "obsidian_tags",
        "path",
        "snippets",
        "buffer",
        "lsp",
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
      sources = function()
        local cmd_type = vim.fn.getcmdtype()
        if cmd_type == "/" or cmd_type == "?" then
          return { "buffer" }
        end
        if cmd_type == ":" then
          return { "cmdline" }
        end
        return {}
      end,
      keymap = {
        preset = "super-tab",
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
  },
}
