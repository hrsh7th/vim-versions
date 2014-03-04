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
  let theirs = get(args, 'theirs', '')
  let ours   = get(args, 'ours', '')

  let opt = []
  if theirs != ''
    call add(opt, '--theirs')
  endif
  if ours != ''
    call add(opt, '--ours')
  endif
  if branch != ''
    call add(opt, branch)
  else
    call add(opt, '--')
    call add(opt, join(args.paths, ' '))
  endif

  let output = vital#versions#system(printf('git checkout %s', join(opt, ' ')))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

