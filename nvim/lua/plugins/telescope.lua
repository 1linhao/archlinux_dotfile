-- 模糊查找器
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim", -- 提高模糊搜索性能
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
        .. "cmake --build build --config Release && "
        .. "cmake --install build --prefix build",
    },
  },
  cmd = "Telescope",
  opts = {
    
    defaults = {
      layout_strategy = "vertical",  -- 使用垂直布局，便于阅读
      mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
          ["<CR>"] = require("telescope.actions").select_default,
          ["<C-c>"] = require("telescope.actions").close,
        },
      },
    },
    pickers = {
      obsidian = {
        prompt_title = "Obsidian Notes",  -- 自定义标题
        sorter = require("telescope.sorters").get_fuzzy_file(),  -- 模糊搜索
      },
    },

    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
  config = function(_, opts)
    local telescope = require "telescope"
      telescope.setup(opts)
      telescope.load_extension("fzf")
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope help tags" },

  }
}

