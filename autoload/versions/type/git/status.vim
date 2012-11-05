let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#status#do(args)
  let path = vital#versions#substitute_path_separator(
        \ get(a:args, 'path', './'))

  let output = vital#versions#system(printf('git status --short %s',
        \ versions#get_relative_path(path)))
  return versions#type#git#status#parse(output)
endfunction

function! versions#type#git#status#parse(output)
  let list = map(split(a:output, "\n"),
        \ 'vital#versions#trim_right(v:val)')
  let list = filter(list,
        \ 'versions#type#git#status#is_status_line(v:val)')
  return map(list,
        \ 'versions#type#git#status#create_status(v:val)')
endfunction

function! versions#type#git#status#is_status_line(line)
  return match(strpart(a:line, 0, 2), '^[?MADRCU ]\+$') > -1
endfunction

function! versions#type#git#status#create_status(line)
  return {
        \ 'line': a:line,
        \ 'status': strpart(a:line, 0, 2),
        \ 'path': vital#versions#substitute_path_separator(strpart(a:line, 3)),
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

