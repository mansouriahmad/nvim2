return {
  'tpope/vim-fugitive',
  event = 'VeryLazy',
  config = function()
    -- Enhanced Git fugitive keymaps with better organization
    -- Core Git operations
    vim.keymap.set('n', '<leader>gS', vim.cmd.Git, { desc = 'Git [S]tatus (fugitive)' })
    vim.keymap.set('n', '<leader>gC', function()
      vim.cmd.Git('commit')
    end, { desc = 'Git [C]ommit' })
    vim.keymap.set('n', '<leader>gP', function()
      vim.cmd.Git('push')
    end, { desc = 'Git [P]ush' })
    vim.keymap.set('n', '<leader>gL', function()
      vim.cmd.Git('pull')
    end, { desc = 'Git [L]ull' })

    -- Diff operations
    vim.keymap.set('n', '<leader>gD', function()
      vim.cmd.Gdiffsplit()
    end, { desc = 'Git [D]iff split' })
    vim.keymap.set('n', '<leader>gB', function()
      vim.cmd.Git('blame')
    end, { desc = 'Git [B]lame' })
    vim.keymap.set('n', '<leader>gBr', function()
      vim.cmd.Git('branch')
    end, { desc = 'Git [B]ranch' })
    vim.keymap.set('n', '<leader>gCo', function()
      vim.cmd.Git('checkout')
    end, { desc = 'Git [C]heckout' })
    vim.keymap.set('n', '<leader>gLog', function()
      vim.cmd.Git('log')
    end, { desc = 'Git [L]og' })

    -- Advanced diff operations
    vim.keymap.set('n', '<leader>gdf', function()
      vim.cmd.Git('diff')
    end, { desc = 'Git [D]iff all [F]iles' })
    vim.keymap.set('n', '<leader>gdc', function()
      vim.cmd.Git('diff --cached')
    end, { desc = 'Git [D]iff [C]ached files' })
    vim.keymap.set('n', '<leader>gdh', function()
      vim.cmd.Git('diff HEAD')
    end, { desc = 'Git [D]iff vs [H]EAD' })
    vim.keymap.set('n', '<leader>gdm', function()
      vim.cmd.Git('diff main')
    end, { desc = 'Git [D]iff vs [M]ain branch' })

    -- Quick commit workflow
    vim.keymap.set('n', '<leader>gcc', function()
      vim.cmd.Git('commit -m "')
    end, { desc = 'Git [C]ommit with [C]ustom message' })

    -- Merge and rebase operations
    vim.keymap.set('n', '<leader>gM', function()
      vim.cmd.Git('merge')
    end, { desc = 'Git [M]erge' })
    vim.keymap.set('n', '<leader>gR', function()
      vim.cmd.Git('rebase')
    end, { desc = 'Git [R]ebase' })

    -- Stash operations
    vim.keymap.set('n', '<leader>gSt', function()
      vim.cmd.Git('stash')
    end, { desc = 'Git [S]tash' })
    vim.keymap.set('n', '<leader>gSp', function()
      vim.cmd.Git('stash pop')
    end, { desc = 'Git [S]tash [P]op' })
    vim.keymap.set('n', '<leader>gSl', function()
      vim.cmd.Git('stash list')
    end, { desc = 'Git [S]tash [L]ist' })

    -- Enhanced diff viewing with Fugitive
    vim.keymap.set('n', '<leader>gV', function()
      vim.cmd('Gdiffsplit')
    end, { desc = 'Open diff split (VS Code-like diff)' })

    vim.keymap.set('n', '<leader>gH', function()
      vim.cmd('Git log --oneline %')
    end, { desc = 'File history' })

    -- Enhanced staging/unstaging keymaps
    vim.keymap.set('n', '<leader>ga', function()
      vim.cmd.Git('add .')
    end, { desc = 'Stage all files' })

    vim.keymap.set('n', '<leader>gu', function()
      vim.cmd.Git('reset')
    end, { desc = 'Unstage all files' })

    vim.keymap.set('n', '<leader>gA', function()
      vim.cmd.Git('add %')
    end, { desc = 'Stage current file' })

    vim.keymap.set('n', '<leader>gU', function()
      vim.cmd.Git('reset %')
    end, { desc = 'Unstage current file' })

    -- Enhanced keymaps for Git status buffer
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fugitive',
      callback = function()
        -- Stage/unstage files in Git status buffer
        vim.keymap.set('n', 's', function()
          vim.cmd('Git add ' .. vim.fn.expand('<cfile>'))
        end, { buffer = true, desc = 'Stage file' })

        vim.keymap.set('n', 'u', function()
          vim.cmd('Git reset ' .. vim.fn.expand('<cfile>'))
        end, { buffer = true, desc = 'Unstage file' })

        -- Stage/unstage all files
        vim.keymap.set('n', 'S', function()
          vim.cmd('Git add .')
        end, { buffer = true, desc = 'Stage all files' })

        vim.keymap.set('n', 'U', function()
          vim.cmd('Git reset')
        end, { buffer = true, desc = 'Unstage all files' })

        -- Open diff view
        vim.keymap.set('n', 'dv', function()
          vim.cmd('Gdiffsplit ' .. vim.fn.expand('<cfile>'))
        end, { buffer = true, desc = 'Open diff view' })

        -- Commit operations
        vim.keymap.set('n', 'cc', function()
          vim.cmd('Git commit')
        end, { buffer = true, desc = 'Commit' })

        vim.keymap.set('n', 'ca', function()
          vim.cmd('Git commit --amend')
        end, { buffer = true, desc = 'Amend commit' })

        vim.keymap.set('n', 'cA', function()
          vim.cmd('Git commit --amend --no-edit')
        end, { buffer = true, desc = 'Amend commit (no edit)' })

        -- Push/Pull operations
        vim.keymap.set('n', 'pp', function()
          vim.cmd('Git push')
        end, { buffer = true, desc = 'Push' })

        vim.keymap.set('n', 'pl', function()
          vim.cmd('Git pull')
        end, { buffer = true, desc = 'Pull' })

        -- Branch operations
        vim.keymap.set('n', 'bb', function()
          vim.cmd('Git branch')
        end, { buffer = true, desc = 'List branches' })

        vim.keymap.set('n', 'bc', function()
          vim.cmd('Git checkout -b ')
        end, { buffer = true, desc = 'Create new branch' })

        -- Stash operations
        vim.keymap.set('n', 'st', function()
          vim.cmd('Git stash')
        end, { buffer = true, desc = 'Stash' })

        vim.keymap.set('n', 'sp', function()
          vim.cmd('Git stash pop')
        end, { buffer = true, desc = 'Stash pop' })

        -- Refresh status
        vim.keymap.set('n', 'r', function()
          vim.cmd('edit')
        end, { buffer = true, desc = 'Refresh status' })

        -- Toggle file details
        vim.keymap.set('n', 't', function()
          vim.cmd('Git status --porcelain')
        end, { buffer = true, desc = 'Toggle file details' })
      end,
    })

    -- Enhanced keymaps for Git commit buffer
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'gitcommit',
      callback = function()
        -- Quick commit message templates
        vim.keymap.set('i', '<C-t>', function()
          local templates = {
            'feat: ',
            'fix: ',
            'docs: ',
            'style: ',
            'refactor: ',
            'test: ',
            'chore: ',
          }
          -- Simple template insertion (you could enhance this with telescope)
          vim.cmd('startinsert')
        end, { buffer = true, desc = 'Insert commit template' })

        -- Auto-wrap at 72 characters
        vim.opt_local.textwidth = 72
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
      end,
    })
  end
}
