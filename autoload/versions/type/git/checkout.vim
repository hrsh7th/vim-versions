let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#checkout#do(args)
  let args = a:args
  if has_key(args, 'paths') && vital#versions#is_list(args.paths)
    call map(args.paths, 'vital#versions#substitute_path_separator(v:val)')
    call map(args.paths, 'versions#get_relative_path(v:val)')
  else
    let args.paths = []
  endif

  let branch = get(args, 'branch', '')

  let output = vital#versions#system(printf('git checkout %s%s',
        \ branch,
        \ branch == '' ? ' -- ' . join(args.paths, ' ') : ''))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

