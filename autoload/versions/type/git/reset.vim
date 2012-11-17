let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#reset#do(args)
  let args = a:args

  if !has_key(args, 'paths') || !vital#versions#is_list(args.paths)
    let args.paths = []
  endif

  if !has_key(args, 'revision')
    let args.revision = 'HEAD'
  endif

  let soft = get(args, 'soft', 0)
  let hard = get(args, 'hard', 0)

  call map(args.paths, 'vital#versions#substitute_path_separator(v:val)')
  call map(args.paths, 'versions#get_relative_path(v:val)')

  let output = vital#versions#system(printf('git reset %s %s -- %s',
        \ soft ? '--soft' : (hard ? '--hard' : ''),
        \ args.revision,
        \ join(args.paths, ' ')))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

