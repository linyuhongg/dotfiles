local M = {}

M.general = {
  n = {
    ["<C-h"] = { "<cmd> TmuxNavigationLeft<CR>", "window left" },
    ["<C-l>"] = { "<cmd> TmuxNagivagateRight<CR>", "window right" },
    ["<C-j>"] = { "<cmd> TmuxNagivagateDown<CR>", "window down" },
    ["<C-k>"] = { "<cmd> TmuxNagivagateUp<CR>", "window up" },
  }
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {"<cmd> DapToggleBreakpoint <CR>"}
  }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

return M
