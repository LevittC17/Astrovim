return {
  { "mfussenegger/nvim-jdtls", lazy = true },
  {
    "AstroNvim/astrolsp",
    opts = {
      setup_handlers = {
        jdtls = function(_, opts)
          vim.api.nvim_create_autocmd("Filetype", {
            pattern = "java",
            callback = function()
              if opts.root_dir and opts.root_dir ~= "" then
                require("jdtls").start_or_attach(opts)
              end
            end,
          })
        end,
      },
      config = {
        jdtls = function()
          local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
          local root_dir = require("jdtls.setup").find_root(root_markers)
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
          os.execute("mkdir -p " .. workspace_dir)
          local install_path = require("mason-registry").get_package("jdtls"):get_install_path()
          local os_name = vim.fn.has("macunix") == 1 and "mac" or (vim.fn.has("win32") == 1 and "win" or "linux")
          return {
            cmd = {
              "java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dlog.protocol=true",
              "-Dlog.level=ALL",
              "-javaagent:" .. install_path .. "/lombok.jar",
              "-Xms1g",
              "--add-modules=ALL-SYSTEM",
              "--add-opens", "java.base/java.util=ALL-UNNAMED",
              "--add-opens", "java.base/java.lang=ALL-UNNAMED",
              "-jar", vim.fn.glob(install_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
              "-configuration", install_path .. "/config_" .. os_name,
              "-data", workspace_dir,
            },
            root_dir = root_dir,
          }
        end,
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "jdtls" },
    },
  },
}
