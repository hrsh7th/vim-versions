let s:save_cpo = &cpo
set cpo&vim

function! versions#diff#file_with_string(path, arg)
  call vital#versions#execute('tabedit', a:path)
  diffthis

  vnew
  put!=a:arg.string
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  call vital#versions#execute('file', a:arg.name)
  call vital#versions#execute('filetype', 'detect')
  diffthis

  call setpos('.', [bufnr('%'), 0, 0])
  stopinsert!
endfunction

function! versions#diff#string_with_string(arg1, arg2)
  tabnew
  put!=a:arg1.string
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  call vital#versions#execute('file', a:arg1.name)
  call vital#versions#execute('filetype', 'detect')
  diffthis

  vnew
  put!=a:arg2.string
  $delete
  setlocal bufhidden=delete buftype=nofile nobuflisted noswapfile nomodifiable
  call vital#versions#execute('file', a:arg2.name)
  call vital#versions#execute('filetype', 'detect')
  diffthis

  call setpos('.', [bufnr('%'), 0, 0])
  stopinsert!
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

