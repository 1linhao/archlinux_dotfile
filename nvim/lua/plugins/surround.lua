-- 基于motion添加包裹符号
return {
  -- 用法：ys+motion+<包裹符号>/t
  -- 例：
  -- 添加包裹符号:
  -- n mode: ysiw(  ysiwt    
  -- v mode: S"
  -- 删除包裹符号: ds"
  -- 替换包裹符号: cs"(
  "kylechui/nvim-surround",
  event = "VeryLazy", -- 懒加载
  opts = {},
}
