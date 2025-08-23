require("simple-mtpfs"):setup({
  mount_point = os.getenv("HOME" .. "/Android"),
  mount_opts = { "debug", "max_read=1000" },
})

-- ~/.config/yazi/init.lua
require("relative-motions"):setup({ show_numbers="relative", show_motion = true, enter_mode ="first" })

-- 自定义目录规则
require("folder-rules"):setup()
