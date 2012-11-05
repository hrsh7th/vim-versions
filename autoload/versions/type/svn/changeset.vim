let s:save_cpo = &cpo
set cpo&vim

function! versions#type#svn#changeset#do(args)
  let revision = get(a:args, 'revision', 'HEAD')

  let output = vital#versions#system(printf('svn log --incremental --verbose --limit 2 %s@%s',
        \ versions#get_root_dir(getcwd()),
        \ revision))

  return versions#type#svn#changeset#parse(output)
endfunction

function! versions#type#svn#changeset#parse(output)
  if stridx(a:output, g:versions#type#svn#log#separator) < 0
    return {}
  endif
  let list = split(a:output, g:versions#type#svn#log#separator)
  let list = filter(list, 'strlen(v:val)')

  if empty(list)
    return {}
  endif

  return versions#type#svn#changeset#extract_changeset(list)
endfunction

function! versions#type#svn#changeset#extract_changeset(list)
  let [log1, statuses1] = s:extract_changeset(a:list[0])
  let [log2, statuses2] = s:extract_changeset(a:list[1])
  let logs = versions#type#svn#log#parse(printf("%s\n%s\n%s",
        \ join(log1, "\n"),
        \ g:versions#type#svn#log#separator,
        \ join(log2, "\n")))
  if empty(logs)
    return {}
  endif
  let logs[0].statuses = map(filter(statuses1,
        \ 'versions#type#svn#changeset#is_status_line(v:val)'),
        \ 'versions#type#svn#changeset#create_status(v:val)')
  return logs[0]
endfunction

function! versions#type#svn#changeset#is_status_line(line)
  return match(strpart(a:line, 0, 4), '^[^>]*$') > -1
endfunction

function! versions#type#svn#changeset#create_status(line)
  return {
        \ 'line': a:line,
        \ 'status': strpart(a:line, 0, 4),
        \ 'path': vital#versions#substitute_path_separator(strpart(a:line, 5)),
        \ }
endfunction

function! s:extract_changeset(log)
  let log = split(a:log, "\n")
  let statuses = remove(log, 1, index(log, '') - 1)
  if !empty(statuses)
    let statuses = statuses[1:]
  endif
  return [log, statuses]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

