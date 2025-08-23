-- lsp包管理器
return {
  "mason-org/mason.nvim",
  event = "VeryLazy",
  dependencies = {
    -- 为lsp提供配置
    "neovim/nvim-lspconfig",
    -- 将`mason`中的lsp名字转换成`nvim-lspconfig`中对应的名字
    "mason-org/mason-lspconfig.nvim",
  },
  opts = {},
  config = function (_, opts)
    require("mason").setup(opts)

    local registry = require("mason-registry")

    -- 启动lsp的方法
    local function setup(name,config)
      -- 判断lsp是否已安装
      local success, package = pcall(registry.get_package, name)
      if success and not package:is_installed() then
        package:install()
      end

      -- 将`mason`中的lsp名字转换成`nvim-lspconfig`中对应的名字
      local lsp = require("mason-lspconfig").get_mappings().package_to_lspconfig[name]
      -- 让blick.com获取neovim的capabilities（支持的功能）
      -- 可以减少lsp返回的一些内容，降低延迟
      -- 获得一些有用的功能
      config.capabilities = require("blink.cmp").get_lsp_capabilities()

      -- 取消lsp的格式化功能，格式化由none-ls实现
      -- on_attach函数会在lsp被附加到buffer时执行
      config.on_attach = function (client, bufnr)
        -- 规定server_capabilities应该支持什么功能
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        -- 添加 gd 映射用于跳转
        if lsp == "markdown_oxide" then
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
        end
      end

      -- 为 markdown-oxide 添加特定配置
      if lsp == "markdown_oxide" then
        config.settings = {
          workspace = {
            path = "~/Public/share/obsidian",  -- 笔记库路径
          },
        }
      end

      -- 启动lsp，将lsp附加到buffer上
      vim.lsp.config(lsp, config)
    end

    -- lsp列表
    -- 可从mason面板中查找相应语言的lsp名字，如lua的`lua-language-server`
    -- 启动lsp时可以进行一些配置
    local servers = {
      ["lua-language-server"] = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim", "builtin", "Snacks" },
          },
        }
      }
      },
      pyright = {},
      ["html-lsp"] = {},
      ["css-lsp"] = {},
      ["typescript-language-server"] = {},
      ["emmet-ls"] = {},
      ["markdown-oxide"] = {},
      ["json-lsp"] = {},
      qmlls = {},
    }

    -- 通过循环启动lsp
    for server, config in pairs(servers) do
      setup(server, config)
    end

    -- 附加lsp到buffer的操作是通过`ft`事件触发来实现的
    -- `nvim-lspconfig`在mason加载后才会启动
    -- mason因为设置了懒启动，启动时机在`ft`事件之后
    -- 所以在nvim刚打开，为buffer附加`lsp`时，`nvim-lspconfig`并没有启动
    -- 因此需要在mason加载后再执行一遍为buffer附加lsp的操作
    -- `ft`事件在每次打开文件时都会执行，因此需要添加判断条件决定附加lsp的命令是否执行
    -- 检查当前文件类型是否在支持的 LSP 列表中
    local function is_supported_filetype()
      local filetype = vim.bo.filetype
      local supported_filetypes = { "lua", "python", "html", "css", "javascript", "typescript", "markdown", "config", "json" }
      return vim.tbl_contains(supported_filetypes, filetype)
    end
    -- 仅当有文件打开且文件类型受支持时启动 LSP
    if vim.fn.argc() > 0 and is_supported_filetype() then
      vim.cmd("LspStart")
    end

    -- 配置neovim对lsp返回的diagnostic的处理
    vim.diagnostic.config(
      {
      -- 在插入模式开启warning
      update_in_insert = true,
      -- 显示warning文字提示
      virtual_text = true
      }
    )
  end,
}
