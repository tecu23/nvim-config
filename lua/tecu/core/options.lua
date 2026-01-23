-- ============================================================================
-- Neovim Options Configuration for Full-Stack Development
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- ============================================================================
-- Line Numbers & Display
-- ============================================================================
opt.number = true -- Show absolute line numbers
opt.relativenumber = true -- Show relative line numbers (hybrid mode with number)
opt.cursorline = true -- Highlight the line nwhere the cursor is
opt.signcolumn = "yes" -- Always show sign column (prevents text shift)
-- opt.colorcolumn = "80,120" -- ?? Highlight columns 80 and 120 (common line length limits)
opt.wrap = false -- Don't wrap long lines
opt.linebreak = true -- If wrap is enabled, break at word boundaries
opt.showbreak = "↪ " -- String to show at the start of wrapped lines

-- ============================================================================
-- Indentation & Formatting
-- ============================================================================
opt.expandtab = true -- Convert tabs to spaces
opt.tabstop = 4 -- Number of spaces tabs count for
opt.shiftwidth = 4 -- Size of an indent
opt.softtabstop = 4 -- Number of spaces tab counts for in insert mode
opt.smartindent = true -- Smart autoindenting on new lines
opt.autoindent = true -- Copy indent from current line when starting new line
opt.breakindent = true -- Preserve indentation in wrapped lines
opt.shiftround = true -- Round indent to multiple of shiftwidth

-- Format options (use += and -= to add/remove flags)
opt.formatoptions:remove({ "c", "r", "o" }) -- Don't auto-insert comment leader

-- ============================================================================
-- Search & Replace
-- ============================================================================
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- Case-sensitive if search contains capitals
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Show search matches as you type
opt.inccommand = "split" -- Line preview of :substitute commands
opt.gdefault = true -- ?? Add g flag to search/replace by default

-- ============================================================================
-- UI & Visual Settings
-- ============================================================================
g.have_nerd_font = true -- Enable Nerd Font
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.showmode = false -- Don't show mode (shown in statusline)
opt.showcmd = true -- Show partial commands in the last line
opt.cmdheight = 1 -- ?? Command line height
opt.laststatus = 3 -- ?? Global statusline
opt.showtabline = 0 -- ?? Always show tabline
opt.pumheight = 10 -- Maximum number of items in popup menu
opt.pumblend = 0 -- Popup menu transparency (0-100)
opt.winblend = 0 -- Window transparency (0-100)
opt.conceallevel = 0 -- Don't hide text with conceal syntax
opt.list = true -- Show invisible characters
opt.listchars = { -- Define which invisible characters to show
	tab = "→ ",
	trail = "·",
	-- lead = "·",
	extends = "»",
	precedes = "«",
	nbsp = "␣",
	-- eol = "↲",
}
opt.fillchars = { -- Characters for UI elements
	eob = " ", -- Empty lines at the end of buffer
	fold = " ",
	foldopen = "",
	foldsep = " ",
	foldclose = "",
	lastline = " ",
	diff = "╱",
}

-- ============================================================================
-- Editor Behavior
-- ============================================================================
opt.mouse = "a" -- Enable mouse support in all modes
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.undofile = true -- Persistent undo history
opt.undolevels = 10000 -- Maximum number of undo levels
opt.swapfile = false -- Don't create swap files
opt.backup = false -- Don't create backup files
opt.writebackup = false -- Don't create backup before overwriting
opt.updatetime = 2000 -- Trigger CursorHold events (increased to 2s to prevent gopls freezes)
opt.timeoutlen = 300 -- Time to wait for mapped sequence (ms)
opt.ttimeoutlen = 10 -- Time to wait for key code sequence
opt.hidden = true -- Allow switching buffers without saving
opt.autoread = true -- Auto-reload files changed outside Neovim
opt.confirm = true -- Ask for confirmation instead of erroring
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.backspace = "indent,eol,start" -- Allow backspace over everything

-- ============================================================================
-- Scrolling
-- ============================================================================
opt.scrolloff = 20 -- Minimum lines to keep above/below cursor
opt.sidescrolloff = 20 -- Minimum columns to keep left/right of cursor
opt.smoothscroll = true -- Smooth scrolling (Neovim 0.10+)

-- ============================================================================
-- Splits & Windows
-- ============================================================================
opt.splitright = true -- Horizontal splits go below current window
opt.splitbelow = true -- Vertical splits go to the right
opt.splitkeep = "screen" -- Keep the text on the same screen line
opt.equalalways = false -- Don't autoresize windows to be equal

-- ============================================================================
-- Folding
-- ============================================================================
opt.foldmethod = "expr" -- Use treesitter for folding
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99 -- Start with all folds open
opt.foldlevelstart = 99 -- Start with all folds open
opt.foldenable = true -- Enable folding
opt.foldcolumn = "1" -- Don't show fold column

-- ============================================================================
-- Completion
-- ============================================================================
opt.completeopt = { "menu", "menuone", "noselect" } -- Completion options
opt.wildmenu = true -- Enhanced command line completion
opt.wildmode = "longest:full,full" -- Command line completion mode
opt.wildignorecase = true -- Case insensitive filename completion
opt.infercase = true -- Infer case in completion

-- Ignore these files/folders in completions
opt.wildignore:append({
	"*.o",
	"*.obj",
	"*.pyc",
	"*.pyo",
	"*.pyd",
	"*.dll",
	"*.class",
	"*.jpg",
	"*.jpeg",
	"*.png",
	"*.gif",
	"*.bmp",
	"*.ico",
	"*.pdf",
	"*.doc",
	"*.docx",
	".git",
	".svn",
	".hg",
	"__pycache__",
	"*.egg-info",
	"node_modules",
	"bower_components",
	".sass-cache",
	"*.min.js",
	"*.min.css",
	".DS_Store",
	"Thumbs.db",
	"*.swp",
	"*.swo",
	"*~",
	"._*",
})

-- ============================================================================
-- Performance
-- ============================================================================
opt.lazyredraw = false -- Don't redraw during macros (can cause issues)
opt.redrawtime = 1500 -- Time limit for syntax highlighting (ms)
opt.synmaxcol = 300 -- Maximum column for syntax highlighting
opt.ttyfast = true -- Faster terminal connection

-- ============================================================================
-- Spell Checking
-- ============================================================================
opt.spell = false -- Disable spell checking by default
opt.spelllang = { "en_us" } -- Language for spell checking

-- ============================================================================
-- File Specific Settings
-- ============================================================================
opt.encoding = "utf-8" -- Internal encoding
opt.fileencoding = "utf-8" -- File encoding
opt.fileformat = "unix" -- Use Unix line endings
opt.fixendofline = false -- Don't add newline at end of file

-- ============================================================================
-- Session Options
-- ============================================================================
opt.sessionoptions = {
	"buffers",
	"curdir",
	"tabpages",
	"winsize",
	"help",
	"globals",
	"skiprtp",
	"folds",
}

-- ============================================================================
-- Grep Program (use ripgrep if available)
-- ============================================================================
if vim.fn.executable("rg") == 1 then
	opt.grepprg = "rg --vimgrep --smart-case --hidden"
	opt.grepformat = "%f:%l:%c:%m"
end

-- ============================================================================
-- Disable Built-in Plugins (for faster startup)
-- ============================================================================
local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
}

for _, plugin in pairs(disabled_built_ins) do
	g["loaded_" .. plugin] = 1
end
