local termbufm_window = -1
local termbufm_buffer = -1
local termbufm_job_id = -1
local termbufm_cache = {}

local config = {
    termbufm_direction_cmd = 'new',
    termbufm_code_scripts = {
        cpp = {
            build = { 'g++ %s', '%' },
            run = { './a.out' },
        },
    },
}

local setup = function(opts)
    if opts == nil then
        return
    end

    if opts.termbufm_direction_cmd == 'vnew' then
        config.termbufm_direction_cmd = 'vnew'
    end

    if type(opts.termbufm_code_scripts) == 'table' then
        config.termbufm_code_scripts = opts.termbufm_code_scripts
    end
end

local TermBufMOpen = function()
    local direction = config.termbufm_direction_cmd
    if not vim.api.nvim_buf_is_valid(termbufm_buffer) then
        -- create the termbufm buffer
        vim.cmd(direction)

        -- get window and buffer ids
        termbufm_window = vim.api.nvim_get_current_win()
        termbufm_buffer = vim.api.nvim_get_current_buf()

        -- get terminal job id
        termbufm_job_id = vim.fn.termopen(vim.env.SHELL)

        -- change name of buffer
        vim.api.nvim_buf_set_name(termbufm_buffer, 'termbufm_b')

        -- don't show in buffer list
        vim.bo[termbufm_buffer].buflisted = false
        
        -- don't show line numbers
        vim.wo[termbufm_window].number = false
        vim.wo[termbufm_window].relativenumber = false

    elseif not vim.api.nvim_win_is_valid(termbufm_window) then
        -- open the buffer in a split window
        vim.cmd(direction)

        termbufm_window = vim.api.nvim_get_current_win()

        vim.api.nvim_win_set_buf(termbufm_window, termbufm_buffer)
    end
end

local TermBufMClose = function()
    if vim.api.nvim_win_is_valid(termbufm_window) then
        vim.api.nvim_win_hide(termbufm_window)
    end
end

local TermBufMToggle = function()
    if vim.api.nvim_win_is_valid(termbufm_window) then
        TermBufMClose()
    else
        TermBufMOpen()
    end
end

local TermBufMExec = function(cmd)
    -- open if needed
    if not vim.api.nvim_buf_is_loaded(termbufm_buffer) then
        TermBufMOpen()
    end

    -- send command
    vim.api.nvim_chan_send(termbufm_job_id, cmd .. '\n')

    -- go to bottom
    vim.cmd.normal('G')

    -- go to previous window where you came from
    vim.cmd.wincmd('p')
end

local TermBufMExecCodeScript = function(filetype, commandtype)
    assert(config.termbufm_code_scripts[filetype] ~= nil, "filetype not found: " .. filetype)
    assert(config.termbufm_code_scripts[filetype][commandtype] ~= nil, "command type not found: " .. commandtype)

    if termbufm_cache[filetype] == nil then
        termbufm_cache[filetype] = { commandtype = nil }
    end
    
    if termbufm_cache[filetype][commandtype] == nil then
        local fmtstr = config.termbufm_code_scripts[filetype][commandtype]
        for i = 2,#fmtstr do
            fmtstr[i] = vim.fn.expand(fmtstr[i])
        end
        termbufm_cache[filetype][commandtype] = vim.fn.call('printf', fmtstr)
    end

    TermBufMExec(termbufm_cache[filetype][commandtype])
end

return {
    setup = setup,
    toggle = TermBufMToggle,
    code_exec = TermBufMExecCodeScript,
    exec = TermBufMExec,
}
