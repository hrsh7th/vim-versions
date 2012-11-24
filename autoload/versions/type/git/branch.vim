let s:save_cpo = &cpo
set cpo&vim

" TODO: redesign.
" versions#command('branch', {}) #=> versions#type#git#branch#do(args)
" versions#command('branch:list', { }) #=> versions#type#git#branch#list(args)
" versions#command('branch:delete', { 'branch': 'master' }) #=> versions#type#git#branch#delete(args)
function! versions#type#git#branch#do(args)
  " for delete.
  if get(a:args, 'delete', '') != ''
    let output = vital#versions#system(printf('git branch -D %s', a:args.delete))
    return vital#versions#trim_cr(output)

  " for list.
  elseif get(a:args, 'list', '') != ''
    let output = vital#versions#system('git branch')
    return map(split(output, "\n"), 'versions#type#git#branch#convert(v:val)')

  " for create.
  else
    if get(a:args, 'name', '') == ''
      throw 'branch name not given.'
    endif
    let output = vital#versions#system(printf('git branch %s', a:args.name))
    return vital#versions#trim_cr(output)
  endif
endfunction

function! versions#type#git#branch#convert(line)
  let mark = strpart(a:line, 0, 2)
  let name = strpart(a:line, 2)
  return {
        \ 'name': name,
        \ 'is_current': mark =~# '\*',
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

