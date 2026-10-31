-- Language servers, completion and formatting (replaces ALE, vim-go, black).
-- The servers and formatters are installed by mise (~/.config/mise/config.toml);
-- nvim-lspconfig supplies each server's settings.
-- Neovim's default LSP maps apply: K hover, grn rename, gra code action,
-- grr references, gri implementation, [d / ]d diagnostics.
return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })
      vim.lsp.enable({
        "basedpyright", "bashls", "docker_language_server", "dockerls", "gopls",
        "helm_ls", "jsonls", "lua_ls", "marksman", "ruff", "terraformls", "tflint",
        "yamlls",
      })

      vim.diagnostic.config({ virtual_text = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp", { clear = true }),
        callback = function(args)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
          -- Built-in completion: pops up as you type, <C-y> accepts.
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })
    end,
  },
  { "folke/lazydev.nvim", ft = "lua", opts = {} },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        go = { "goimports" }, -- also applies gofmt
        python = { "ruff_organize_imports", "ruff_format" },
        terraform = { "terraform_fmt" },
        ["terraform-vars"] = { "terraform_fmt" },
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },
}
