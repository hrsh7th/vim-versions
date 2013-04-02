let s:save_cpo = &cpo
set cpo&vim

" HASH, PREV_HASH, AUTHOR_NAME, AUTHOR_EMAIL, AUTHOR_DATE, SUBJECT
call vital#versions#define(g:, 'versions#type#git#log#format', '%H%x09%P%x09%an%x09%ae%x09%ai%x09%s')
call vital#versions#define(g:, 'versions#type#git#log#limit', 1000)
call vital#versions#define(g:, 'versions#type#git#log#no_merges', 0)
call vital#versions#define(g:, 'versions#type#git#log#first_parent', 0)
call vital#versions#define(g:, 'versions#type#git#log#append_is_pushed', 0)

function! versions#type#git#log#do(args)
  let path = vital#versions#substitute_path_separator(get(a:args, 'path', './'))
  let path = versions#get_relative_path(path)
  let path = (path == '' ? './' : path)
  let limit = '-' . get(a:args, 'limit', g:versions#type#git#log#limit)

  let output = vital#versions#system(printf('git log --pretty=format:"%s" %s %s %s %s',
        \ g:versions#type#git#log#format,
        \ limit,
        \ g:versions#type#git#log#no_merges ? '--no-merges' : '',
        \ g:versions#type#git#log#first_parent? '--first-parent' : '',
        \ path))

  let logs = versions#type#git#log#parse(output)

  " append is_pushed.
  if g:versions#type#git#log#append_is_pushed
    let branches = versions#type#git#branch#list({ 'path': versions#get_relative_path(path) })
    let branches = filter(branches, "v:val.is_current")
    if  !empty(branches)
      let current_branch = branches[0]
      let foward_logs = versions#type#git#log#diff({ 'rev1': 'origin/' . current_branch.name, 'rev2': current_branch.name })

      for log in logs
        for foward_log in foward_logs
          if log.revision == foward_log.revision
            let log.is_pushed = 0
          else
            let log.is_pushed = 1
          endif
        endfor
      endfor
    endif
  endif

  return logs
endfunction

function! versions#type#git#log#diff(args)
  if !exists('a:args.rev1') || !exists('a:args.rev2')
    throw 'versions#type#git#log#diff: a:args.rev1 or a:args.rev2 is not found.'
  endif

  let rev1 = a:args.rev1
  let rev2 = a:args.rev2
  let output = vital#versions#system(printf('git log --pretty=format:"%s" %s..%s',
        \ g:versions#type#git#log#format,
        \ rev1,
        \ rev2))
  return versions#type#git#log#parse(output)
endfunction

function! versions#type#git#log#parse(output)
  let list = map(split(a:output, "\n"),
        \ "versions#type#git#log#create_log(v:val)")
  return filter(list, '!empty(v:val)')
endfunction

function! versions#type#git#log#create_log(line)
  try
    let [revision, prev_revision, author, mail, date, message] =
          \ split(a:line, "\t")
  catch
    return {}
  endtry
  return {
        \ 'revision': revision,
        \ 'prev_revision': prev_revision,
        \ 'author': author,
        \ 'date': matchstr(date,
        \   '\d\{4,4}\-\d\{2,2}-\d\{2,2}\s\d\{2,2}:\d\{2,2}:\d\{2,2}'),
        \ 'message': message,
        \ }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

