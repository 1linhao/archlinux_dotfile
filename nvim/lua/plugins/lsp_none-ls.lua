-- 代码格式化
-- none-ls为需要的buffer启动一个lsp，然后使用相应的formatter格式化代码
-- none-ls通过调用外部工具进行格式化，因此自定义格式化需要需要根据不同工具对其进行配置
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "mason-org/mason.nvim",
    "nvim-lua/plenary.nvim",  -- 优化或添加lua标准库的一些功能
  },
  event = "VeryLazy",
  config = function()
    -- 安装formatter
    local registry = require("mason-registry")
    local function install(name)
      local success, package = pcall(registry.get_package, name)
      if success and not package:is_installed() then
        package:install()
      end
    end
    install("stylua")

    -- 设置source
    -- none-ls fork from null-ls，为了兼容性，none-ls沿用了require("null-ls")
    -- 由于sources中的值来自null-ls，因此需要在require("null-ls")后才能设置sources
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
      },
    })
  end,

  -- 设置快捷键
  keys = {
    {
      "<leader>lf",
      function()
        vim.lsp.buf.format()
      end,
      desc = "为当前的buffer格式化代码",
    }
  },
}
