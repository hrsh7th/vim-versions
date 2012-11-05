let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#show#do(args)
  if !has_key(a:args, 'path')
    throw 'versions#type#git#show: invalid argument "path".'
  endif
  let path = versions#get_relative_path(a:args.path)
  let revision = get(a:args, 'revision', 'HEAD')

  let output = vital#versions#system(printf('git show %s',
        \ revision . ':' . vital#versions#substitute_path_separator(path)))
  return substitute(vital#versions#trim_cr(output),
        \ '\n$', '', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

