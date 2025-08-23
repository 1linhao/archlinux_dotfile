-- 显示代码上下文
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "VeryLazy",
  config = function()
    require("treesitter-context").setup({
      enable = true,
      max_lines = 0,
      min_window_height = 0,
      multiline_threshold = 20,
      mode = "cursor",
      zindex = 20,
    })
  end,
}
