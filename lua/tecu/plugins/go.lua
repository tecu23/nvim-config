-- ============================================================================
-- Neovim Golang Integration Configuration (go.nvim)
-- ============================================================================

return {
	"ray-x/go.nvim",
	ft = "go",
	dependencies = {
		"ray-x/guihua.lua", -- GUI components for go.nvim
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
		"mfussenegger/nvim-dap", -- DAP support for debugging
	},
	build = ':lua require("go.install").update_all_sync()', -- Install/update all binaries
	opts = {
		-- Disable lsp_cfg as we have our own gopls configuration
		lsp_cfg = false,
		lsp_gofumpt = false,
		lsp_on_attach = false,
		lsp_codelens = true,
		-- DAP configuration
		dap_debug = true,
		dap_debug_gui = true,
		-- Test configuration
		test_runner = "go", -- or 'gotestsum', 'ginkgo'
		run_in_floaterm = false,
		-- Formatting
		lsp_inlay_hints = {
			enable = false, -- We handle this in gopls config
		},
		-- Diagnostic configuration
		lsp_diag_hdlr = true,
		lsp_diag_virtual_text = { space = 0, prefix = "■" },
		lsp_diag_signs = true,
		lsp_diag_update_in_insert = false,
		-- Additional settings
		luasnip = true,
		verbose = false,
	},

	config = function(_, opts)
		require("go").setup(opts)

		-- Auto-format and organize imports on save
		local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				require("go.format").goimports()
			end,
			group = format_sync_grp,
		})

		-- Golang KeyMaps
		vim.keymap.set("n", "<leader>ggsj", "<cmd>GoAddTag json<CR>", { desc = "[G]o Add Json Struct Tags" })
		vim.keymap.set("n", "<leader>ggsy", "<cmd>GoAddTag yaml<CR>", { desc = "[G]o Add Yaml Struct Tags" })
		vim.keymap.set(
			"n",
			"<leader>ggsv",
			"<cmd>GoAddTag validate<CR>",
			{ desc = "[G]o Add Struct Validation" }
		)

		vim.keymap.set("n", "<leader>ggcmt", "<cmd>GoCmt<CR>", { desc = "[G]o Generate Doc Comments" })
		vim.keymap.set("n", "<leader>gge", "<cmd>GoIfErr<CR>", { desc = "[G]o Generate Error" })

		vim.keymap.set("n", "<leader>ggmt", "<cmd>GoModTidy<CR>", { desc = "[G]o Mod Tidy" })

		-- Additional go.nvim keymaps
		vim.keymap.set("n", "<leader>ggt", "<cmd>GoTest<CR>", { desc = "[G]o Run Tests" })
		vim.keymap.set("n", "<leader>ggT", "<cmd>GoTestFunc<CR>", { desc = "[G]o Test Function" })
		vim.keymap.set("n", "<leader>ggc", "<cmd>GoCoverage<CR>", { desc = "[G]o Coverage" })
		vim.keymap.set("n", "<leader>ggf", "<cmd>GoFillStruct<CR>", { desc = "[G]o Fill Struct" })
		vim.keymap.set("n", "<leader>ggi", "<cmd>GoImport<CR>", { desc = "[G]o Import Package" })
		vim.keymap.set("n", "<leader>ggd", "<cmd>GoDoc<CR>", { desc = "[G]o Documentation" })
		vim.keymap.set("n", "<leader>ggb", "<cmd>GoBuild<CR>", { desc = "[G]o Build" })
		vim.keymap.set("n", "<leader>ggr", "<cmd>GoRun<CR>", { desc = "[G]o Run" })
	end,
}
