# Hakyll Blog with Nix Spices
_this is a direct fork of https://github.com/rpearce/hakyll-nix-template and is being hosted on my VPS_

## Quick reference Commands

- build result into `./result/dist`

```bash
nix build
```

- start hakyll's dev server that reloads after changes are made:

```bash
nix run . watch
```

- run any hakyll command through `nix run .`!

```bash
nix run . clean
```

- `nix develop` does/has:
    - hakyll-site
    - hakyll-init
    - shell.buildInputs of hakyllProject
    - setup to run ghci with some defaults and the modules loaded so you can make your own changes and test them out in the ghci REPL
