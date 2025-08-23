-- buffer状态栏
return {
  "akinsho/bufferline.nvim", -- buffer状态栏
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- 开启图标
  opts = {
    options = {
      -- 显示lsp错误数量
      diagnostics = "nvim_lsp",
      -- 设置buffer上显示的内容
      diagnostics_indicator = function (_, _, diagnostics_dict, _)
        local indicator = " "
        for level, number in pairs(diagnostics_dict) do
          local symbol
          if level == "error" then
            symbol = " "
          elseif level == "warning" then
            symbol = " "
          else
            symbol = " "
          end
          indicator = indicator .. number .. symbol
        end
        return indicator
      end
    },
  },
  -- 设置bufferline快捷键
  keys = {
    { "<S-j>", ":BufferLineCyclePrev<CR>", silent = true },
    { "<S-k>", ":BufferLineCycleNext<CR>", silent = true },
    -- { "<leader>bd", ":bdelete<CR>", silent = true },
    -- 使用snack的bufdelete模块，使删除buffer时不影响windows布局
    { "<leader>bd", function() Snacks.bufdelete.delete() end, silent = true },
    { "<leader>bo", ":BufferLineCloseOthers<CR>", silent = true },
    { "<leader>bp", ":BufferLinePick<CR>", silent = true },
    { "<leader>bc", ":BufferLinePickClose<CR>", silent = true },
    { "<leader>bs", ":buffers<CR>", silent = true },
    { "<leader>b1", ":buffer 1<CR>", silent = true },
    { "<leader>b2", ":buffer 2<CR>", silent = true },
    { "<leader>b3", ":buffer 3<CR>", silent = true },
    { "<leader>b4", ":buffer 4<CR>", silent = true },
    { "<leader>b5", ":buffer 5<CR>", silent = true },
    { "<leader>b6", ":buffer 6<CR>", silent = true },
    { "<leader>b7", ":buffer 7<CR>", silent = true },
    { "<leader>b8", ":buffer 8<CR>", silent = true },
    { "<leader>b9", ":buffer 9<CR>", silent = true }, },
  lazy = false,
}
