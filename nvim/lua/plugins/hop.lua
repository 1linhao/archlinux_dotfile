-- 光标跳转
return {
    "smoka7/hop.nvim", -- 光标跳转
    opts = {
        -- hint_position = 3, -- 设置跳转到word的末尾
        hint_position = 1, -- 设置跳转到word的开头
    },
    keys = {
        { "<leader>hp", "<Cmd>HopWord<CR>", desc = "hop word", silent = true },
    },
}

