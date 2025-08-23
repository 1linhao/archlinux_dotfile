-- 将代码抽象成抽象语法树（abstract syntax tree, AST）
-- treesitter: 把代码内容抽象为AST
-- nvim-treesitter: 在neovim中使用treesitter
-- 代码高亮
return {
  "nvim-treesitter/nvim-treesitter",
  -- lazy无法识别nvim-treesitter setup的模块名称，需要手动设置
  main = "nvim-treesitter.configs",
  branch = "master", -- 指定版本，详见neovim入门教程附录(https://shaobin-jiang.github.io/blog/posts/neovim-beginner-guide/update/)
  event = "VeryLazy",
  opts = {
    -- 指定安装哪些parser
    ensure_installed = { "markdown", "lua", "bash", "json", "yaml", "xml", "html", "c", "java", "qmljs" },
    -- 开启代码高亮
    highlight = { enable = true },
    fold = { enable = true }
  },
}
