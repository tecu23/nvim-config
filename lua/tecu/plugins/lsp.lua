-- ============================================================================
-- LSP Plugins Configuration for Lazy.nvim
-- ============================================================================

return {
	-- ============================================================================
	-- Core LSP Configuration
	-- ============================================================================
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- LSP Management
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "saghen/blink.cmp" },

			-- Useful status updates for LSP
			{
				"j-hui/fidget.nvim",
				config = function()
					require("fidget").setup({
						notification = {
							window = {
								winblend = 0,
								relative = "editor",
							},
						},
					})
				end,
			},

			-- Additional lua configuration, makes nvim stuff amazing
			{ "folke/neodev.nvim", opts = {} },

			-- Schema information for JSON/YAML
			{ "b0o/schemastore.nvim" },
		},
		config = function()
			require("tecu.lsp").setup()
		end,
	},

	-- ============================================================================
	-- Mason - Package Manager for LSP servers, DAP servers, linters, formatters
	-- ============================================================================
	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
		build = ":MasonUpdate",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
					width = 0.8,
					height = 0.8,
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
				log_level = vim.log.levels.DEBUG,
				max_concurrent_installers = 4,
			})
		end,
	},

	-- ============================================================================
	-- TypeScript Tools (Better TypeScript support than ts_ls)
	-- ============================================================================
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		opts = {
			settings = {
				-- spawn additional tsserver instance to calculate diagnostics on it
				separate_diagnostic_server = true,
				-- "change"|"insert_leave" determine when the client asks the server about diagnostic
				publish_diagnostic_on = "insert_leave",
				-- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
				-- "remove_unused_imports"|"organize_imports") -- or string "all"
				expose_as_code_action = "all",
				-- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
				-- not exists then standard path resolution strategy is applied
				tsserver_path = nil,
				-- specify a list of plugins to load by tsserver
				tsserver_plugins = {},
				-- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
				tsserver_max_memory = "auto",
				-- described below
				tsserver_format_options = {},
				tsserver_file_preferences = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayVariableTypeHintsWhenTypeMatchesName = false,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
					includeCompletionsForModuleExports = true,
					quotePreference = "auto",
					allowTextChangesInNewFiles = true,
					providePrefixAndSuffixTextForRename = true,
				},
				-- locale of all tsserver messages
				tsserver_locale = "en",
				-- mirror of VSCode's code_lens_on
				complete_function_calls = true,
				include_completions_with_insert_text = true,
				-- CodeLens
				code_lens = "all", -- "off" | "all" | "implementations_only" | "references_only"
				-- disable_member_code_lens = true, -- true | false
				-- JSX specific settings
				jsx_close_tag = {
					enable = true,
					filetypes = { "javascriptreact", "typescriptreact" },
				},
			},
			handlers = {
				-- Custom handler to change severity of specific diagnostics
				["textDocument/publishDiagnostics"] = function(err, params, ctx)
					-- Modify diagnostics before they're processed
					if params.diagnostics then
						for _, diagnostic in ipairs(params.diagnostics) do
							-- Change unused variable errors to warnings
							if diagnostic.code == 6133 or diagnostic.code == 6196 then -- TS unused variable codes
								diagnostic.severity = vim.diagnostic.severity.WARN
							end
							-- You can add more specific diagnostic code modifications here
						end
					end
					-- Call the default handler
					vim.lsp.diagnostic.on_publish_diagnostics(err, params, ctx)
				end,
			},
		},
	},

	-- ============================================================================
	-- Autocompletion
	-- ============================================================================
	{
		"saghen/blink.cmp",
		--  provides snippets for the snippet source
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
				build = "make install_jsregexp",
				dependencies = {
					"rafamadriz/friendly-snippets",
				},
			},
			"folke/lazydev.nvim",
			"onsails/lspkind.nvim",
		},

		-- use a release tag to download pre-built binaries
		version = "1.*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default",

				-- Show/Hide
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide" },
				["<C-y>"] = { "select_and_accept" },
				--
				-- Select prev/next
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback_to_mappings" },
				["<C-n>"] = { "select_next", "fallback_to_mappings" },

				-- Scroll
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },

				-- Tab management
				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },

				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},

			appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- will be removed in a future release
				use_nvim_cmp_as_default = true,
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
				kind_icons = {
					Text = "󰉿",
					Method = "󰊕",
					Function = "󰊕",
					Constructor = "",
					Field = "󰇽",
					Variable = "󰂡",
					Class = "󰠱",
					Interface = "",
					Module = "",
					Property = "󰜢",
					Unit = "",
					Value = "󰎠",
					Enum = "",
					Keyword = "󰌋",
					Snippet = "",
					Color = "󰏘",
					File = "󰈙",
					Reference = "",
					Folder = "󰉋",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "󰅲",
				},
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},

			completion = {
				list = {
					max_items = 200,
					selection = { preselect = true, auto_insert = true },
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = {
						border = "rounded",
						winblend = 0,
						winhighlight = "Normal:Normal,FloatBorder:BorderBG,Search:None",
					},
				},

				menu = {
					enabled = true,
					border = "rounded",
					winblend = 0,
					winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind", "source_name", gap = 1 },
						},
					},
				},

				-- Ghost text (v1.x experimental feature)
				ghost_text = {
					enabled = true,
				},

				-- Accept configuration
				accept = {
					auto_brackets = {
						enabled = false,
					},
				},
			},

			cmdline = {
				keymap = { preset = "inherit" },
				completion = {
					menu = { auto_show = true },
					ghost_text = { enabled = true },
					list = {
						selection = {
							preselect = true,
							auto_insert = true,
						},
					},
				},
				sources = {
					"buffer",
					"cmdline",
					-- -- For search
					-- ["/"] = { "buffer" },
					-- ["?"] = { "buffer" },
					-- -- For command mode
					-- [":"] = { "path", "cmdline" },
				},
			},

			-- Signature help configuration
			signature = {
				enabled = true,
				window = {
					border = "rounded",
					winblend = 0,
				},
			},

			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				active = function(filter)
					if filter and filter.direction then
						return require("luasnip").jumpable(filter.direction)
					end
					return require("luasnip").in_snippet()
				end,
				jump = function(direction)
					require("luasnip").jump(direction)
				end,
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
		config = function(_, opts)
			require("blink-cmp").setup(opts)

			-- Load friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	-- ============================================================================
	-- Formatting
	-- ============================================================================
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = { "n", "v" },
				desc = "[F]ormat Buffer",
			},
		},
		opts = {
			notify_on_error = true,
			formatters_by_ft = {
				asm = { "asmfmt" },
				lua = { "stylua" },

				cpp = { "clang-format" },

				python = { "isort", "black" },

				css = { "prettierd" },
				scss = { "prettierd" },
				html = { "prettierd" },
				yaml = { "prettierd" },
				json = { "prettierd" },
				markdown = { "prettierd" },
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescriptreact = { "prettierd" },

				go = { "gofmt" },

				sql = { "sqlfmt" },

				ruby = { "rubocop" },

				rust = { "rustfmt" },

				-- sh = { "shfmt" },
				["*"] = { "trim_whitespace" },
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				-- Reduced from 10000ms to 3000ms for faster saves
				return { timeout_ms = 3000, lsp_fallback = true }
			end,
		},
	},

	-- ============================================================================
	-- Linting
	-- ============================================================================
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				javascript = { "eslint" },
				typescript = { "eslint" },
				javascriptreact = { "eslint" },
				typescriptreact = { "eslint" },

				python = { "flake8" }, -- Only use flake8 until I make pylint work with conda envs

				ruby = { "rubocop" },

				go = { "golangcilint" },

				json = { "jsonlint" },

				markdown = { "markdownlint" },

				yaml = { "yamllint" },

				dockerfile = { "hadolint" },

				bash = { "shellcheck" },
				sh = { "shellcheck" },
				-- make = { "checkmate" },
			}

			-- Create autocommand which carries out the actual linting
			-- on the specified events.
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},

	-- ============================================================================
	-- Trouble - Better diagnostics list
	-- ============================================================================
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Trouble", "TroubleToggle" },
		opts = {
			position = "bottom",
			height = 10,
			width = 50,
			icons = true,
			mode = "workspace_diagnostics",
			fold_open = "",
			fold_closed = "",
			group = true,
			padding = true,
			action_keys = {
				close = "q",
				cancel = "<esc>",
				refresh = "r",
				jump = { "<cr>", "<tab>" },
				open_split = { "<c-x>" },
				open_vsplit = { "<c-v>" },
				open_tab = { "<c-t>" },
				jump_close = { "o" },
				toggle_mode = "m",
				toggle_preview = "P",
				hover = "K",
				preview = "p",
				close_folds = { "zM", "zm" },
				open_folds = { "zR", "zr" },
				toggle_fold = { "zA", "za" },
				previous = "k",
				next = "j",
			},
			indent_lines = true,
			auto_open = false,
			auto_close = false,
			auto_preview = true,
			auto_fold = false,
			auto_jump = { "lsp_definitions" },
			sign_priority = 6,
			use_diagnostic_signs = false,
		},
	},

	-- ============================================================================
	-- Inlay Hints (if not using Neovim 0.10+)
	-- ============================================================================
	{
		"lvimuser/lsp-inlayhints.nvim",
		branch = "anticonceal",
		event = "LspAttach",
		opts = {},
	},
}
