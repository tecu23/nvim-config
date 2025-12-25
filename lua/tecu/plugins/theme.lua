-- ============================================================================
-- Theme Configuration
-- ============================================================================

local function apply_transparency()
	-- Only make UI elements transparent, NOT syntax highlighting groups
	-- This preserves code coloring while keeping the background transparent
	local transparent_groups = {
		-- Editor background
		"Normal",
		"NormalNC",
		"NormalFloat",
		"FloatBorder",

		-- UI elements
		"LineNr",
		"NonText",
		"SignColumn",
		"CursorLineNr",
		"EndOfBuffer",
		"TabLine",
		"TabLineFill",
		"StatusLine",
		"StatusLineNC",
		"WinBar",
		"WinBarNC",
		"WinSeparator",

		-- Completion menu
		"Pmenu",
		"PmenuSel",
		"PmenuSbar",
		"PmenuThumb",
	}

	for _, group in ipairs(transparent_groups) do
		vim.cmd(string.format("highlight %s guibg=NONE ctermbg=NONE", group))
	end
end

return {
	"vague2k/vague.nvim",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other plugins
	config = function()
		require("vague").setup({
			transparent = true,
		})
		vim.cmd("colorscheme vague")
		apply_transparency()

		-- Custom YAML syntax colors
		vim.api.nvim_set_hl(0, "@property.yaml", { fg = "#89b4fa", bold = true }) -- keys: blue
		vim.api.nvim_set_hl(0, "@field.yaml", { link = "@property.yaml" })
		vim.api.nvim_set_hl(0, "@string.yaml", { fg = "#a6e3a1" }) -- strings: green
		vim.api.nvim_set_hl(0, "@number.yaml", { fg = "#fab387" }) -- numbers: orange

		-- Reapply transparency after colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				apply_transparency()
				-- Reapply YAML customizations
				vim.api.nvim_set_hl(0, "@property.yaml", { fg = "#89b4fa", bold = true })
				vim.api.nvim_set_hl(0, "@field.yaml", { link = "@property.yaml" })
				vim.api.nvim_set_hl(0, "@string.yaml", { fg = "#a6e3a1" })
				vim.api.nvim_set_hl(0, "@number.yaml", { fg = "#fab387" })
			end,
		})
	end,
}
