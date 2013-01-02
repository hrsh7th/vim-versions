let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#revert#do(args)
  let args = a:args

  if !has_key(args, 'revisions') || !vital#versions#is_list(args.revisions)
    let args.revisions = []
  endif

  let output = vital#versions#system(printf('git revert --no-edit %s',
        \ join(args.revisions, ' ')))

  return vital#versions#trim_cr(output)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


