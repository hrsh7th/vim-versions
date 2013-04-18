let s:save_cpo = &cpo
set cpo&vim

function! versions#type#git#changeset#do(args)
  let revision = get(a:args, 'revision', 'HEAD')
  let prev_revision = get(a:args, 'prev_revision', 'HEAD')

  let log_info = vital#versions#system(printf('git log --pretty=format:"%s" -1 %s',
        \ g:versions#type#git#log#format,
        \ revision))
  let name_status = vital#versions#system(printf('git diff --name-status %s %s',
        \ revision,
        \ prev_revision))

  return versions#type#git#changeset#parse(log_info, name_status)
endfunction

function! versions#type#git#changeset#parse(log_info, name_status)
  let list = map(split(a:log_info, "\n"), 'vital#versions#trim_right(v:val)')
  if empty(list)
    return {}
  endif

  let changeset = versions#type#git#log#parse(list[0])
  if empty(changeset)
    return {}
  endif

  let changeset[0].statuses = map(filter(split(a:name_status, "\n"),
        \ 'versions#type#git#changeset#is_status_line(v:val)'),
        \ 'versions#type#git#changeset#create_status(v:val)')
  return changeset[0]
endfunction

function! versions#type#git#changeset#is_status_line(line)
  return match(strpart(a:line, 0, 1), '^[ACDMRTUXB]\+$') > -1
endfunction

function! versions#type#git#changeset#create_status(line)
  return {
        \ 'line': a:line,
        \ 'status': strpart(a:line, 0, 1),
        \ 'path': vital#versions#substitute_path_separator(strpart(a:line, 2)),
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


