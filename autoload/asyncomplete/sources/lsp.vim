" CompletionItemKind values from the LSP protocol.
let g:asyncomplete_lsp_types = {
\ 1: 'text',
\ 2: 'method',
\ 3: 'function',
\ 4: 'constructor',
\ 5: 'field',
\ 6: 'variable',
\ 7: 'class',
\ 8: 'interface',
\ 9: 'module',
\ 10: 'property',
\ 11: 'unit',
\ 12: 'value',
\ 13: 'enum',
\ 14: 'keyword',
\ 15: 'snippet',
\ 16: 'color',
\ 17: 'file',
\ 18: 'reference',
\ 19: 'folder',
\ 20: 'enum_member',
\ 21: 'constant',
\ 22: 'struct',
\ 23: 'event',
\ 24: 'operator',
\ 25: 'type_parameter',
\ }

" For compatibility reasons, we only use built in VIM completion kinds
" See :help complete-items for Vim completion kinds
let g:asyncomplete_completion_symbols = get(g:, 'asyncomplete_completion_symbols', {
\ 'text': 'v',
\ 'method': 'f',
\ 'function': 'f',
\ 'constructor': 'f',
\ 'field': 'm',
\ 'variable': 'v',
\ 'class': 't',
\ 'interface': 't',
\ 'module': 'd',
\ 'property': 'm',
\ 'unit': 'v',
\ 'value': 'v',
\ 'enum': 't',
\ 'keyword': 'v',
\ 'snippet': 'v',
\ 'color': 'v',
\ 'file': 'v',
\ 'reference': 'v',
\ 'folder': 'v',
\ 'enum_member': 'm',
\ 'constant': 'm',
\ 'struct': 't',
\ 'event': 'v',
\ 'operator': 'f',
\ 'type_parameter': 'p',
\ '*': 'v'
\ })

function! asyncomplete#sources#lsp#GetCompletionSymbol(kind) abort
    let l:kind = get(g:asyncomplete_lsp_types, a:kind, '')
    let l:symbol = get(g:asyncomplete_completion_symbols, l:kind, '')

    if !empty(l:symbol)
        return l:symbol
    endif

    return get(g:asyncomplete_completion_symbols, '*', 'v')
endfunction

function! asyncomplete#sources#lsp#get_source_options(...) abort
    let l:default = extend({
    \     'name': 'lsp',
    \     'completor': function('asyncomplete#sources#lsp#completor'),
    \     'whitelist': ['*'],
    \     'triggers': asyncomplete#sources#lsp#get_triggers(),
    \ }, a:0 >= 1 ? a:1 : {})

    return extend(l:default, {'refresh_pattern': '\k\+$'})
endfunction

let s:trigger_character_map = {
\   '*': ['.'],
\   'typescript': ['.', '''', '"'],
\   'rust': ['.', '::'],
\   'cpp': ['.', '::', '->'],
\}

function! asyncomplete#sources#lsp#get_triggers() abort
    return deepcopy(s:trigger_character_map)
endfunction

function! asyncomplete#sources#lsp#completor(options, context) abort
    lua << EOF
      local context = vim.fn['asyncomplete#context']()
      local params = vim.lsp.util.make_position_params()
      local callback = function(_, _, result)
          if not result then return end
          data = vim.fn['asyncomplete#sources#lsp#callback'](result, context)
      end
      vim.lsp.buf_request(0, 'textDocument/completion', params, callback)
EOF
endfunction

function! asyncomplete#sources#lsp#callback(results, context) abort
  let l:keyword = matchstr(a:context.typed, '\w\+$')
  let l:startcol = a:context.col - len(l:keyword)

  let l:items = []
  for l:item in a:results['items']
    let l:kind = asyncomplete#sources#lsp#GetCompletionSymbol(get(l:item, 'kind', ''))
    let l:word = get(l:item, 'insertText', '')
    let l:menu = get(l:item, 'detail', '')
    let l:info = get(l:item, 'detail', '')
    let l:fixedItem = {'word': l:word, 'kind': l:kind, 'info': l:info, 'menu': l:menu}

    let l:items += [l:fixedItem]
  endfor

  call asyncomplete#complete('lsp', a:context, l:startcol, l:items)
endfunction
