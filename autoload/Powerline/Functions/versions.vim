let s:cache = {}
let s:life_time = 30

function! Powerline#Functions#versions#GetBranch(symbol)
  let path = expand('%:p:h')

  " get cache.
  if exists('s:cache[path]') && s:cache[path].expire > reltime()[0]
    return s:substitute(s:cache[path].branch, a:symbol)
  endif

  " execute system command.
  try
    let branches = versions#command('branch:list', {}, { 'working_dir': path })
    let branches = filter(branches, 'v:val.is_current')
    if empty(branches)
      throw 'dummy'
    endif

    let s:cache[path] = {
          \ 'expire': reltime()[0] + s:life_time,
          \ 'branch': branches[0].name,
          \ }
  catch
    let s:cache[path] = {
          \ 'expire': reltime()[0] + s:life_time,
          \ 'branch': '',
          \ }
  endtry
  return s:substitute(s:cache[path].branch, a:symbol)
endfunction

function s:substitute(name, symbol)
  return substitute(a:name, '\c\v\[?GIT\(([a-z0-9\-_\./:]+)\)\]?', a:symbol .' \1', 'g')
endfunction

