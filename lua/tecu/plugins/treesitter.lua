-- ============================================================================
-- Treesitter Configuration
-- ============================================================================

return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"astro",
			"bash",
			"c",
			"css",
			"dockerfile",
			"go",
			"hcl", -- Terraform/HCL
			"helm", -- Kubernetes Helm
			"html",
			"javascript",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"python",
			"regex",
			"sql",
			"terraform", -- Terraform
			"typescript",
			"tsx",
			"tmux",
			"vim",
			"vimdoc",
			"yaml",
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		highlight = {
			enable = true,
			-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
			--  If you are experiencing weird indenting issues, add the language to
			--  the list of additional_vim_regex_highlighting and disabled languages for indent.
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
	},
	config = function(_, opts)
		require("nvim-treesitter.install").prefer_git = true
		require("nvim-treesitter.configs").setup(opts)
	end,
}
