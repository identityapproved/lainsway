return {
  -- remove Telescope in favor of fzf-lua
  { "nvim-telescope/telescope.nvim", enabled = false },
  { "nvim-telescope/telescope-fzf-native.nvim", enabled = false },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local fzf = require("fzf-lua")
      local theme_opts = {
        "--highlight-line",
        "--info=inline-right",
        "--ansi",
        "--layout=reverse",
        "--border=none",
        "--color=bg+:#283457",
        "--color=bg:#16161e",
        "--color=border:#27a1b9",
        "--color=fg:#c0caf5",
        "--color=gutter:#16161e",
        "--color=header:#ff9e64",
        "--color=hl+:#2ac3de",
        "--color=hl:#2ac3de",
        "--color=info:#545c7e",
        "--color=marker:#ff007c",
        "--color=pointer:#ff007c",
        "--color=prompt:#2ac3de",
        "--color=query:#c0caf5:regular",
        "--color=scrollbar:#27a1b9",
        "--color=separator:#ff9e64",
        "--color=spinner:#ff007c",
      }

      local env_opts = table.concat(theme_opts, " ")
      vim.env.FZF_DEFAULT_OPTS = vim.trim((vim.env.FZF_DEFAULT_OPTS or "") .. " " .. env_opts)

      fzf.setup({
        winopts = {
          width = 0.85,
          height = 0.85,
        },
        files = {
          -- include hidden and ignored files so .txt never gets filtered out
          rg_opts = "--hidden --follow --no-ignore --color=never --files",
        },
        fzf_opts = {
          ["--highlight-line"] = "",
          ["--info"] = "inline-right",
          ["--ansi"] = "",
          ["--layout"] = "reverse",
          ["--border"] = "none",
          ["--color"] = {
            "bg+:#283457",
            "bg:#16161e",
            "border:#27a1b9",
            "fg:#c0caf5",
            "gutter:#16161e",
            "header:#ff9e64",
            "hl+:#2ac3de",
            "hl:#2ac3de",
            "info:#545c7e",
            "marker:#ff007c",
            "pointer:#ff007c",
            "prompt:#2ac3de",
            "query:#c0caf5:regular",
            "scrollbar:#27a1b9",
            "separator:#ff9e64",
            "spinner:#ff007c",
          },
        },
      })

      local map = vim.keymap.set
      map("n", "<leader>ff", fzf.files, { desc = "Find files (fzf)" })
      map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep (fzf)" })
      map("n", "<leader>fb", fzf.buffers, { desc = "Buffers (fzf)" })
      map("n", "<leader>fh", fzf.help_tags, { desc = "Help tags (fzf)" })
      map("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files (fzf)" })
      map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor (fzf)" })
      map("n", "<leader>fs", fzf.live_grep, { desc = "Search in project (fzf)" })
      map("n", "<leader>/", fzf.live_grep, { desc = "Search in project (fzf)" })
    end,
  },
}
