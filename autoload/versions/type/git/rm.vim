let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#rm#do(args)
  let args = a:args

  if !has_key(args, 'paths') || !vital#versions#is_list(args.paths)
    throw 'versions#type#git#rm: invalid argument "paths".'
  endif

  let force = get(args, 'force', 0)
  let cached = get(args, 'cached', 0)

  call map(args.paths, 'vital#versions#substitute_path_separator(v:val)')
  call map(args.paths, 'versions#get_relative_path(v:val)')

  let output = vital#versions#system(printf('git rm %s %s -- %s',
        \ force ? '--force' : '',
        \ cached ? '--cached' : '',
        \ join(args.paths, ' ')))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

