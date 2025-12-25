-- ============================================================================
-- YAML Language Server
-- ============================================================================

return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose", "yaml.kubernetes", "yml" },
	settings = {
		yaml = {
			hover = true,
			completion = true,
			validate = true,
			format = {
				enable = true,
				singleQuote = false,
				bracketSpacing = true,
				proseWrap = "preserve",
				printWidth = 80,
			},
			schemas = (function()
				local ok, schemastore = pcall(require, "schemastore")
				if ok then
					return schemastore.yaml.schemas()
				end
				return {
					-- Fallback schemas if schemastore is not available
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
					kubernetes = "*.yaml",
				}
			end)(),
			schemaDownload = { enable = true },
			trace = {
				server = "off",
			},
			customTags = {
				"!reference sequence", -- GitLab CI
				"!reference scalar", -- GitLab CI
			},
		},
		redhat = {
			telemetry = {
				enabled = false,
			},
		},
	},
	on_attach = function(client, bufnr)
		-- YAML specific keymaps
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "YAML: " .. desc })
		end

		-- Show current schema
		map("n", "<leader>yi", function()
			vim.notify("YAML LSP attached with Kubernetes schema support", vim.log.levels.INFO)
		end, "Show YAML info")

		-- Validate YAML
		map("n", "<leader>yv", function()
			vim.lsp.buf.code_action()
		end, "Validate YAML")
	end,
}
