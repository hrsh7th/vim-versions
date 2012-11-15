let s:save_cpo = &cpo
set cpo&vim

function! versions#type#svn#cat#do(args)
  if !has_key(a:args, 'path')
    throw 'versions#type#svn#cat: invalid argument "path".'
  endif
  let path = vital#versions#substitute_path_separator(a:args.path)
  let path = versions#get_relative_path(path)
  let revision = get(a:args, 'revision', 'HEAD')

  let output = vital#versions#system(printf('svn cat --revision %s %s',
        \ revision,  path))
  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

