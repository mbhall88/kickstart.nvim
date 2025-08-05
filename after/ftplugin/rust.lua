local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set('n', '<leader>a', function()
  vim.cmd.RustLsp 'codeAction' -- supports rust-analyzer's grouping
  -- or vim.lsp.buf.codeAction() if you don't want grouping.
end, { silent = true, buffer = bufnr })
vim.keymap.set(
  'n',
  'K', -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp { 'hover', 'actions' }
  end,
  { silent = true, buffer = bufnr }
)
-- Keybinding: Show the next diagnostic with rendered cargo-style output
-- Equivalent to `:RustLsp renderDiagnostic cycle`
-- This cycles forward through diagnostics that include enhanced output (e.g., from rust-analyzer)
vim.keymap.set('n', '<leader>rn', function()
  vim.cmd.RustLsp { 'renderDiagnostic', 'cycle' }
end, {
  desc = 'Rust: next rendered diagnostic',
  buffer = true,
})

-- Keybinding: Show the previous diagnostic with rendered output
-- Equivalent to `:RustLsp renderDiagnostic cycle_prev`
vim.keymap.set('n', '<leader>rp', function()
  vim.cmd.RustLsp { 'renderDiagnostic', 'cycle_prev' }
end, {
  desc = 'Rust: previous rendered diagnostic',
  buffer = true,
})

-- Keybinding: Show rendered diagnostic at the current line (no movement)
-- Equivalent to `:RustLsp renderDiagnostic current`
vim.keymap.set('n', '<leader>rc', function()
  vim.cmd.RustLsp { 'renderDiagnostic', 'current' }
end, {
  desc = 'Rust: current line rendered diagnostic',
  buffer = true,
})
-- This file sets up Rust-specific keybindings using the Rustaceanvim plugin
-- It is loaded automatically by Neovim for buffers with filetype 'rust'

-- Keybinding: Run any Rust "runnable" (test, binary, example, etc.)
-- This opens a Telescope-powered picker showing all testable/runnable items
-- You can select an item to run it via `cargo`, with args and environment if needed
-- This uses rust-analyzer's `runnables` feature under the hood
vim.keymap.set('n', '<leader>rt', function()
  vim.cmd.RustLsp 'runnables'
end, {
  desc = 'Rust: list and run tests/runnables',
  buffer = true,
})

-- Turns on inlay hints by default for Rust
vim.api.nvim_create_autocmd('LspAttach', {
  pattern = '*.rs',
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
})

-- Configure rust-analyzer (via Rustaceanvim) to run Clippy on save,
-- instead of cargo check, with custom linting options.
--
-- How it works:
-- - checkOnSave.enable = true → run the check command every time the file is saved.
-- - check.command = "clippy" → tells rust-analyzer to use cargo clippy instead of cargo check.
-- - check.extraArgs are passed to cargo clippy after the `--` separator,
--   which marks the end of cargo args and the start of rustc/Clippy args.
-- - In this example:
--     "-D warnings"         → treat all warnings as errors.
--     "-W clippy::pedantic" → enable Clippy's pedantic lints.
--
-- Example command that will run on save:
--   cargo clippy -- -D warnings -W clippy::pedantic
vim.g.rustaceanvim = {
  server = {
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = {
          enable = true, -- Run checks automatically on save
        },
        check = {
          command = 'clippy',
          extraArgs = { '--all-targets', '--all-features', '--', '-D', 'warnings' },
        },
      },
    },
  },
}
