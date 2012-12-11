let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#type#git#branch#merge#ignore_all_space', 0)

" branch:do -> branch:create.
function! versions#type#git#branch#do(args)
  return versions#type#git#branch#create(a:args)
endfunction

" branch:create.
function! versions#type#git#branch#create(args)
  let branch = get(a:args, 'branch', '')
  let branch = branch != '' ? branch : s:input(1)

  if branch == ''
    return
  endif

  return vital#versions#trim_cr(
        \   vital#versions#system(printf('git branch %s', branch))
        \ )
endfunction

" branch:delete.
function! versions#type#git#branch#delete(args)
  let branch = get(a:args, 'branch', '')
  let branch = branch != '' ? branch : s:input(0)

  if branch == ''
    return
  endif

  return vital#versions#trim_cr(
        \   vital#versions#system(printf('git branch -D %s', branch))
        \ )
endfunction

" branch:merge.
function! versions#type#git#branch#merge(args)
  let branch = get(a:args, 'branch', '')
  let branch = branch != '' ? branch : s:input(0)

  if branch == '' && vital#versions#yesno('merge?')
    return
  endif

  return vital#versions#trim_cr(
        \   vital#versions#system(printf('git merge --no-ff %s %s',
        \     g:versions#type#git#branch#merge#ignore_all_space ? '-Xignore-all-space' : '',
        \     branch
        \   ))
        \ )
endfunction

" branch:push.
function! versions#type#git#branch#push(args)
  let branch = get(a:args, 'branch', '')
  let branch = branch != '' ? branch : s:input(0)

  if branch == '' && vital#versions#yesno('push?')
    return
  endif

  return vital#versions#trim_cr(
        \   vital#versions#system(printf('git push origin %s:%s', branch, branch))
        \ )
endfunction

" branch:list.
function! versions#type#git#branch#list(...)
  return map(split(vital#versions#system('git branch'), "\n"),
        \   'versions#type#git#branch#create_branch(v:val)'
        \)
endfunction

function! versions#type#git#branch#create_branch(line)
  let mark = strpart(a:line, 0, 2)
  let name = strpart(a:line, 2)
  return {
        \ 'name': name,
        \ 'is_current': mark =~# '\*',
        \ }
endfunction

function! s:input(force)
  echomsg '--- branches. ---'
  for _ in versions#type#git#branch#list()
    echomsg (_.is_current ? ' * ' : '   ') . _.name
  endfor
  echomsg '-----------------'

  while 1
    let branch = input('[branch name] ')
    if branch == ''
      echomsg 'canceled.'
      return
    endif
    if a:force || !empty(filter(branches, 'v:val.name == branch'))
      return branch
    endif
  endwhile
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

