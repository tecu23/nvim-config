-- ============================================================================
-- Neovim Autocommands Configuration for Full-Stack Development
-- ========================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Clear existing autocommands to prevent duplicates on reload
local general = augroup("General", { clear = true })
local golang = augroup("Golang", { clear = true })
local ruby = augroup("Ruby", { clear = true })
local frontend = augroup("Frontend", { clear = true })
-- local formatting = augroup("Formatting", { clear = true })
local terminal = augroup("Terminal", { clear = true })
local quickfix = augroup("QuickFix", { clear = true })

-- ============================================================================
-- General Autocommands
-- ============================================================================

-- Highlight yanked text briefly
autocmd("TextYankPost", {
	group = general,
	pattern = "*",
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
	group = general,
	pattern = "*",
	desc = "Remove trailing whitespace",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
	group = general,
	pattern = "*",
	desc = "Return to last edit position",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Auto-resize splits when window is resized
autocmd("VimResized", {
	group = general,
	pattern = "*",
	desc = "Auto-resize splits on window resize",
	command = "tabdo wincmd =",
})

-- Check if file changed outside of Neovim
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = general,
	pattern = "*",
	desc = "Check for file changes",
	command = "if mode() != 'c' | checktime | endif",
})

-- Create parent directories when saving a file
autocmd("BufWritePre", {
	group = general,
	pattern = "*",
	desc = "Create parent directories if they don't exist",
	callback = function()
		local dir = vim.fn.expand("<afile>:p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

-- Disable line numbers in certain file types
autocmd("FileType", {
	group = general,
	pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "startuptime", "checkhealth" },
	desc = "Disable line numbers for certain filetypes",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.cursorline = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Close certain windows with 'q'
autocmd("FileType", {
	group = general,
	pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "startuptime", "checkhealth", "notify" },
	desc = "Close with q",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
	end,
})

-- ============================================================================
-- Go (Golang) Specific
-- ============================================================================
autocmd("BufWritePre", {
	group = golang,
	pattern = "*.go",
	desc = "Organize Go imports on save",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
	end,
})

autocmd("BufWritePre", {
	group = golang,
	pattern = "*.go",
	desc = "Format Go files on save",
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Set up Go test mappings
autocmd("FileType", {
	group = golang,
	pattern = "go",
	desc = "Set up Go test keymaps",
	callback = function()
		-- Run test under cursor
		vim.keymap.set(
			"n",
			"<leader>gt",
			"<cmd>!go test -v -run ^%:t:r$ ./...<cr>",
			{ buffer = true, desc = "Run Go test under cursor" }
		)
		-- Run all tests in package
		vim.keymap.set("n", "<leader>gT", "<cmd>!go test -v ./...<cr>", { buffer = true, desc = "Run all Go tests" })
		-- Generate test for function
		vim.keymap.set("n", "<leader>gg", "<cmd>!gotests -w %<cr>", { buffer = true, desc = "Generate Go test" })
	end,
})

-- ============================================================================
-- Ruby Specific
-- ============================================================================

-- Set file type for Ruby files
autocmd({ "BufNewFile", "BufRead" }, {
	group = ruby,
	pattern = {
		"*.rb",
		"*.rake",
		"Gemfile",
		"Rakefile",
		"Vagrantfile",
		"Thorfile",
		"Procfile",
		"Guardfile",
		"config.ru",
		"*.rabl",
		"*.jbuilder",
	},
	desc = "Detect Ruby files",
	command = "setfiletype ruby",
})

-- Rails specific file detection
autocmd({ "BufNewFile", "BufRead" }, {
	group = ruby,
	pattern = { "*.erb", "*.rhtml" },
	desc = "Detect ERB files",
	command = "setfiletype eruby",
})

-- Auto-insert frozen string literal comment
autocmd("BufNewFile", {
	group = ruby,
	pattern = "*.rb",
	desc = "Add frozen string literal to new Ruby files",
	callback = function()
		vim.api.nvim_buf_set_lines(0, 0, 0, false, { "# frozen_string_literal: true", "" })
	end,
})

-- Run RuboCop on save (requires rubocop to be installed)
autocmd("BufWritePost", {
	group = ruby,
	pattern = "*.rb",
	desc = "Run RuboCop on save",
	callback = function()
		-- This is non-blocking and shows results in quickfix
		vim.fn.jobstart("rubocop --format emacs " .. vim.fn.expand("%"), {
			on_stdout = function(_, data)
				if data and #data > 1 then
					vim.fn.setqflist({}, "r", { title = "RuboCop", lines = data })
					vim.cmd("cwindow")
				end
			end,
		})
	end,
})

-- Ruby test keymaps
autocmd("FileType", {
	group = ruby,
	pattern = "ruby",
	desc = "Set up Ruby test keymaps",
	callback = function()
		-- RSpec keymaps
		vim.keymap.set(
			"n",
			"<leader>rt",
			"<cmd>!bundle exec rspec %<cr>",
			{ buffer = true, desc = "Run current spec file" }
		)
		vim.keymap.set("n", "<leader>rT", "<cmd>!bundle exec rspec<cr>", { buffer = true, desc = "Run all specs" })
		vim.keymap.set(
			"n",
			"<leader>rl",
			"<cmd>execute '!bundle exec rspec %:' . line('.')<cr>",
			{ buffer = true, desc = "Run spec at current line" }
		)
	end,
})

-- ============================================================================
-- Frontend (React, TypeScript, JavaScript)
-- ============================================================================
autocmd({ "BufNewFile", "BufRead" }, {
	group = frontend,
	pattern = { "*.jsx", "*.tsx" },
	desc = "Detect React files",
	callback = function()
		local ext = vim.fn.expand("%:e")
		if ext == "jsx" then
			vim.bo.filetype = "javascriptreact"
		elseif ext == "tsx" then
			vim.bo.filetype = "typescriptreact"
		end
	end,
})

-- Package.json keymaps
autocmd("BufEnter", {
	group = frontend,
	pattern = "package.json",
	desc = "Package.json keymaps",
	callback = function()
		vim.keymap.set("n", "<leader>ni", "<cmd>!npm install<cr>", { buffer = true, desc = "npm install" })
		vim.keymap.set("n", "<leader>nr", "<cmd>!npm run ", { buffer = true, desc = "npm run" })
		vim.keymap.set("n", "<leader>ns", "<cmd>!npm start<cr>", { buffer = true, desc = "npm start" })
		vim.keymap.set("n", "<leader>nt", "<cmd>!npm test<cr>", { buffer = true, desc = "npm test" })
	end,
})

-- ============================================================================
-- YAML/Docker/Config Files
-- ============================================================================

autocmd("FileType", {
	group = general,
	pattern = { "yaml", "yml" },
	desc = "YAML specific settings",
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.indentkeys:remove("<:>")
	end,
})

-- Dockerfile detection
autocmd({ "BufNewFile", "BufRead" }, {
	group = general,
	pattern = { "Dockerfile*", "*.dockerfile" },
	desc = "Detect Dockerfiles",
	command = "setfiletype dockerfile",
})

-- -- .env file detection
-- autocmd({ "BufNewFile", "BufRead" }, {
-- 	group = general,
-- 	pattern = { ".env*" },
-- 	desc = "Detect .env files",
-- 	command = "setfiletype sh",
-- })

-- ============================================================================
-- Terminal Specific
-- ============================================================================

-- Terminal settings
autocmd("TermOpen", {
	group = terminal,
	pattern = "*",
	desc = "Terminal settings",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.statusline = " Terminal "
		vim.cmd("startinsert")
	end,
})

-- Auto-enter insert mode when entering terminal
autocmd({ "BufEnter", "BufWinEnter" }, {
	group = terminal,
	pattern = "term://*",
	desc = "Enter insert mode in terminal",
	command = "startinsert",
})

-- Close terminal with q when in normal mode
autocmd("FileType", {
	group = terminal,
	pattern = "terminal",
	desc = "Close terminal with q",
	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
	end,
})

-- ============================================================================
-- Quickfix Window
-- ============================================================================

-- Better quickfix window
autocmd("FileType", {
	group = quickfix,
	pattern = "qf",
	desc = "Better quickfix settings",
	callback = function()
		vim.opt_local.wrap = false
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"

		-- Navigate quickfix with <C-n> and <C-p>
		vim.keymap.set("n", "<C-n>", "<cmd>cnext<cr>zz", { buffer = true })
		vim.keymap.set("n", "<C-p>", "<cmd>cprev<cr>zz", { buffer = true })
	end,
})

-- Auto-close quickfix if it's the last window
autocmd("WinEnter", {
	group = quickfix,
	pattern = "*",
	desc = "Auto-close quickfix if last window",
	callback = function()
		if vim.fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
			vim.cmd("quit")
		end
	end,
})

-- ============================================================================
-- LSP Specific
-- ============================================================================

-- Show diagnostics on cursor hold
autocmd("CursorHold", {
	group = general,
	pattern = "*",
	desc = "Show diagnostics on cursor hold",
	callback = function()
		vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
	end,
})

-- Update diagnostics in insert mode (less aggressive)
autocmd({ "InsertLeave", "TextChanged" }, {
	group = general,
	pattern = "*",
	desc = "Update diagnostics",
	callback = function()
		vim.diagnostic.setloclist({ open = false })
	end,
})

-- ============================================================================
-- File-specific behaviors
-- ============================================================================

-- Markdown settings
autocmd("FileType", {
	group = general,
	pattern = "markdown",
	desc = "Markdown specific settings",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
		vim.opt_local.conceallevel = 2
	end,
})

-- Git commit messages
autocmd("FileType", {
	group = general,
	pattern = { "gitcommit", "gitrebase" },
	desc = "Git commit settings",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.textwidth = 72
		vim.opt_local.wrap = true
	end,
})

-- ============================================================================
-- Project-specific overrides
-- ============================================================================

-- Load project-specific settings if they exist
autocmd("VimEnter", {
	group = general,
	pattern = "*",
	desc = "Load project-specific settings",
	callback = function()
		-- Look for .nvim.lua in project root
		local project_config = vim.fn.getcwd() .. "/.nvim.lua"
		if vim.fn.filereadable(project_config) == 1 then
			dofile(project_config)
		end
	end,
})

-- ============================================================================
-- Performance optimizations
-- ============================================================================

-- Disable certain features in large files
autocmd("BufReadPre", {
	group = general,
	pattern = "*",
	desc = "Disable features for large files",
	callback = function()
		local max_filesize = 100 * 1024 -- 100 KB
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
		if ok and stats and stats.size > max_filesize then
			vim.b.large_file = true
			vim.opt_local.eventignore = "all"
			vim.opt_local.undofile = false
			vim.opt_local.swapfile = false
			vim.opt_local.loadplugins = false
			vim.opt_local.syntax = "off"
			vim.opt_local.foldmethod = "manual"
		end
	end,
})
