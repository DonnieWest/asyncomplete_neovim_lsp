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
      local base = vim.fn['asyncomplete#sources#lsp#get_base'](context)
      local params = vim.lsp.util.make_position_params()
      local callback = function(err, _, result)
          if err or not result then
              return
          end
          local matches = vim.lsp.util.text_document_completion_list_to_complete_items(result, base)
          data = vim.fn['asyncomplete#sources#lsp#callback'](matches, context)
      end
      vim.lsp.buf_request(context.bufnr, 'textDocument/completion', params, callback)
EOF
endfunction

function! asyncomplete#sources#lsp#get_base(context) abort
  return matchstr(a:context.typed, '\w\+$')
endfunction

function! asyncomplete#sources#lsp#callback(results, context) abort
  let l:keyword = matchstr(a:context.typed, '\w\+$')
  let l:startcol = a:context.col - len(l:keyword)

  call asyncomplete#complete('lsp', a:context, l:startcol, a:results)
endfunction
