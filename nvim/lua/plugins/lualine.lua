-- 状态栏

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto", -- 自动切换配色
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    extensions = { "nvim-tree" }, -- 关闭对nvim-tree的lualine显示
    sections = {
      lualine_b = { "branch", "diff" },
      lualine_x = {
        "filesize",
        "encoding",
        "filetype",
        "lsp_status",
      },
    },
  },
}

