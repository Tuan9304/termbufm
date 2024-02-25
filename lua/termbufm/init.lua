local termbufm_window = -1
local termbufm_buffer = -1
local termbufm_job_id = -1

local config = {
    termbufm_direction_cmd = 'new',
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
        termbufm_job_id = vim.api.nvim_open_term(termbufm_buffer)

        -- change name of buffer
        vim.api.nvim_buf_set_name(termbufm_buffer, 'termbufm_b')
        
        -- unload the buffer when close
        vim.bo[termbufm_buffer].bufhidden = 'unload'

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
        vim.api.nvim_win_hide(termbufm_window)
    end
end

local TermBufMToggle = function()
    if vim.api.nvim_buf_is_loaded(termbufm_buffer) then
        TermBufMClose()
    else
        TermBufMOpen()
    end
end

return {
    setup = setup,
    toggle = TermBufMToggle,
}
