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
			usePlaceholders = true, -- Placeholders in completions
			completeUnimported = true, -- Complete unimported packages
			staticcheck = true, -- Enable staticcheck
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

			-- Diagnostic settings
			diagnosticsDelay = "250ms",
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
		usePlaceholders = true,
		completeUnimported = true,
	},

	-- Organize imports on save
	on_attach = function(client, bufnr)
		if not vim.lsp.buf_is_attached(bufnr, client.id) then
			vim.lsp.buf_attach_client(bufnr, client.id)
		end

		require("tecu.lsp").get_on_attach()(client, bufnr)
		-- 	-- -- Create autocmd for organizing imports on save
		-- 	-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	-- 	pattern = "*.go",
		-- 	-- 	-- buffer = bufnr,
		-- 	-- 	callback = function()
		-- 	-- 		-- Organize imports
		-- 	-- 		local params = vim.lsp.util.make_range_params()
		-- 	-- 		params.context = { only = { "source.organizeImports" } }
		-- 	-- 		local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
		-- 	-- 		for cid, res in pairs(result or {}) do
		-- 	-- 			for _, r in pairs(res.result or {}) do
		-- 	-- 				if r.edit then
		-- 	-- 					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
		-- 	-- 					vim.lsp.util.apply_workspace_edit(r.edit, enc)
		-- 	-- 				end
		-- 	-- 			end
		-- 	-- 		end
		-- 	--
		-- 	-- 		-- Format
		-- 	-- 		vim.lsp.buf.format({ async = false })
		-- 	-- 	end,
		-- 	-- })
		--
		-- 	-- Set up Go-specific keymaps
		-- 	local map = function(mode, lhs, rhs, desc)
		-- 		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Go: " .. desc })
		-- 	end
		--
		-- 	-- Test keymaps
		-- 	map("n", "<leader>gt", "<cmd>!go test -v ./...<CR>", "Run all tests")
		-- 	map("n", "<leader>gT", "<cmd>!go test -v -run ^%:t:r$ ./...<CR>", "Run test under cursor")
		-- 	map("n", "<leader>gb", "<cmd>!go test -bench=.<CR>", "Run benchmarks")
		--
		-- 	-- Build and run
		-- 	map("n", "<leader>gr", "<cmd>!go run %<CR>", "Run current file")
		-- 	map("n", "<leader>gB", "<cmd>!go build<CR>", "Build project")
		--
		-- 	-- Go to alternate file (test <-> implementation)
		-- 	map("n", "<leader>ga", function()
		-- 		local file = vim.fn.expand("%")
		-- 		local alt_file
		-- 		if file:match("_test%.go$") then
		-- 			alt_file = file:gsub("_test%.go$", ".go")
		-- 		else
		-- 			alt_file = file:gsub("%.go$", "_test.go")
		-- 		end
		-- 		vim.cmd("edit " .. alt_file)
		-- 	end, "Go to alternate file")
		--
		-- 	-- Generate
		-- 	map("n", "<leader>gg", "<cmd>!go generate ./...<CR>", "Run go generate")
		--
		-- 	-- Mod commands
		-- 	map("n", "<leader>gm", "<cmd>!go mod tidy<CR>", "Run go mod tidy")
		-- 	map("n", "<leader>gv", "<cmd>!go mod vendor<CR>", "Run go mod vendor")
		--
		-- 	-- Coverage
		-- 	map("n", "<leader>gc", function()
		-- 		vim.cmd("!go test -coverprofile=coverage.out ./...")
		-- 		vim.cmd("!go tool cover -html=coverage.out -o coverage.html")
		-- 		vim.notify("Coverage report generated: coverage.html", vim.log.levels.INFO)
		-- 	end, "Generate coverage report")
	end,
}
