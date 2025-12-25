-- ============================================================================
-- Terraform Language Server
-- ============================================================================

return {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform", "terraform-vars", "tf", "hcl" },
	root_dir = function(fname)
		local util = require("lspconfig.util")
		-- Look for .terraform directory or .git
		return util.root_pattern(".terraform", ".git")(fname) or util.path.dirname(fname)
	end,
	settings = {
		["terraform-ls"] = {
			-- Enable experimental features
			experimentalFeatures = {
				validateOnSave = true,
				prefillRequiredFields = true,
			},
		},
		terraform = {
			-- Validation settings
			validation = {
				enableEnhancedValidation = true,
			},
		},
	},
	on_attach = function(client, bufnr)
		-- Terraform specific keymaps
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Terraform: " .. desc })
		end

		-- Terraform commands
		map("n", "<leader>ti", "<cmd>!terraform init<CR>", "Init")
		map("n", "<leader>tv", "<cmd>!terraform validate<CR>", "Validate")
		map("n", "<leader>tp", "<cmd>!terraform plan<CR>", "Plan")
		map("n", "<leader>ta", "<cmd>!terraform apply<CR>", "Apply")
		map("n", "<leader>td", "<cmd>!terraform destroy<CR>", "Destroy")
		map("n", "<leader>tf", "<cmd>!terraform fmt<CR>", "Format")
		map("n", "<leader>tw", "<cmd>!terraform workspace list<CR>", "List workspaces")
	end,
}
