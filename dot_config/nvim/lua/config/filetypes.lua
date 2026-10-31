-- Filetypes Neovim doesn't detect on its own, so the right language server
-- attaches (see plugins/lsp.lua).

local function in_chart(path)
  return vim.fs.root(path, "Chart.yaml") ~= nil
end

local function next_to_chart(path)
  return vim.uv.fs_stat(vim.fs.joinpath(vim.fs.dirname(path), "Chart.yaml")) ~= nil
end

vim.filetype.add({
  -- Docker Compose files, so docker_language_server attaches alongside yamlls.
  filename = {
    ["compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["docker-compose.yml"] = "yaml.docker-compose",
  },
  pattern = {
    -- Overrides such as compose.override.yaml or docker-compose.dev.yml
    [".*/compose%.[^/]+%.ya?ml"] = "yaml.docker-compose",
    [".*/docker%-compose%.[^/]+%.ya?ml"] = "yaml.docker-compose",

    -- Helm charts: templates get "helm" and values files "yaml.helm-values",
    -- so helm_ls attaches instead of plain yamlls (which reports every {{ }}
    -- as an error). Only files inside a chart (a directory with Chart.yaml)
    -- match; anything else stays plain YAML.
    [".*/templates/.*%.ya?ml"] = function(path)
      return in_chart(path) and "helm" or nil
    end,
    [".*/templates/.*%.tpl"] = function(path)
      return in_chart(path) and "helm" or nil
    end,
    [".*/values[^/]*%.ya?ml"] = function(path)
      return next_to_chart(path) and "yaml.helm-values" or nil
    end,
  },
})
