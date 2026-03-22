return {
  {
    "dmmulroy/ts-error-translator.nvim",
    event = "VeryLazy",
    opts = {
      auto_attach = true,
      servers = {
        "astro",
        "svelte",
        "ts_ls",
        "tsserver",
        "typescript-tools",
        "volar",
        "vtsls",
        "tsgo",
      },
    },
    config = function(_, opts)
      require("ts-error-translator").setup(opts)
    end,
  },
}
