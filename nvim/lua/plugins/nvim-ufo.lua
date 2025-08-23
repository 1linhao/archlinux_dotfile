-- 折叠插件
return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "BufReadPost",
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      return { "treesitter", "indent" }
    end,
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (" 󰁂 %d lines"):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local chunkHl = chunk[2]
          table.insert(newVirtText, { chunkText, chunkHl })
          curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, "MoreMsg" })
      return newVirtText
    end,
  },
  config = function(_, opts)
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
    vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
    require("ufo").setup(opts)
  end,
  keys = {
    { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open fold under cursor" },
    { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close fold under cursor" },
    { "z1", ":set foldlevel=1<CR>", desc = "Set foldlevel to 1" },
    { "z2", ":set foldlevel=2<CR>", desc = "Set foldlevel to 2" },
    { "z3", ":set foldlevel=3<CR>", desc = "Set foldlevel to 3" },
    { "z9", ":set foldlevel=99<CR>", desc = "Set foldlevel to 99" },
  },
}
