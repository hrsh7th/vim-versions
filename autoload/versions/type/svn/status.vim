let s:save_cpo = &cpo
set cpo&vim

call vital#versions#define(g:, 'versions#type#svn#status#ignore_status', [])

function! versions#type#svn#status#do(args)
  let path = vital#versions#substitute_path_separator(
        \ get(a:args, 'path', './'))
  let output = vital#versions#system(printf('svn status --ignore-externals %s',
        \ versions#get_relative_path(path)))
  return s:filter_status(versions#type#svn#status#parse(output))
endfunction

function! versions#type#svn#status#parse(output)
  let list = map(split(a:output, "\n"),
        \ 'vital#versions#trim_right(v:val)')
  let list = filter(list,
        \ 'versions#type#svn#status#is_status_line(v:val)')
  return map(list,
        \ 'versions#type#svn#status#create_status(v:val)')
endfunction

function! versions#type#svn#status#is_status_line(line)
  return match(strpart(a:line, 0, 7), '^[^>]*$') > -1
endfunction

function! versions#type#svn#status#create_status(line)
  return {
        \ 'line': a:line,
        \ 'status': strpart(a:line, 0, 7),
        \ 'path': vital#versions#substitute_path_separator(strpart(a:line, 8)),
        \ }
endfunction

function! s:filter_status(list)
  let list = a:list
  for status in g:versions#type#svn#status#ignore_status
    let list = filter(list, 'v:val.status !~# status')
  endfor
  return list
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

