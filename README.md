# asyncomplete_neovim_lsp

LSP completion source (via [Neovim LSP][]) for [asyncomplete.vim][].

## Installation & Usage

Install:

```
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'donniewest/asyncomplete_neovim_lsp'
```

Configure:

```
au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#lsp#get_source_options({}))
```

[asyncomplete.vim]: https://github.com/prabirshrestha/asyncomplete.vim
[Neovim LSP]: https://neovim.io/doc/user/lsp.html
