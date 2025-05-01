# tmux-window-switcher

> Easily switch to another Tmux window with [fzf](https://github.com/junegunn/fzf) and Tmux popup.

> ![tmux-window-switcher](./window-switcher.jpg)

> [!INFO]
> This uses a Tmux popup to display the current Tmux windows. It spawns a
> new shell to render them, so the display speed may vary depending on your
> shell's startup time.
>
> In other words, if performance is a priority, consider optimizing your shell
> configuration (a highly recommended step) or simply stick to the default Tmux
> window switcher (`<prefix>w`), which is instant.

## :package: Installation
### Install through [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```bash
set -g @plugin 'l-lin/tmux-window-switcher'
```

Hit `prefix + I` to fetch the plugin and source it.

## :rocket: Usage

`prefix + C-g` opens Tmux windows in a Tmux popup.

## :wrench: Configuration

Default configuration:

```bash
set -g @tmux-window-switcher-key-binding 'C-g'
set -g @tmux-window-switcher-width '90%'
set -g @tmux-window-switcher-height '90%'
```

## :page_with_curl: License

[MIT](./LICENSE)

