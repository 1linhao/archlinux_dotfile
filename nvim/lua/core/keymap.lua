vim.g.mapleader = " "

local keymap = vim.keymap

-- 插入模式
keymap.set({"i", "c"}, "j;", "<ESC>")
vim.api.nvim_set_keymap('i', '<C-S-v>', '<Cmd>set paste<CR><C-R>+<Cmd>set nopaste<CR>', { noremap = true })
-- vim.api.nvim_set_keymap('v', '<C-S-c>', '<Cmd>set paste<CR><C-R>+<Cmd>set nopaste<CR>', { noremap = true })

-- 视觉模式
-- 移动选中行
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- 正常模式
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 垂直新增窗口
keymap.set("n", "<leader>sh", "<C-w>s") -- 水平新增窗口
keymap.set("n", "<C-h>", "<C-w>h") -- 跳转到左窗口
keymap.set("n", "<C-j>", "<C-w>j") -- 跳转到下窗口
keymap.set("n", "<C-k>", "<C-w>k") -- 跳转到上窗口
keymap.set("n", "<C-l>", "<C-w>l") -- 跳转到右窗口
keymap.set("n", "<C-j>", "<C-w>j") -- 跳转到左窗口
keymap.set("n", "<C-c>", "<C-w>c") -- 关闭当前窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- lazy
keymap.set("n", "<leader>L", "<cmd>Lazy<CR>")

-- workpath
keymap.set("n", "<leader>sh", "<cmd>cd %:p:h<CR>")

-- 注释
-- 在行尾添加注释
local function comment_end()
    local line = vim.api.nvim_get_current_line() -- 当前行的内容
    local row = vim.api.nvim_win_get_cursor(0)[1] -- 当前所在的行数，从1开始

    local commentstring = vim.bo.commentstring -- 获取 commentstring
    local comment = commentstring:gsub("%%s", "") -- 将 commentstring 中的 %s 替换掉; %% 是对 % 转义
    local index = commentstring:find "%%s" -- 获取光标插入相对于注释的位置（从1开始），这个值相当于 %s 前面的字符数 + 1

    if line:find "%S" then -- 查找第一个非空字符
        comment = " " .. comment
        index = index + 1 -- 相当于 commentstring 开头被添加了一位
    end

    -- 0 代表当前 buffer
    -- 这里的行数是从 0 开始的
    -- 将第 [start, end -1] 行的内容替换掉
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line .. comment })

    -- 0 代表当前 window
    -- 这里的第二个参数是一个table，由 row 和 col 组成，其中 row 从 1 开始，col 从 0 开始
    -- 当我们的光标放在一行的第一位，col 为 0，所以 col 的值等于光标前面字符的数量
    -- 我们现在要把光标放在 %s 再往前一位，例如如果是 // %s，则把光标放在 //■%s 的位置
    -- 这样我们后续进入 insert mode 直接按 a 键就可以
    -- 至于为什么不是放在 %s 处然后按 i 键，别忘了我们把 %s 替换掉了，最终的字符出在 %s 前面就结束了
    -- 所以现在光标前面字符包括：line 的全部内容 + %s 前面的字符数 - 1 = #line + index - 1 - 1 
    vim.api.nvim_win_set_cursor(0, { row, #line + index - 2 })

    vim.api.nvim_feedkeys("a", "n", false)
end

-- 在上一下添加注释
local function comment_above()
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local commentstring = vim.bo.commentstring
    local comment = commentstring:gsub("%%s", "")
    local index = commentstring:find "%%s"

    -- 获取当前行的缩进
    -- 查找第一个非空字符，减 1 就是空白字符数
    -- 如果没有非空字符，则空白字符数等于当前行的字符数
    local blank_chars = (line:find "%S" or #line + 1) - 1
    local blank = line:sub(1, blank_chars)

    -- 可以理解是将第 [start, end - 1] 行的内容替换掉；如果 start 和 end 相等，则向 start 上面添加一行
    -- 也就是在当前行插入换行符，当前行变成第 row 行（行数从 0 开始），要写入的行为第 row - 1 行
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, true, { blank .. comment })
    vim.api.nvim_win_set_cursor(0, { row, #blank + index - 2 })
    vim.api.nvim_feedkeys("a", "n", false)
end

-- 在下一行添加注释
local function comment_below()
    local row = vim.api.nvim_win_get_cursor(0)[1]

    -- 如果当前行为最后一行，则仍然取用当前行的缩进
    local total_lines = vim.api.nvim_buf_line_count(0)
    local line
    if row == total_lines then
        line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    else
        line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    end

    local commentstring = vim.bo.commentstring
    local comment = commentstring:gsub("%%s", "")
    local index = commentstring:find "%%s"

    local blank_chars = (line:find "%S" or #line + 1) - 1
    local blank = line:sub(1, blank_chars)

    vim.api.nvim_buf_set_lines(0, row, row, true, { blank .. comment })
    vim.api.nvim_win_set_cursor(0, { row + 1, #blank + index - 2 })

    vim.api.nvim_feedkeys("a", "n", false)
end

-- 为默认的gcc添加注释空白行的功能
local function comment_line()
    local line = vim.api.nvim_get_current_line()

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local commentstring = vim.bo.commentstring
    local comment = commentstring:gsub("%%s", "")
    local index = vim.bo.commentstring:find "%%s"

    if not line:find "%S" then
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line .. comment })
        vim.api.nvim_win_set_cursor(0, { row, #line + index - 1 })
    else
        require("vim._comment").toggle_lines(row, row, { row, 0 })
    end
end

vim.keymap.set("n", "gcc", comment_line)

vim.keymap.set("n", "gco", comment_below)

vim.keymap.set("n", "gcO", comment_above)

vim.keymap.set("n", "gcA", comment_end)

