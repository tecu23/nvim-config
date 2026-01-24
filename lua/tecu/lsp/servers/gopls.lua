-- ============================================================================
-- Go Language Server (gopls) Configuration
-- ============================================================================

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = function(fname)
		local util = require("lspconfig.util")
		-- Look for go.work first (Go workspace), then go.mod, then .git
		return util.root_pattern("go.work", "go.mod", ".git")(fname) or util.path.dirname(fname)
	end,
	single_file_support = true,
	settings = {
		gopls = {
			-- General settings
			gofumpt = false, -- Use gofumpt formatting
			usePlaceholders = false, -- Placeholders in completions
			completeUnimported = true, -- Complete unimported packages
			staticcheck = false, -- Disabled staticcheck to improve performance (can cause freezes)
			semanticTokens = true, -- Enable semantic tokens

			-- Analyses settings
			analyses = {
				unusedparams = true, -- Report unused parameters
				shadow = true, -- Report shadowed variables
				fieldalignment = true, -- Find structs that can be optimized
				nilness = true, -- Check for nil pointer dereferences
				unusedwrite = true, -- Report unused writes
				useany = true, -- Suggest using 'any' over 'interface{}'
				unusedvariable = true, -- Report unused variables
				composites = true, -- Check for unkeyed composite literals
				SA1019 = true, -- Using a deprecated function, variable, constant or field
			},

			-- Code lenses
			codelenses = {
				gc_details = false, -- Don't show gc annotation details
				generate = true, -- Show 'generate' lens
				regenerate_cgo = true, -- Show 'regenerate cgo' lens
				run_govulncheck = true, -- Show 'run vulncheck' lens
				test = true, -- Show 'run test' lens
				tidy = true, -- Show 'go mod tidy' lens
				upgrade_dependency = true, -- Show 'upgrade dependency' lens
				vendor = true, -- Show 'vendor' lens
			},

			-- Inlay hints
			hints = {
				assignVariableTypes = true, -- Show type hints for variables
				compositeLiteralFields = true, -- Show field names in composite literals
				compositeLiteralTypes = true, -- Show type hints for composite literals
				constantValues = true, -- Show values of constants
				functionTypeParameters = true, -- Show type parameters in function calls
				parameterNames = true, -- Show parameter names in function calls
				rangeVariableTypes = true, -- Show types of range variables
			},

			-- Diagnostic settings (increased delay to reduce CPU usage in monorepos)
			diagnosticsDelay = "1000ms", -- Increased from 500ms to further reduce freezes
			symbolMatcher = "fuzzy",

			-- Build settings
			buildFlags = { "-tags=integration" }, -- Add build tags if needed
			env = {}, -- Environment variables

			-- Module settings
			allowModfileModifications = true,
			allowImplicitNetworkAccess = true,

			-- Completion settings
			matcher = "fuzzy",
			symbolStyle = "dynamic", -- "dynamic", "full", "package"

			-- Documentation
			linksInHover = true,
			importShortcut = "both", -- "link", "definition", "both"

			-- Experimental features
			experimentalPostfixCompletions = true,
			experimentalTemplateSupport = true,
			experimentalWorkspaceModule = true,
		},
	},

	-- Additional initialization options
	init_options = {
		usePlaceholders = false,
		completeUnimported = true,
	},

	-- Match VS Code: organize imports + format on save via gopls
	on_attach = function(client, bufnr)
		if not vim.lsp.buf_is_attached(bufnr, client.id) then
			vim.lsp.buf_attach_client(bufnr, client.id)
		end

		require("tecu.lsp").get_on_attach()(client, bufnr)

		-- Organize imports and format on save (same as VS Code)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				-- 1. Organize imports (same as VS Code's source.organizeImports)
				local params = vim.lsp.util.make_range_params()
				params.context = { only = { "source.organizeImports" } }
				local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
				for cid, res in pairs(result or {}) do
					for _, r in pairs(res.result or {}) do
						if r.edit then
							local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
							vim.lsp.util.apply_workspace_edit(r.edit, enc)
						end
					end
				end

				-- 2. Format code (same as VS Code's editor.formatOnSave)
				vim.lsp.buf.format({ async = false, bufnr = bufnr })
			end,
		})
	end,
}
