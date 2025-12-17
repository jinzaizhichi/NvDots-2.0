local M = {}

-- =============================================================================
-- DATA
-- =============================================================================
M.mappings = {
    { header = "Core" },
    { key = "<Space>",    desc = "Leader Key" },
    { key = "<Leader>w",  desc = "Save File" },
    { key = "<Leader>q",  desc = "Quit" },
    { key = "w!!",        desc = "Save as Root (sudo)" },

    { header = "Navigation" },
    { key = "<Leader>ff", desc = "Find Files" },
    { key = "<Leader>fg", desc = "Find Git Files" },
    { key = "<Leader>/",  desc = "Grep Text" },
    { key = "<Leader>,",  desc = "Switch Buffers" },

    { header = "LSP & Code" },
    { key = "gd",         desc = "Go to Definition" },
    { key = "gr",         desc = "Find References" },
    { key = "K",          desc = "Hover Doc" },
    { key = "<Leader>ca", desc = "Code Action" },
    { key = "<Leader>rn", desc = "Rename" },
    { key = "<Leader>=",  desc = "Format File" },

    { header = "Utils" },
    { key = "<Leader>z",  desc = "Toggle Zen Mode" },
    { key = ":Cls",       desc = "Clear Trailing Spaces" },
    { key = ":Run",       desc = "Run Code" },
    { key = ":Dos2Unix",  desc = "Convert Line Endings" },
}

-- =============================================================================
-- UI LOGIC
-- =============================================================================
function M.show()
    local buf = vim.api.nvim_create_buf(false, true)
    local ns_id = vim.api.nvim_create_namespace("CheatsheetHighlights")
    
    local lines = {}
    
    -- This table will store where to apply colors: { line_index, start_col, end_col, hl_group }
    local highlights = {} 

    -- Iterate and build lines
    for _, map in ipairs(M.mappings) do
        local line_idx = #lines -- current line index
        
        if map.header then
            -- HEADER ROW
            table.insert(lines, "") -- Add spacing
            table.insert(lines, "  " .. map.header)
            
            -- Highlight the Header 
            -- Changed from "Title" to "Directory" (Usually Blue/Cyan) for a fresh look
            table.insert(highlights, { #lines - 1, 0, -1, "Directory" })
        else
            -- MAPPING ROW
            -- Format:  <key>   ...padding...   <desc>
            local key_str = "  " .. map.key
            local padding = string.rep(" ", 18 - #map.key)
            local full_line = key_str .. padding .. map.desc
            
            table.insert(lines, full_line)

            -- Highlight the Key (Function color - usually Blue/Yellow)
            table.insert(highlights, { line_idx, 0, #key_str, "Function" })
            
            -- Highlight the Description (String color - usually Green/Peach)
            -- Start highlighting after the padding
            local desc_start = #key_str + #padding
            table.insert(highlights, { line_idx, desc_start, -1, "String" })
        end
    end

    -- Set buffer content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- APPLY DYNAMIC HIGHLIGHTS
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(buf, ns_id, hl[4], hl[1], hl[2], hl[3])
    end

    -- Window Calculation
    local width = 0
    for _, l in ipairs(lines) do if #l > width then width = #l end end
    width = width + 4
    local height = #lines
    local ui = vim.api.nvim_list_uis()[1]
    local row = (ui.height - height) / 2
    local col = (ui.width - width) / 2

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " KEY MAPPING CHEATSHEET ",
        title_pos = "center"
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Apply 'FloatBorder' highlight to match theme
    vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")

    -- Keymaps to close
    local close_cmd = string.format("<cmd>lua vim.api.nvim_win_close(%d, true)<CR>", win)
    for _, key in ipairs({"q", "Q", "<Esc>", "<CR>", "<Space>"}) do
        vim.keymap.set("n", key, close_cmd, { buffer = buf, nowait = true, silent = true })
    end
    
    vim.opt_local.cursorline = true
    vim.opt_local.modifiable = false
end

return M
