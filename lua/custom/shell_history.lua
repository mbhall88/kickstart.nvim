--[[
shell_history.lua
=================
A small Telescope picker to browse and insert your shell history (zsh or bash).

Usage:
  :lua require('custom.shell_history').telescope_shell_history()

Or, bind a key in your init.lua:
  local shell_history = require('custom.shell_history')
  vim.keymap.set('n', '<leader>fh', shell_history.telescope_shell_history,
    { desc = '[F]uzzy search [H]istory (shell)' })

This will open an fzf-like picker of your shell history. Press <CR> to insert
the chosen command under the cursor in the current buffer.
--]]

local pickers       = require('telescope.pickers')
local finders       = require('telescope.finders')
local conf          = require('telescope.config').values
local actions       = require('telescope.actions')
local action_state  = require('telescope.actions.state')

local M = {}
local uv = vim.uv or vim.loop  -- For Neovim 0.10 and later, use vim.uv

--- Read the user’s shell history file and return its lines as a table.
-- Supports zsh extended history (`: <epoch>:<duration>;command`) by stripping prefixes.
-- Falls back to ~/.bash_history if ~/.zsh_history is not present.
local function shell_history_lines()
  local hist = os.getenv('HISTFILE')
  if not hist or hist == '' then
    local home = vim.fn.expand('~')
    if uv.fs_stat(home .. '/.zsh_history') then
      hist = home .. '/.zsh_history'
    else
      hist = home .. '/.bash_history'
    end
  end

  local out = {}
  local f = io.open(hist, 'r')
  if f then
    for line in f:lines() do
      -- For zsh extended format, strip the leading timestamp and duration
      line = line:gsub('^:%s*%d+:%d+;', '')
      table.insert(out, line)
    end
    f:close()
  end
  return out
end

--- Telescope picker for shell history.
-- Opens a fuzzy-finder window with history lines.
-- When an entry is selected, the command is inserted at the cursor position.
function M.telescope_shell_history()
  local lines = shell_history_lines()

  pickers.new({}, {
    prompt_title = 'Shell History',
    finder = finders.new_table(lines),
    sorter = conf.generic_sorter({}),

    attach_mappings = function(prompt_bufnr, map)
      local function insert_line()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if entry and entry[1] and entry[1] ~= '' then
          -- Insert into current buffer at cursor
          vim.api.nvim_put({ entry[1] }, 'c', true, true)
        end
      end

      -- Bind <CR> in insert and normal mode to insert command
      map('i', '<CR>', insert_line)
      map('n', '<CR>', insert_line)
      return true
    end,
  }):find()
end

return M
