let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'Powerline#Functions#versions#GetBranchLifeTime', 30)

let s:branch_cache = {}
function! Powerline#Functions#versions#GetBranch(symbol)
  let path = expand('%:p:h')

  " get branch_cache.
  if exists('s:branch_cache[path]') && s:branch_cache[path].expire > reltime()[0]
    return s:substitute(s:branch_cache[path].branch, a:symbol)
  endif

  " execute system command.
  try
    let branches = versions#command('branch:list', {}, { 'working_dir': path })
    let branches = filter(branches, 'v:val.is_current')
    if empty(branches)
      throw 'dummy'
    endif

    let s:branch_cache[path] = {
          \ 'expire': reltime()[0] + g:Powerline#Functions#versions#GetBranchLifeTime,
          \ 'branch': branches[0].name,
          \ }
  catch
    let s:branch_cache[path] = {
          \ 'expire': reltime()[0] + g:Powerline#Functions#versions#GetBranchLifeTime,
          \ 'branch': '',
          \ }
  endtry
  return s:substitute(s:branch_cache[path].branch, a:symbol)
endfunction

function s:substitute(name, symbol)
  return substitute(a:name, '\c\v\[?GIT\(([a-z0-9\-_\./:]+)\)\]?', a:symbol .' \1', 'g')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

