local termbufm_window = -1
local termbufm_buffer = -1
local termbufm_job_id = -1

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
    -- TODO: add setup
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

    elseif not vim.api.nvim_buf_is_loaded(termbufm_buffer) then
        -- open the buffer in a split window
        vim.cmd(direction)

        termbufm_window = vim.api.nvim_get_current_win()

        vim.api.nvim_win_set_buf(termbufm_window, termbufm_buffer)
    end
end

local TermBufMClose = function()
    if vim.api.nvim_buf_is_loaded(termbufm_buffer) then
        vim.api.nvim_buf_delete(termbufm_buffer, { unload = true, force = true })
    end
end

local TermBufMToggle = function()
    if vim.api.nvim_buf_is_loaded(termbufm_buffer) then
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
    -- not complete
end

return {
    setup = setup,
    toggle = TermBufMToggle,
    exec = TermBufMExecCodeScript,
}
