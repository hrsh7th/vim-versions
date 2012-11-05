let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#type#svn#log#limit', 1000)
call vital#versions#define(g:, 'versions#type#svn#log#stop_on_copy', 1)
call vital#versions#define(g:, 'versions#type#svn#log#separator',
      \ '------------------------------------------------------------------------')

function! versions#type#svn#log#do(args)
  let path = vital#versions#substitute_path_separator(get(
        \ a:args, 'path', './'))
  let limit = get(a:args, 'limit',
        \ g:versions#type#svn#log#limit)
  let stop_on_copy = get(a:args, 'stop_on_copy',
        \ g:versions#type#svn#log#stop_on_copy)

  let output = vital#versions#system(printf('svn log --incremental --limit %s %s %s',
        \ limit,
        \ stop_on_copy ? '--stop-on-copy' : '',
        \ versions#get_relative_path(path)))

  return versions#type#svn#log#parse(output)
endfunction

function! versions#type#svn#log#parse(output)
  if stridx(a:output, g:versions#type#svn#log#separator) < 0
    return []
  endif
  let list = split(a:output, g:versions#type#svn#log#separator)
  let list = filter(list, 'strlen(v:val)')
  let list = map(list, 'versions#type#svn#log#create_log(v:val)')
  let list = filter(list, '!empty(v:val)')
  let list = s:append_prev_revision(list)
  return list
endfunction

function! versions#type#svn#log#create_log(lines)
  try
    let lines = split(vital#versions#trim(a:lines), "\n")
    let description = lines[0]
    let message = join(lines[2:], "\n")
    let [revision, author, date, _] = map(split(description, "|"),
          \ 'vital#versions#trim(v:val)')
  catch
    return {}
  endtry
  return {
        \ 'revision': matchstr(revision, '\d\+'),
        \ 'message': message,
        \ 'author': author,
        \ 'date': matchstr(date,
        \   '\d\{4,4}\-\d\{2,2}-\d\{2,2}\s\d\{2,2}:\d\{2,2}:\d\{2,2}')
        \ }
endfunction

function! s:append_prev_revision(logs)
  let i = 0
  while exists('a:logs[i + 1]')
    let a:logs[i].prev_revision = a:logs[i + 1].revision
    let i += 1
  endwhile
  let a:logs[i].prev_revision = ''
  return a:logs
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

