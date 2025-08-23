-- 颜色预览
return {
  'norcalli/nvim-colorizer.lua',
  event = "VeryLazy",
  config = function (_, opts)
    require('colorizer').setup()
  end,

}
