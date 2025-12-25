-- ============================================================================
-- LSP Main Initialization Module
-- ============================================================================
local M = {}

-- ============================================================================
-- Setup Function
-- ============================================================================
function M.setup()
	-- Load LSP modules
	require("tecu.lsp.setup").setup()

	-- Setup diagnostic configuration
	M.setup_diagnostics()

	-- Setup LSP handlers
	M.setup_handlers()

	-- Setup autocommands
	M.setup_autocmds()

	-- Setup user commands
	M.setup_commands()
end

-- ============================================================================
-- Diagnostic Configuration
-- ============================================================================
function M.setup_diagnostics()
	-- Configure diagnostic display
	vim.diagnostic.config({
		virtual_text = {
			prefix = function(diagnostic)
				local icons = {
					[vim.diagnostic.severity.ERROR] = "✘",
					[vim.diagnostic.severity.WARN] = "▲",
					[vim.diagnostic.severity.INFO] = "»",
					[vim.diagnostic.severity.HINT] = "⚑",
				}
				return icons[diagnostic.severity] or "●"
			end,
			spacing = 4,
			source = "if_many",
			format = function(diagnostic)
				-- Show error code if available
				if diagnostic.code then
					return string.format("%s [%s]", diagnostic.message, diagnostic.code)
				end

				return diagnostic.message
			end,
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "✘",
				[vim.diagnostic.severity.WARN] = "▲",
				[vim.diagnostic.severity.HINT] = "⚑",
				[vim.diagnostic.severity.INFO] = "»",
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
				[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
				[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			},
		},
		update_in_insert = false,
		severity_sort = true,
		float = {
			border = "rounded",
			max_width = 80,
			max_height = 20,
			source = "always",
			format = function(diagnostic)
				return string.format("%s: %s", diagnostic.source or "LSP", diagnostic.message)
			end,
		},

		-- Add underline for better visual indication without full line highlighting
		underline = {
			severity = { min = vim.diagnostic.severity.HINT },
		},
	})
end

-- ============================================================================
-- LSP Handlers Configuration
-- ============================================================================
function M.setup_handlers()
	-- Hover handler with border
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
		width = 60,
		focusable = true,
	})

	-- Configure help handler with
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
		width = 60,
		focusable = false,
	})

	-- Configure how references/definitions are shown
	vim.lsp.handlers["textDocument/references"] = vim.lsp.with(vim.lsp.handlers["textDocument/references"], {
		loclist = false,
		on_list = function(options)
			-- Use Telescope for better UX if available
			local ok, telescope = pcall(require, "telescope.builtin")
			if ok then
				telescope.lsp_references()
			else
				vim.fn.setqflist({}, " ", options)
				vim.cmd("copen")
			end
		end,
	})

	-- Show diagnostics automatically in hover window
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		-- Enable underline, use default values
		underline = true,
		virtual_text = true,
		signs = true,
		update_in_insert = false,
	})
end

-- ============================================================================
-- Autocommands
-- ============================================================================
function M.setup_autocmds()
	local group = vim.api.nvim_create_augroup("LspConfig", { clear = true })

	-- LSP Attach
	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = function(event)
			M.on_attach(event)
		end,
	})

	-- LSP Detach
	vim.api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(event)
			M.on_detach(event)
		end,
	})

	-- Show diagnostics on cursor hold
	vim.api.nvim_create_autocmd("CursorHold", {
		group = group,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			}
			vim.diagnostic.open_float(nil, opts)
		end,
	})
end

-- ============================================================================
-- On Attach Function
-- ============================================================================
function M.on_attach(event)
	local bufnr = event.buf
	local client = vim.lsp.get_client_by_id(event.data.client_id)

	if not client then
		return
	end

	-- Setup Keymaps
	M.setup_keymaps(bufnr)

	-- Setup buffer-specific settings
	M.setup_buffer_settings(client, bufnr)

	-- Setup document highlighting
	if client.server_capabilities.documentHighlightProvider then
		M.setup_document_highlight(bufnr)
	end

	-- Setup code lens
	if client.server_capabilities.codeLensProvider then
		M.setup_codelens(bufnr)
	end

	-- Setup inlay hints
	if vim.lsp.inlay_hint and client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	-- Log attachment
	vim.notify(string.format("LSP: %s attached to buffer %d", client.name, bufnr), vim.log.levels.INFO)
end

-- ============================================================================
-- On Detach Function
-- ============================================================================
function M.on_detach(event)
	local bufnr = event.buf
	vim.lsp.buf.clear_references()
	-- Safely clear autocmds only if groups exist
	pcall(vim.api.nvim_clear_autocmds, { group = "LspDocumentHighlight", buffer = bufnr })
	pcall(vim.api.nvim_clear_autocmds, { group = "LspCodeLens", buffer = bufnr })
end

-- ============================================================================
-- Setup Keymaps
-- ============================================================================
function M.setup_keymaps(bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	-- Navigation
	map("n", "gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("n", "gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	map("n", "gr", vim.lsp.buf.references, "[G]oto [R]eferences")
	map("n", "gs", vim.lsp.buf.signature_help, "[G]oto [S]ignature Help")
	map("n", "<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")

	-- Use Telescope if available
	local ok, telescope = pcall(require, "telescope.builtin")
	if ok then
		map("n", "gd", telescope.lsp_definitions, "[G]oto [D]efinition (Telescope)")
		-- map("n", "gD", telescope.lsp_declaration, "[G]oto [D]efinition (Telescope)")
		map("n", "gI", telescope.lsp_implementations, "[G]oto [I]mplementation (Telescope)")
		map("n", "gr", telescope.lsp_references, "[G]oto [R]eferences (Telescope)")
		map("n", "<leader>D", telescope.lsp_type_definitions, "Type [D]efinition (Telescope)")
		map("n", "<leader>ds", telescope.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("n", "<leader>ws", telescope.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	end

	-- Documentation
	map("n", "K", vim.lsp.buf.hover, "Show hover documentation")

	-- Workspace
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]remove Folder")
	map("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	-- Actions
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("n", "<leader>rn", vim.lsp.buf.rename, "[R]ename [S]ymbol")

	-- Diagnostics
	map("n", "<leader>do", vim.diagnostic.open_float, "Show Line Diagnostics")
	map("n", "[d", vim.diagnostic.goto_prev, "Previous [D]iagnostic")
	map("n", "]d", vim.diagnostic.goto_next, "Next [D]iagnostic")
	map("n", "<leader>q", vim.diagnostic.setloclist, "Set Location List")

	-- Use Trouble if available for better diagnostics UI
	local trouble_ok, _ = pcall(require, "trouble")
	if trouble_ok then
		map("n", "<leader>xx", "<cmd>TroubleToggle<CR>", "Toggle trouble")
		map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", "Workspace diagnostics")
		map("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", "Document diagnostics")
		map("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", "Location list")
		map("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", "Quickfix list")
	end

	-- Toggle inlay hints
	if vim.lsp.inlay_hint then
		map("n", "<leader>ih", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle [I]nlay [H]ints")
	end

	-- Code lens
	map("n", "<leader>cl", vim.lsp.codelens.run, "[C]ode [L]ens")
	map("n", "<leader>cr", vim.lsp.codelens.refresh, "[C]ode Lens [R]efresh")
end

-- ============================================================================
-- Setup Buffer Settings
-- ============================================================================
function M.setup_buffer_settings(client, bufnr)
	-- Enable completion
	if client.server_capabilities.completionProvider then
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	end

	-- Enable tag support
	if client.server_capabilities.definitionProvider then
		vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
	end

	-- Set formatexpr for gq
	if client.server_capabilities.documentFormattingProvider then
		vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
	end
end

-- ============================================================================
-- Setup Document Highlight
-- ============================================================================
function M.setup_document_highlight(bufnr)
	local group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
	vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		buffer = bufnr,
		callback = vim.lsp.buf.clear_references,
	})
end

-- ============================================================================
-- Setup Code Lens
-- ============================================================================
function M.setup_codelens(bufnr)
	local group = vim.api.nvim_create_augroup("LspCodeLens", { clear = false })
	vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })

	-- Refresh code lens on certain events
	vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
		group = group,
		buffer = bufnr,
		callback = function()
			vim.lsp.codelens.refresh()
		end,
	})
end

-- ============================================================================
-- User Commands
-- ============================================================================
function M.setup_commands()
	-- LSP Info
	vim.api.nvim_create_user_command("LspInfo", function()
		vim.cmd("checkhealth vim.lsp")
	end, { desc = "Show LSP information" })

	-- LSP Log
	vim.api.nvim_create_user_command("LspLog", function()
		vim.cmd("edit " .. vim.lsp.get_log_path())
	end, { desc = "Open LSP log file" })

	-- Restart LSP
	vim.api.nvim_create_user_command("LspRestart", function()
		vim.lsp.stop_client(vim.lsp.get_active_clients())
		vim.cmd("edit")
		vim.notify("LSP servers restarted", vim.log.levels.INFO)
	end, { desc = "Restart all LSP servers" })

	-- Format document
	vim.api.nvim_create_user_command("Format", function(args)
		local range = nil
		if args.count ~= -1 then
			local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
			range = {
				start = { args.line1, 0 },
				["end"] = { args.line2, end_line:len() },
			}
		end
		require("conform").format({ async = true, lsp_fallback = true, range = range })
	end, { range = true, desc = "Format document or range" })

	-- Toggle format on save
	vim.api.nvim_create_user_command("FormatToggle", function()
		vim.g.disable_autoformat = not vim.g.disable_autoformat
		if vim.g.disable_autoformat then
			vim.notify("Autoformat disabled", vim.log.levels.INFO)
		else
			vim.notify("Autoformat enabled", vim.log.levels.INFO)
		end
	end, { desc = "Toggle format on save" })

	-- Toggle diagnostics
	vim.api.nvim_create_user_command("DiagnosticsToggle", function()
		local current = vim.diagnostic.is_disabled()
		if current then
			vim.diagnostic.enable()
			vim.notify("Diagnostics enabled", vim.log.levels.INFO)
		else
			vim.diagnostic.disable()
			vim.notify("Diagnostics disabled", vim.log.levels.INFO)
		end
	end, { desc = "Toggle diagnostics" })
end

-- ============================================================================
-- Utility Functions
-- ============================================================================

-- Get LSP capabilities
function M.get_capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- Enable snippet support
	capabilities.textDocument.completion.completionItem.snipperSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}

	-- Enable semantic tokens
	capabilities.textDocument.semanticTokens = vim.lsp.protocol.make_client_capabilities().textDocument.semanticTokens

	-- File watching
	capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

	-- Workspace folders
	capabilities.workspace.workspaceFolders = true

	-- If nvim-cmp is installed, enhance capabiliries
	local ok, blink_cmp = pcall(require, "blink.cmp")
	if ok then
		capabilities = vim.tbl_deep_extend("force", capabilities, blink_cmp.get_lsp_capabilities())
	end

	return capabilities
end

-- Get common on_attach function
function M.get_on_attach()
	return function(client, bufnr)
		-- This is kept for compatibility with servers that might use it directly
		-- The actual logic is handled by the LspAttach autocmd
	end
end

return M
