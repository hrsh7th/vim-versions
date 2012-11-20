let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#info#do(args)
  let format = get(a:args, 'format', g:versions#info.git)
  return 'git'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

