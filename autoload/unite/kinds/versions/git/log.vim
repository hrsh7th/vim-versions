let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#versions#git#log#define()
  return [s:kind]
endfunction

let s:kind = {
      \ 'name': 'versions/git/log',
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

let s:kind.action_table.revert = {
      \ 'description': 'revert revision.',
      \ 'is_selectable': 1,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.revert.func(candidates)
  let candidates = vital#versions#is_list(a:candidates) ? a:candidates : [a:candidates]
  call versions#command('revert', {
        \   'revisions': map(deepcopy(candidates), 'v:val.action__log.revision'),
        \ }, {
        \   'working_dir': fnamemodify(candidates[0].source__args.path, ':p:h')
        \ })
endfunction

let s:kind.action_table.reset = {
      \ 'description': 'reset revision.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#command('reset', {
        \   'revision': candidate.action__log.revision
        \ }, {
        \   'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \ })
endfunction

let s:kind.action_table.reset_soft = {
      \ 'description': 'reset revision with soft.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset_soft.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#command('reset', {
        \   'revision': candidate.action__log.revision,
        \   'soft': 1
        \ }, {
        \   'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \ })
endfunction

let s:kind.action_table.reset_hard = {
      \ 'description': 'reset revision with hard.',
      \ 'is_selectable': 0,
      \ 'is_invalidate_cache': 1,
      \ 'is_quit': 0,
      \ }
function! s:kind.action_table.reset_hard.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#command('reset', {
        \   'revision': candidate.action__log.revision,
        \   'hard': 1
        \ }, {
        \   'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \ })
endfunction

let s:kind.action_table.changeset = {
      \ 'description': 'display changeset.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.changeset.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  return unite#start_temporary([['versions/git/changeset',
        \ candidate.source__args.path,
        \ 'HEAD',
        \ candidate.action__log.revision]])
endfunction

let s:kind.action_table.changeset_prev = {
      \ 'description': 'display previous revision changeset.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.changeset_prev.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  return unite#start_temporary([['versions/git/changeset',
        \ candidate.source__args.path,
        \ candidate.action__log.revision,
        \ candidate.action__log.prev_revision]])
endfunction

let s:kind.action_table.diff = {
      \ 'description': 'display diff.',
      \ 'is_selectable': 0,
      \ 'is_quit': 1,
      \ 'is_start': 1,
      \ }
function! s:kind.action_table.diff.func(candidates)
  let candidate = vital#versions#is_list(a:candidates) ? a:candidates[0] : a:candidates
  call versions#call('unite#kinds#versions#git#log#diff',
        \ [candidate],
        \ fnamemodify(candidate.source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#git#log#diff(candidate)
  let candidate = a:candidate

  if !filereadable(candidate.source__args.path)
    return unite#start_temporary([['versions/git/changeset',
          \ candidate.source__args.path,
          \ 'HEAD',
          \ candidate.action__log.revision
          \ ]])
  endif

  call versions#diff#file_with_string(candidate.source__args.path, {
        \   'name': printf('[REMOTE: %s] %s', candidate.action__log.revision, candidate.source__args.path),
        \   'string': versions#command('show', {
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
  call versions#call('unite#kinds#versions#git#log#diff_prev',
        \ [candidate],
        \ fnamemodify(candidate.source__args.path, ':p:h'))
endfunction
function! unite#kinds#versions#git#log#diff_prev(candidate)
  let candidate = a:candidate

  if !filereadable(candidate.source__args.path)
    return unite#start_temporary([['versions/git/changeset',
          \ candidate.source__args.path,
          \ candidate.action__log.revision,
          \ candidate.action__log.prev_revision]])
  endif

  call versions#diff#string_with_string({
        \   'name': printf('[REMOTE: %s] %s', candidate.action__log.revision, candidate.source__args.path),
        \   'string': versions#command('show', {
        \     'path': candidate.source__args.path,
        \     'revision': candidate.action__log.revision,
        \   }, {
        \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \   })
        \ }, {
        \   'name': printf('[REMOTE: %s] %s', candidate.action__log.prev_revision, candidate.source__args.path),
        \   'string': versions#command('show', {
        \     'path': candidate.source__args.path,
        \     'revision': candidate.action__log.prev_revision,
        \   }, {
        \     'working_dir': fnamemodify(candidate.source__args.path, ':p:h')
        \   })
        \ })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

