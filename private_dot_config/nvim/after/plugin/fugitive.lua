vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.keymap.set("n", "<leader>gf", ":Gdiffsplit<CR>")
vim.keymap.set("n", "<leader>gp", ":G push<CR>")
vim.keymap.set("n", "<leader>gb", function()
    local branch_name = vim.fn.input("New branch name: ")

    if branch_name ~= "" then
        vim.cmd("Git checkout -b " .. branch_name)
    else
        print("Branch name cannot be empty")
    end
end)
vim.keymap.set("n", "<leader>gc", function()
    local branch_name = vim.fn.input("Checkout branch: ")

    if branch_name ~= "" then
        vim.cmd("Git checkout " .. branch_name)
    else
        print("Branch name cannot be empty")
    end
end)
