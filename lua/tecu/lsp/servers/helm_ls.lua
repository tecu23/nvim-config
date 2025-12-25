-- ============================================================================
-- Helm Language Server
-- ============================================================================

return {
	cmd = { "helm_ls", "serve" },
	filetypes = { "helm" },
	root_dir = function(fname)
		local util = require("lspconfig.util")
		-- Look for Chart.yaml (Helm chart root)
		return util.root_pattern("Chart.yaml", ".git")(fname)
	end,
	settings = {},
	on_attach = function(client, bufnr)
		-- Helm specific keymaps
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Helm: " .. desc })
		end

		-- Helm commands
		map("n", "<leader>hl", "<cmd>!helm lint .<CR>", "Lint chart")
		map("n", "<leader>ht", "<cmd>!helm template . --debug<CR>", "Template debug")
		map("n", "<leader>hd", "<cmd>!helm dependency update<CR>", "Update dependencies")
	end,
}
