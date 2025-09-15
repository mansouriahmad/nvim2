return {
  -- nvim-dap: Debug Adapter Protocol client
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_virtual_text = require("nvim-dap-virtual-text")

      -- Setup virtual text
      dap_virtual_text.setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = "<module",
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Check if project needs rebuilding by comparing modification times
      local function needs_rebuild()
        local cwd = vim.fn.getcwd()
        local cargo_toml = cwd .. "/Cargo.toml"
        
        if vim.fn.filereadable(cargo_toml) == 0 then
          return false
        end

        -- Get project name and executable path
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        local os = vim.loop.os_uname().sysname:lower()
        local executable_name = project_name
        if os == "windows" or os == "windows_nt" then
          executable_name = project_name .. ".exe"
        end

        local debug_path = cwd .. "/target/debug/" .. executable_name
        
        -- If executable doesn't exist, we need to build
        if vim.fn.filereadable(debug_path) == 0 then
          return true
        end

        -- Get executable modification time
        local executable_stat = vim.loop.fs_stat(debug_path)
        if not executable_stat then
          return true
        end

        local executable_mtime = executable_stat.mtime.sec

        -- Check if any Rust source files are newer than the executable
        local rust_files = vim.fn.glob(cwd .. "/src/**/*.rs", false, true)
        for _, file in ipairs(rust_files) do
          local file_stat = vim.loop.fs_stat(file)
          if file_stat and file_stat.mtime.sec > executable_mtime then
            return true
          end
        end

        -- Check Cargo.toml and Cargo.lock
        local cargo_lock = cwd .. "/Cargo.lock"
        if vim.fn.filereadable(cargo_lock) == 1 then
          local lock_stat = vim.loop.fs_stat(cargo_lock)
          if lock_stat and lock_stat.mtime.sec > executable_mtime then
            return true
          end
        end

        local cargo_toml_stat = vim.loop.fs_stat(cargo_toml)
        if cargo_toml_stat and cargo_toml_stat.mtime.sec > executable_mtime then
          return true
        end

        return false
      end

      -- Intelligent executable detection and building
      local function find_or_build_executable(force_build)
        local cwd = vim.fn.getcwd()
        local cargo_toml = cwd .. "/Cargo.toml"
        
        if vim.fn.filereadable(cargo_toml) == 0 then
          vim.notify("No Cargo.toml found in current directory", vim.log.levels.ERROR)
          return nil
        end

        -- Get project name from Cargo.toml
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        local os = vim.loop.os_uname().sysname:lower()
        local executable_name = project_name
        if os == "windows" or os == "windows_nt" then
          executable_name = project_name .. ".exe"
        end

        local debug_path = cwd .. "/target/debug/" .. executable_name
        
        -- Check if we need to build (either executable doesn't exist or source files are newer)
        if force_build or needs_rebuild() then
          vim.notify("Building project...", vim.log.levels.INFO)
          
          -- Build the project
          local build_cmd = "cargo build"
          local result = vim.fn.system(build_cmd)
          
          if vim.v.shell_error ~= 0 then
            vim.notify("Build failed: " .. result, vim.log.levels.ERROR)
            return nil
          end
          
          vim.notify("Build successful!", vim.log.levels.INFO)
        end

        return debug_path
      end

      -- Cross-platform debugger detection and configuration
      local function get_debugger_config(force_build)
        local os = vim.loop.os_uname().sysname:lower()
        local executable_path = find_or_build_executable(force_build)
        
        if not executable_path then
          return nil
        end

        local config = {}

        if os == "windows" or os == "windows_nt" then
          -- Windows configuration - use codelldb from Mason
          config = {
            type = "codelldb",
            request = "launch",
            name = "Debug Rust (Windows)",
            program = executable_path,
            args = {},
            stopOnEntry = false,
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            sourceLanguages = { "rust" },
          }
        elseif os == "darwin" then
          -- macOS configuration - use codelldb from Mason
          config = {
            type = "codelldb",
            request = "launch",
            name = "Debug Rust (macOS)",
            program = executable_path,
            args = {},
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            console = "integratedTerminal",
            sourceLanguages = { "rust" },
          }
        else
          -- Linux configuration - use codelldb from Mason
          config = {
            type = "codelldb",
            request = "launch",
            name = "Debug Rust (Linux)",
            program = executable_path,
            args = {},
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            console = "integratedTerminal",
            sourceLanguages = { "rust" },
          }
        end

        return config
      end

      -- Setup DAP adapters - use codelldb from Mason
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- Function to find or build test executable
      local function find_or_build_test_executable(test_name)
        local cwd = vim.fn.getcwd()
        local cargo_toml = cwd .. "/Cargo.toml"
        
        if vim.fn.filereadable(cargo_toml) == 0 then
          vim.notify("No Cargo.toml found in current directory", vim.log.levels.ERROR)
          return nil
        end

        -- Build tests first
        vim.notify("Building tests...", vim.log.levels.INFO)
        local build_cmd = "cargo test --no-run"
        local result = vim.fn.system(build_cmd)
        
        if vim.v.shell_error ~= 0 then
          vim.notify("Test build failed: " .. result, vim.log.levels.ERROR)
          return nil
        end

        -- Find the test executable
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        local os = vim.loop.os_uname().sysname:lower()
        local executable_name = project_name
        if os == "windows" or os == "windows_nt" then
          executable_name = executable_name .. ".exe"
        end

        -- Look for test executables in target/debug/deps
        local deps_dir = cwd .. "/target/debug/deps/"
        local test_executables = vim.fn.glob(deps_dir .. executable_name .. "-*", false, true)
        
        if #test_executables > 0 then
          return test_executables[1]
        end

        vim.notify("No test executable found", vim.log.levels.ERROR)
        return nil
      end

      -- Rust debug configuration
      dap.configurations.rust = {
        get_debugger_config(),
        -- Test debugging configuration
        {
          type = "codelldb",
          request = "launch",
          name = "Debug Rust Test",
          program = function()
            return find_or_build_test_executable()
          end,
          args = {},
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          console = "integratedTerminal",
          sourceLanguages = { "rust" },
        },
        -- Manual executable selection
        {
          type = "codelldb",
          request = "launch",
          name = "Debug Rust (Manual)",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          args = {},
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          console = "integratedTerminal",
          sourceLanguages = { "rust" },
        },
        -- Attach configuration
        {
          type = "codelldb",
          request = "attach",
          name = "Attach to Rust Process",
          pid = function()
            return tonumber(vim.fn.input("Process ID: "))
          end,
          cwd = "${workspaceFolder}",
          sourceLanguages = { "rust" },
        },
      }

      -- Setup DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏭",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "⏮",
            run_last = "🔄",
            terminate = "⏹",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Auto-open DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
      -- Close UI when session completes normally
      dap.listeners.after.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.after.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Enhanced keymaps for debugging
      local keymap = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Debugging keymaps
      keymap("n", "<F5>", function()
        -- Check if we're in a Rust project and build if needed
        local cwd = vim.fn.getcwd()
        if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
          -- Build project if changes detected, then start debugging
          local executable_path = find_or_build_executable()
          if executable_path then
            local config = get_debugger_config()
            if config then
              dap.run(config)
            else
              vim.notify("Failed to create debug configuration", vim.log.levels.ERROR)
            end
          else
            vim.notify("Failed to build project", vim.log.levels.ERROR)
          end
        else
          -- Not in a Rust project, just continue with normal debug
          dap.continue()
        end
      end, vim.tbl_extend("force", opts, { desc = "Debug: Continue (with auto-build)" }))
      keymap("n", "<F1>", dap.step_into, vim.tbl_extend("force", opts, { desc = "Debug: Step Into" }))
      keymap("n", "<F2>", dap.step_over, vim.tbl_extend("force", opts, { desc = "Debug: Step Over" }))
      keymap("n", "<F3>", dap.step_out, vim.tbl_extend("force", opts, { desc = "Debug: Step Out" }))
      keymap("n", "<F4>", dap.step_back, vim.tbl_extend("force", opts, { desc = "Debug: Step Back" }))
      keymap("n", "<F17>", function()
        -- Close DAP UI before restarting
        dapui.close()
        -- Restart the debug session
        dap.restart()
        -- The DAP UI will automatically reopen due to the event listeners
      end, vim.tbl_extend("force", opts, { desc = "Debug: Restart (with UI reset)" }))
      keymap("n", "<F23>", function()
        -- Stop the debug session
        dap.close()
        -- Close DAP UI
        dapui.close()
      end, vim.tbl_extend("force", opts, { desc = "Debug: Stop (with UI close)" }))
      keymap("n", "<Leader>b", dap.toggle_breakpoint, vim.tbl_extend("force", opts, { desc = "Debug: Toggle Breakpoint" }))
      keymap("n", "<Leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, vim.tbl_extend("force", opts, { desc = "Debug: Set Conditional Breakpoint" }))
      keymap("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, vim.tbl_extend("force", opts, { desc = "Debug: Set Log Point" }))
      keymap("n", "<Leader>dr", dap.repl.open, vim.tbl_extend("force", opts, { desc = "Debug: Open REPL" }))
      keymap("n", "<Leader>dl", dap.run_last, vim.tbl_extend("force", opts, { desc = "Debug: Run Last" }))

      -- DAP UI keymaps
      keymap("n", "<Leader>du", dapui.toggle, vim.tbl_extend("force", opts, { desc = "Debug: Toggle UI" }))
      keymap("n", "<Leader>de", dapui.eval, vim.tbl_extend("force", opts, { desc = "Debug: Eval" }))
      keymap("n", "<Leader>dE", function()
        dapui.eval(vim.fn.input("Expression: "))
      end, vim.tbl_extend("force", opts, { desc = "Debug: Eval Expression" }))

      -- Visual mode keymaps
      keymap("v", "<Leader>de", dapui.eval, vim.tbl_extend("force", opts, { desc = "Debug: Eval Selection" }))

      -- Hover to see variable values
      keymap("n", "<Leader>dh", function()
        dapui.eval(nil, { enter = true })
      end, vim.tbl_extend("force", opts, { desc = "Debug: Hover Eval" }))

      -- Custom commands for Rust debugging
      vim.api.nvim_create_user_command("RustDebug", function()
        local config = get_debugger_config()
        if config then
          dap.run(config)
        else
          vim.notify("Failed to create debug configuration", vim.log.levels.ERROR)
        end
      end, { desc = "Start Rust debugging session with auto-build" })

      vim.api.nvim_create_user_command("RustDebugTest", function()
        local test_executable = find_or_build_test_executable()
        if test_executable then
          dap.run({
            type = "codelldb",
            request = "launch",
            name = "Debug Rust Test",
            program = test_executable,
            args = {},
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            console = "integratedTerminal",
            sourceLanguages = { "rust" },
          })
        else
          vim.notify("Failed to find or build test executable", vim.log.levels.ERROR)
        end
      end, { desc = "Debug Rust test with auto-build" })

      vim.api.nvim_create_user_command("RustBuild", function()
        local cwd = vim.fn.getcwd()
        local cargo_toml = cwd .. "/Cargo.toml"
        
        if vim.fn.filereadable(cargo_toml) == 0 then
          vim.notify("No Cargo.toml found in current directory", vim.log.levels.ERROR)
          return
        end

        vim.notify("Building Rust project...", vim.log.levels.INFO)
        local result = vim.fn.system("cargo build")
        
        if vim.v.shell_error == 0 then
          vim.notify("Build successful!", vim.log.levels.INFO)
        else
          vim.notify("Build failed: " .. result, vim.log.levels.ERROR)
        end
      end, { desc = "Build Rust project" })

      vim.api.nvim_create_user_command("RustDebugForce", function()
        local config = get_debugger_config(true) -- Force build
        if config then
          dap.run(config)
        else
          vim.notify("Failed to create debug configuration", vim.log.levels.ERROR)
        end
      end, { desc = "Start Rust debugging session with force build" })

      -- Auto-detect Rust project and set up debugging
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          -- Check if we're in a Rust project
          local cwd = vim.fn.getcwd()
          if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
            -- Set up project-specific debugging configuration
            vim.notify("Rust project detected. Debugging support ready!", vim.log.levels.INFO)
          end
        end,
      })

      -- Enhanced debugging features
      local function setup_rust_debugging()
        -- Check for required tools
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
        
        if vim.fn.filereadable(codelldb_path) == 0 then
          vim.notify("codelldb not found. Please run :MasonInstall codelldb", vim.log.levels.WARN)
        else
          vim.notify("Rust debugging support ready!", vim.log.levels.INFO)
        end

        -- Check for cargo
        if vim.fn.executable("cargo") == 0 then
          vim.notify("Warning: cargo not found. Auto-building features will not work.", vim.log.levels.WARN)
        end
      end

      -- Setup on plugin load
      setup_rust_debugging()
    end,
  },

  -- Mason integration for debugger installation
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "codelldb", -- Cross-platform LLDB debugger
        "cpptools", -- C++ debugger (includes cppvsdbg for Windows)
      },
    },
  },
}
