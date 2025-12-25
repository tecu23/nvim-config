-- ============================================================================
-- Infrastructure as Code Plugins (Kubernetes, Terraform, Helm)
-- ============================================================================

return {
	-- ============================================================================
	-- Kubernetes/YAML enhancements
	-- ============================================================================
	-- NOTE: yaml-companion is disabled to avoid conflicts with yamlls config
	-- If you need advanced schema switching, uncomment this plugin and remove
	-- the yamlls config from lua/tecu/lsp/servers/yamlls.lua
	-- {
	-- 	"someone-stole-my-name/yaml-companion.nvim",
	-- 	enabled = false,
	-- 	dependencies = {
	-- 		{ "neovim/nvim-lspconfig" },
	-- 		{ "nvim-lua/plenary.nvim" },
	-- 		{ "nvim-telescope/telescope.nvim" },
	-- 	},
	-- 	ft = { "yaml" },
	-- 	config = function()
	-- 		require("yaml-companion").setup({
	-- 			builtin_matchers = {
	-- 				kubernetes = { enabled = true },
	-- 				cloud_init = { enabled = true },
	-- 			},
	-- 			schemas = {
	-- 				{
	-- 					name = "Kubernetes 1.30",
	-- 					uri = "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0-standalone-strict/all.json",
	-- 				},
	-- 			},
	-- 		})
	-- 		require("telescope").load_extension("yaml_schema")
	-- 		vim.keymap.set("n", "<leader>ys", "<cmd>Telescope yaml_schema<CR>", { desc = "Select YAML schema" })
	-- 	end,
	-- },

	-- ============================================================================
	-- Terraform enhancements
	-- ============================================================================
	{
		"hashivim/vim-terraform",
		ft = { "terraform", "tf", "hcl" },
		config = function()
			-- Auto-format on save
			vim.g.terraform_fmt_on_save = 0 -- Disabled since we use conform.nvim

			-- Enable syntax folding
			vim.g.terraform_fold_sections = 1

			-- Align settings with equals sign
			vim.g.terraform_align = 1
		end,
	},

	-- ============================================================================
	-- Additional Kubernetes tools
	-- ============================================================================
	{
		"cuducos/yaml.nvim",
		ft = { "yaml" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			-- Keymaps for YAML navigation
			vim.keymap.set("n", "<leader>yk", function()
				require("yaml_nvim").view()
			end, { desc = "YAML: View key path", noremap = true, silent = true })

			vim.keymap.set("n", "<leader>yy", function()
				require("yaml_nvim").yank()
			end, { desc = "YAML: Yank key path", noremap = true, silent = true })
		end,
	},
}
