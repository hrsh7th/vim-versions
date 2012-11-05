let s:save_cpo = &cpo
set cpo&vim

function! versions#type#svn#add#do(args)
  let args = a:args

  if !has_key(args, 'paths') || !vital#versions#is_list(args.paths)
    throw 'versions#type#svn#add: invalid argument "paths".'
  endif

  call map(args.paths, 'vital#versions#substitute_path_separator(v:val)')
  call map(args.paths, 'versions#get_relative_path(v:val)')

  let output = vital#versions#system(printf('svn add %s',
        \ join(args.paths, ' ')))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

