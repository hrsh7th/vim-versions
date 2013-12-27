let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#svn#log#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/svn/log',
      \ 'default_action': 'diff_prev',
      \ 'action_table': {},
      \ }

let s:kind.action_table.yank_message = {
      \ 'description': 'yank commit message.',
      \ 'is_selectable': 0,
      \ }
function! s:kind.action_table.yank_message.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call vital#versions#yank(candidate.action__log.message)
endfunction

let s:kind.action_table.yank_revision = {
      \ 'description': 'yank revision.',
      \ 'is_selectable': 0,
      \ }
function! s:kind.action_table.yank_revision.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call vital#versions#yank(candidate.action__log.revision)
endfunction

let s:kind.action_table.yank_prev_revision = {
      \ 'description': 'yank prev_revision.',
      \ 'is_selectable': 0,
      \ }
function! s:kind.action_table.yank_prev_revision.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call vital#versions#yank(candidate.action__log.prev_revision)
endfunction

let s:kind.action_table.changeset = {
      \ 'description': 'display changeset.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.changeset.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  return unite#start_temporary([['versions/svn/changeset',
        \ candidate.source__args.path,
        \ candidate.action__log.revision]])
endfunction

let s:kind.action_table.diff = {
      \ 'description': 'display diff.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.diff.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#call('unite#kinds#versions#svn#log#diff',
        \ [candidate],
        \ fnamemodify(candidate.source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#svn#log#diff(candidate)
  let candidate = a:candidate

  if !filereadable(candidate.source__args.path)
    return unite#start_temporary([['versions/svn/changeset',
          \ candidate.source__args.path,
          \ candidate.action__log.revision]])
  endif

  call versions#diff#file_with_string(candidate.source__args.path, {
        \   'name': printf('%s [REMOTE: %s]', candidate.source__args.path, candidate.action__log.revision),
        \   'string': versions#command('cat', {
        \     'path': candidate.source__args.path,
        \     'revision': candidate.action__log.revision,
        \   }, {
        \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \   })
        \ })
endfunction

let s:kind.action_table.diff_prev = {
      \ 'description': 'display previous revision diff.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.diff_prev.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#call('unite#kinds#versions#svn#log#diff_prev',
        \ [candidate],
        \ fnamemodify(candidate.source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#svn#log#diff_prev(candidate)
  let candidate = a:candidate

  if !filereadable(candidate.source__args.path)
    return unite#start_temporary([['versions/svn/changeset',
          \ candidate.source__args.path,
          \ candidate.action__log.revision]])
  endif

  call versions#diff#string_with_string({
        \   'name': printf('%s [REMOTE: %s]', candidate.source__args.path, candidate.action__log.revision),
        \   'string': versions#command('cat', {
        \     'path': candidate.source__args.path,
        \     'revision': candidate.action__log.revision,
        \   }, {
        \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \   })
        \ }, {
        \   'name': printf('%s [REMOTE: %s]', candidate.source__args.path, candidate.action__log.prev_revision),
        \   'string': versions#command('cat', {
        \     'path': candidate.source__args.path,
        \     'revision': candidate.action__log.prev_revision,
        \   }, {
        \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \   })
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

